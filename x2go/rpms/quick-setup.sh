#!/bin/bash

### Quick Setup Steps:
###
### 1. Create the files below
### 2. Create the records in the DB
### 2a.  Insert the localhost keypair into the DB
###
###
###

### EDIT HERE TO CONFIGURE YOUR DOMAIN ##############################

# The name to give your domain
DOMAIN_NAME="wikid93"
# The routable IP of your domain
DOMAIN_IP="192.168.1.93"
# The converted IP of your domain
DOMAIN_CODE="192168001093"
# The IP or DNS name of your server
HOSTNAME="wikid93.local"
# the passphrase for your cert(s)
PASSPHRASE="wikidone"

# Fill in the below certificate values as appropriate for your organization
A_CN="$HOSTNAME"
A_OU="wikid"
A_O="wikid"
A_L="atlanta"
A_ST="georgia"
A_C="us"
A_EMAILADDRESS="ghaygood@wikidsystems.com"

### STOP EDITING HERE TO CONFIGURE YOUR DOMAIN ######################

javac QuickSetup.java

#####################################################################
### DO NOT EDIT BELOW THIS LINE #####################################
#####################################################################

WIKID_ROOT="/opt/WiKID"

CLASSPATH="."
for jar in $WIKID_ROOT/lib/*.jar; do
	CLASSPATH=$CLASSPATH:$jar
done

CERT_DIR="$WIKID_ROOT/private"

DN1="CN=$A_CN,OU=$A_OU,O=$A_O,L=$A_L,ST=$A_ST,C=$A_C"
DN2="$DN1,EMAILADDRESS=$A_EMAILADDRESS"
DN3="E=$A_EMAILADDRESS,C=$A_C,ST=$A_ST,L=$A_L,O=$A_O,OU=$A_OU,CN=$A_CN"

echo "DN1: $DN1"
echo "DN2: $DN2"

PSQL_CMD="psql -q -t -A -U postgres wikid"

KEY_ARGS="-keysize 1024 -keyalg RSA -sigalg MD5withRSA"
BC_ARGS="-storetype BKS -provider org.bouncycastle.jce.provider.BouncyCastleProvider -providerpath /opt/WiKID/lib/bcprov-jdk15-136.jar"

TOMCAT_FILE="$WIKID_ROOT/conf/tomcatKeystore"
LOCALHOST_FILE="$CERT_DIR/localhost.p12"
INT_CA_FILE="$CERT_DIR/intCAKeys.p12"
INT_CA_CSR_FILE="$CERT_DIR/intCAKeys.csr"
INT_CA_CERT_FILE="$CERT_DIR/intCAKeys.cert"
CA_STORE_FILE="$CERT_DIR/CACertStore"

INT_CA_CERT_FILE_TMP="${INT_CA_CERT_FILE}.tmp"
INT_CA_CERT_FILE_DER="${INT_CA_CERT_FILE}.der"

rm -rf $TOMCAT_FILE $LOCALHOST_FILE $INT_CA_FILE $INT_CA_CERT_FILE $INT_CA_CSR_FILE $CA_STORE_FILE $INT_CA_CERT_FILE_TMP $INT_CA_CERT_FILE_DER


#CA_SERVER="https://ca.wikidsystems.com/wikid/processReq.jsp"
CA_SERVER="https://192.168.1.196/wikidca/processReq.jsp"
#CA_SERVER="https://10.148.65.138/wikidca/processReq.jsp"

## 0. check that domain does not already exist

check_for_domain_sql="select code from domain where code='$DOMAIN_CODE'"
domain_exists=`echo $check_for_domain_sql | $PSQL_CMD`
echo "domain_exists: $domain_exists"
if [ ! -z "$domain_exists" ]; then
	echo "Domain code $DOMAIN_CODE already in use!"
	exit 1
fi

## 1. create tomcat cert

#echo "1. creating tomcat cert ..."

#pp="passphrase"
#keytool -genkey -dname "$DN1" -alias tomcat -keyalg RSA -keystore "$TOMCAT_FILE" -keypass "$pp" -storepass "$pp"
#keytool -selfcert -dname "$DN1" -alias tomcat -keystore "$TOMCAT_FILE" -keypass "$pp" -storepass "$pp"

## 2. create localhost cert

pp=$PASSPHRASE

#keytool -genkeypair $KEY_ARGS -v -alias localhost -dname "$DN2" -keystore $LOCALHOST_FILE -storetype pkcs12 -validity 365 -storepass "$pp"

## 3. create intermediate CA cert

# cmd="java -cp $CLASSPATH QuickSetup servercerts $CA_SERVER $pp $A_EMAILADDRESS $A_C $A_ST $A_L $A_O $A_OU $A_CN"

#echo "CMD: '$cmd'"

output=$(java -cp $CLASSPATH QuickSetup "servercerts" "$CA_SERVER" "$pp" "$A_EMAILADDRESS" "$A_C" "$A_ST" "$A_L" "$A_O" "$A_OU" "$A_CN")

echo $output

#keytool -genkeypair $KEY_ARGS -dname "$DN2" -alias 'int' -keypass wikidone -storepass wikidone -keystore "$INT_CA_FILE"
#keytool -certreq $KEY_ARGS -dname "$DN2" -alias 'int' -keypass wikidone -storepass wikidone -keystore "$INT_CA_FILE" > "$INT_CA_CSR_FILE"

#CSR="$(cat $INT_CA_CSR_FILE | perl -p -e 's/\n/%0A/g; s/\r/%0D/g' )"
#CSR="$(cat $INT_CA_CSR_FILE | grep -v 'CERTIFICATE REQUEST' )"
#echo "CSR:"
#echo "$CSR"

#CSR_e="$(perl -MURI::Escape -e "print uri_escape('$CSR');")"
#CSR_e=$CSR
#echo "$CSR_e"

#echo "   posting to WiKID CA ..."
#curl -X POST  --insecure --data "csrText=${CSR_e}&submit=Submit%26for%26Processing\n" $CA_SERVER > $INT_CA_CERT_FILE_TMP
#echo "  all done!"
#cat $INT_CA_CERT_FILE

#perl -ne 'print if /-----BEGIN CERTIFICATE-----/ .. /-----END CERTIFICATE-----/' $INT_CA_CERT_FILE_TMP > $INT_CA_CERT_FILE

#ca_pp="changeit"
#keytool -importcert -noprompt -file /opt/WiKID/private/WiKIDCA.cer -trustcacerts -alias wikid -keypass $ca_pp -storepass $ca_pp -storetype jks -keystore $CA_STORE_FILE

#openssl x509 -outform der -in $INT_CA_CERT_FILE -out $INT_CA_CERT_FILE_DER
#keytool -importcert -noprompt -file $INT_CA_CERT_FILE_DER -trustcacerts -alias "$DN3" -keypass $ca_pp -storepass $ca_pp -storetype jks -keystore $CA_STORE_FILE


## 3. setup the DB records

### 3a. Create the RADIUS host record, if needed


get_radius_host_id_sql="select id_host from host where type=1 and subtype=1 LIMIT 1";

host_id=`echo $get_radius_host_id_sql | $PSQL_CMD`
echo "host_id: $host_id"
if [ -z "$host_id" ]; then

	radius_host_sql='INSERT INTO "public"."host" ("ip", "name", "port", "enabled", "config", "type", "subtype", "debug_level", "multihome", "restrict_nc")'
	radius_host_sql="$radius_host_sql VALUES ('127.0.0.1', 'WiKID Radius Authentication', 1812, 1, 'pwencode=UTF8&scencode=UTF8', 1, 1, 1, 1, 0)"

	echo "---------------------------"
	echo "radius_host_sql: $radius_host_sql"
	echo "---------------------------"
	echo $radius_host_sql | $PSQL_CMD
fi

### 3b. Create the domain record

get_domain_id_sql="select currval('domain_id_domain_seq') as domain_id"
get_nc_id_sql="select currval('network_client_id_nc_seq') as domain_id"

domain_sql='INSERT INTO "public"."full_domain" ("code", "name", "ddname", "minpin", "maxattempts", "valid", "maxbads", "maxoffs", "tacacs", "publickey", "privatekey", "registered_url", "registered_url_hash", "nt_host", "nt_domain_name", "admin_user", "admin_passwd")'
domain_sql="$domain_sql VALUES ('$DOMAIN_CODE', '$DOMAIN_NAME', '$DOMAIN_NAME', 5, 3, 60, 3, 5, 0, '', '', '', '', '', '', '', '')"

echo "domain_sql: $domain_sql"

### 3c. Create the domain keys record

#domain_key_sql='INSERT INTO "public"."full_domain_keys" ("id_domain", "id_cryptotype", "dompublickey", "domprivatekey", "domkeysize", "offlinekeysize")'
#domain_key_sql="$domain_key_sql VALUES (($get_domain_id_sql), 1, '', '', 1024, 1024)"
#echo "domain_key_sql: $domain_key_sql"
domain_key_sql=''

### 3d. Create the network client record

nc_sql='INSERT INTO "public"."full_network_client" ("ip", "name", "secret", "domain", "enforced")'
nc_sql="$nc_sql VALUES ( '$DOMAIN_IP', 'local radius client', 'mysecret', ($get_domain_id_sql), 1)"
echo "nc_sql: $nc_sql";

### 3e. Create the network client mapping record
nc_map_sql='INSERT INTO "public"."host_nc_map" ("host", "nc")'
nc_map_sql="$nc_map_sql VALUES ( ($get_radius_host_id_sql), ($get_nc_id_sql) )"
echo "nc_map_sql: $nc_map_sql"

## run all SQL commands

full_sql="$domain_sql; $domain_key_sql; $nc_sql; $nc_map_sql; "

echo "---------------------------"
echo "full_sql: $full_sql"
echo "---------------------------"
echo $full_sql | $PSQL_CMD

## Setup domain keys

java -cp $CLASSPATH QuickSetup "domainkeys" "$DOMAIN_CODE"

echo "All done!"

