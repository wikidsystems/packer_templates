
import com.ntru.jNeo.Context;
import com.ntru.jNeo.EncKeys;
import com.ntru.jNeo.NTRUConst;
import com.ntru.jNeo.RandomNumber;
import com.wikidsystems.cert.utils;
import com.wikidsystems.cert.WikidCert;
import com.wikidsystems.client.TokenClientType;
import com.wikidsystems.crypto.JksKeyStore;
import com.wikidsystems.crypto.wEncKeys;
import com.wikidsystems.crypto.wEncKeysFactory;
import com.wikidsystems.crypto.wJceEncKeysFactory;
import com.wikidsystems.db.PooledConnectionManager;
import com.wikidsystems.server.ServletCrypto;
import com.wikidsystems.util.B64;
import com.wikidsystems.util.Config;
import com.wikidsystems.util.JSPUtils;
import com.wikidsystems.util.JSPUtils;
import com.wikidsystems.util.stringUtils;
import java.io.*;
import java.io.FileOutputStream;
import java.math.BigInteger;
import java.security.cert.Certificate;
import java.security.cert.CertificateException;
import java.security.KeyPair;
import java.security.KeyStore;
import java.security.KeyStoreException;
import java.security.NoSuchAlgorithmException;
import java.security.Security;
import java.sql.*;
import java.util.Enumeration;
import java.util.Hashtable;
import java.util.Vector;
import org.apache.log4j.Logger;
import org.bouncycastle.asn1.x509.X509Name;
import org.bouncycastle.jce.PKCS10CertificationRequest;
import org.bouncycastle.jce.provider.BouncyCastleProvider;
import org.bouncycastle.x509.X509V1CertificateGenerator;
import org.bouncycastle.jce.PrincipalUtil;
import com.wikidsystems.cert.WikidCert;
import com.wikidsystems.util.Config;
import com.wikidsystems.util.JSPUtils;
import org.apache.log4j.Logger;
import org.bouncycastle.jce.provider.BouncyCastleProvider;
import org.bouncycastle.util.encoders.Base64;
import java.io.*;
import java.security.KeyPair;
import java.security.KeyStore;
import java.security.PrivateKey;
import java.security.Security;
import java.security.cert.Certificate;
import java.security.cert.CertificateFactory;
import java.security.cert.X509Certificate;

public class QuickSetup {

	private static String BASEPATH = "/opt/WiKID";

	private static Connection conn;
	private static Statement stmt;
	private static long domainId;

	private static void out(String s) {
		System.out.println(s);
	}

	private static void error(String s) {
		System.err.println("ERROR: " + s);
	}

	public static boolean addDomainKeys(String domainCode) {

		try {
			RandomNumber tmpRN = new RandomNumber(NTRUConst.NTRU_SHA160_HASH);
			Context ctx = new Context(tmpRN);
			EncKeys ekeys = new EncKeys(ctx, NTRUConst.NTRU_PARAMSET_EES251EP4, NTRUConst.NTRU_SHA1_HASH);
			byte[] pubKeyBytes = ekeys.exportPubKey(false);
			byte[] privKeyBytes = ekeys.exportPrivKey(false);

			PreparedStatement pstmt = conn.prepareStatement("update domain set publickey=?, privatekey=? where code=? and publickey='' and privatekey=''");
			pstmt.setBytes(1, pubKeyBytes);
			pstmt.setBytes(2, privKeyBytes);
			pstmt.setString(3, domainCode);
			int modified = pstmt.executeUpdate();
			out("Result of SQL update: " + String.valueOf(modified));
			pstmt.close();

            int chosenAlg = 1;  // RSA
            int keySize = 1024;
            int offlineKeySize = 1024;

            PreparedStatement pstmt2 = conn.prepareStatement("SELECT keyalg, ciphertransformation AS ct FROM cryptotype where id_cryptotype=?");
            pstmt2.setInt(1, chosenAlg);
            ResultSet presult2 = pstmt2.executeQuery();
            if (!presult2.next()) {
            	//XXX: add error handling here.
            }

            wEncKeysFactory wkeyfactory = new wJceEncKeysFactory(presult2.getString("keyalg"), presult2.getString("ct"), keySize);
            wEncKeys ekeys2 = wkeyfactory.generatePair();

            PreparedStatement pstmt3 = conn.prepareStatement("INSERT INTO domain_keys(id_domain, id_cryptotype, dompublickey, domprivatekey, domkeysize, offlinekeysize) VALUES(?, ?, ?, ?, ?, ?)");
            pstmt3.setLong(1, domainId);
            pstmt3.setInt(2, chosenAlg);
            pstmt3.setBytes(3, ekeys2.exportPubKey());
            pstmt3.setBytes(4, ekeys2.exportPrivKey());
            pstmt3.setInt(5, keySize);
            pstmt3.setInt(6, offlineKeySize);

            pstmt3.execute();

            return true;

        } catch (Exception ex) {
        	ex.printStackTrace();
        }
        return false;
    }

    public static boolean checkForDomain(String domainCode) {

    	String sql = "SELECT code,id_domain FROM domain where code='" + domainCode + "'";

    	try {
    		ResultSet result = stmt.executeQuery(sql);
    		if (result.next()) {
    			domainId = result.getLong("id_domain");
    			out("domain exists! " + String.valueOf(domainId));
    			return true;
    		} else {
    			out("domain does not exist!");
    			return false;
    		}
    	} catch (Exception ex) {
    		ex.printStackTrace();
    	}
    	return false;
    }

    public static String setupTomcatCert(String[] args) {

    	out("** creating Tomcat cert ...");

    	String tomcatKeystore = BASEPATH + "/conf/tomcatKeystore";

		/*
			pp="passphrase"
			keytool -genkey -dname "$DN1" -alias tomcat -keyalg RSA -keystore "$TOMCAT_FILE" -keypass "$pp" -storepass "$pp"
			keytool -selfcert -dname "$DN1" -alias tomcat -keystore "$TOMCAT_FILE" -keypass "$pp" -storepass "$pp"
		*/

		// DN1="CN=$A_CN,OU=$A_OU,O=$A_O,L=$A_L,ST=$A_ST,C=$A_C"

    	String passphrase = "passphrase"; //args[0].trim();
    	String e = args[1].trim();
    	String c = args[2].trim();
    	String st = args[3].trim();
    	String l = args[4].trim();
    	String o = args[5].trim();
    	String ou = args[6].trim();
    	String cn = "localhost"; // args[7].trim();

    	String subjectDN = "CN=" + cn +
					    	",OU=" + ou +
					    	",O=" + o +
					    	",L=" + l +
					    	",ST=" + st +
					    	",C=" + c;

		String[] args1 = new String[] { "keytool", "-genkey", "-dname", subjectDN, "-alias", "tomcat", "-keyalg", "RSA", "-keystore", tomcatKeystore, "-keypass", passphrase, "-storepass", passphrase };
		runCommand( args1 );
		String[] args2 = new String[] { "keytool", "-selfcert", "-dname", subjectDN, "-alias", "tomcat", "-keystore", tomcatKeystore, "-keypass", passphrase, "-storepass", passphrase };
		runCommand( args2 );

		return "";
    }

    public static String setupLocalCert(String[] args) {

    	out("** Setting up localhost cert ...");

    	for (int i=0; i<args.length; i++) {
    		out("Localhost Arg " + String.valueOf(i) + " = " + args[i]);
    	}

    	String passphrase = args[0].trim();
    	String e = args[1].trim();
    	String c = args[2].trim();
    	String st = args[3].trim();
    	String l = args[4].trim();
    	String o = args[5].trim();
    	String ou = args[6].trim();
    	String cn = "localhost"; // args[7].trim();

    	String subjectDN = "C=" + c +
					    	",ST=" + st +
					    	",L=" + l +
					    	",O=" + o +
					    	",OU=" + ou +
					    	",CN=" + cn;

    	String ncid=null;

    	Vector ordering = new Vector();
    	ordering.add(X509Name.C);
    	ordering.add(X509Name.ST);
    	ordering.add(X509Name.L);
    	ordering.add(X509Name.O);
    	ordering.add(X509Name.OU);
    	ordering.add(X509Name.CN);
    	Hashtable attrib = new Hashtable();
    	attrib.put(X509Name.C, c);
    	attrib.put(X509Name.ST, st);
    	attrib.put(X509Name.L, l);
    	attrib.put(X509Name.O, o);
    	attrib.put(X509Name.OU, ou);
    	attrib.put(X509Name.CN, cn);

    	Security.addProvider(new BouncyCastleProvider());

    	try{
    		KeyStore ks = KeyStore.getInstance("PKCS12", "BC");
    		char[] pp = passphrase.toCharArray();
    		ks.load(new FileInputStream(BASEPATH + "/private/intCAKeys.p12"), pp);
    		Enumeration enumerator = ks.aliases();
    		String alias = "";
    		while(enumerator.hasMoreElements()){
    			alias = enumerator.nextElement().toString();
    		}
    		X509Certificate cacert = (X509Certificate)ks.getCertificate(alias);
    		KeyPair cakeys = new KeyPair(cacert.getPublicKey(), (PrivateKey) ks.getKey(alias, pp));
    		X509Name issuer = PrincipalUtil.getSubjectX509Principal(cacert);

    		String sql = "insert into network_client (ip,name,secret,enforced,domain) values ('127.0.0.1','localhost',' ',0,0)";
    		int result = stmt.executeUpdate(sql);
    		ResultSet cs= stmt.executeQuery("select currval('network_client_id_nc_seq'::text)");
    		if(cs.next()){
    			ncid=cs.getString(1);
    		}

    		X509Name subject = new X509Name (ordering,attrib);
    		KeyPair keys = WikidCert.generateKeys(1024);
    		X509Certificate clientCert = WikidCert.createCert(issuer,subject,cakeys,keys.getPublic(),365,new BigInteger(ncid),false);
    		Certificate[] certs = new Certificate[1];
    		certs[0] = clientCert;
    		FileOutputStream fOut = new FileOutputStream(BASEPATH+"/private/"+cn.trim()+".p12");
    		KeyStore ks2 = KeyStore.getInstance("PKCS12", "BC");
    		ks2.load(null,null);
    		ks2.setKeyEntry(cn,keys.getPrivate(),pp,certs);
    		ks2.store(fOut, pp);

			// Set the preferences entries for the demo app and local radius
    		if (cn.equalsIgnoreCase("localhost")){
    			stmt.executeUpdate("update parms1to1 set value='"+passphrase+"' where key='localhost.p12PW'");
    			stmt.executeUpdate("update parms1to1 set value='"+passphrase+"' where key='LDAP_wauth_pass'");
    			stmt.executeUpdate("update parms1to1 set value='"+passphrase+"' where key='demowClientPass'");
    		}
    	} catch (Exception ex) {
    		ex.printStackTrace();
    	}

    	return "";
    }

    public static String setupIntCert(String[] args) {

    	out("** Setting up intermediate CA cert ...");

    	String passphrase = args[0].trim();
    	String e = args[1].trim();
    	String c = args[2].trim();
    	String st = args[3].trim();
    	String l = args[4].trim();
    	String o = args[5].trim();
    	String ou = args[6].trim();
    	String cn = args[7].trim();

    	String subjectDN = "E=" + e +
					    	",C=" + c +
					    	",ST=" + st +
					    	",L=" + l +
					    	",O=" + o +
					    	",OU=" + ou +
					    	",CN=" + cn;

    	Vector ordering = new Vector();
    	ordering.add(X509Name.E);
    	ordering.add(X509Name.C);
    	ordering.add(X509Name.ST);
    	ordering.add(X509Name.L);
    	ordering.add(X509Name.O);
    	ordering.add(X509Name.OU);
    	ordering.add(X509Name.CN);
    	Hashtable attrib = new Hashtable();
    	attrib.put(X509Name.E, e);
    	attrib.put(X509Name.C, c);
    	attrib.put(X509Name.ST, st);
    	attrib.put(X509Name.L, l);
    	attrib.put(X509Name.O, o);
    	attrib.put(X509Name.OU, ou);
    	attrib.put(X509Name.CN, cn);


    	Security.addProvider(new org.bouncycastle.jce.provider.BouncyCastleProvider());
    	PKCS10CertificationRequest req = null;
    	try {
        //X509Name subject = new X509Name(false,subjectDN);
    		X509Name subject = new X509Name(ordering, attrib);

    		KeyPair keys = WikidCert.generateKeys(2048);

    		X509V1CertificateGenerator cg = new X509V1CertificateGenerator();
    		cg.setSignatureAlgorithm("MD5WITHRSA");
    		cg.setIssuerDN(subject);
    		java.util.Date tm = new java.util.Date();
    		cg.setNotAfter(new java.util.Date(tm.getTime() + (86400000L * 365)));
    		cg.setNotBefore(tm);
    		cg.setPublicKey(keys.getPublic());
    		cg.setSerialNumber(new BigInteger("1"));
    		cg.setSubjectDN(subject);
    		Certificate[] certs = new Certificate[1];
    		certs[0] = cg.generateX509Certificate(keys.getPrivate());

    		req = WikidCert.makeCertRequest(subject, keys, null);
    		Security.addProvider(new BouncyCastleProvider());

//			out.print("<pre>"+certs[0]+"</pre>");
    		FileOutputStream fOut = new FileOutputStream(BASEPATH + "/private/intCAKeys.p12");
    		KeyStore ks = KeyStore.getInstance("PKCS12", "BC");
    		ks.load(null, null);

    		char[] pp = passphrase.toCharArray();

    		ks.setKeyEntry("key", keys.getPrivate(), pp, certs);
    		ks.store(fOut, pp);
    		fOut.flush();
    		fOut.close();

    		return WikidCert.blockFormat(req.getEncoded(), "-----BEGIN CERTIFICATE SIGNING REQUEST-----", "-----END CERTIFICATE SIGNING REQUEST-----");

		} catch (Exception ex) {
			ex.printStackTrace();
		}

		return "";
    }

    private static String runCommand(String[] args) {
    	return runCommand(args, null);
    }

    private static String runCommand(String[] args, String input) {

    	out("** Running command: ");
		for (int i=0; i<args.length; i++) {
    		out("'" + args[i] + "'");
    	}

		StringBuffer sb = new StringBuffer("");

    	try {

    		ProcessBuilder builder = new ProcessBuilder(args);
    		builder.redirectErrorStream(true);
    		Process p = builder.start();

    		// if (input != null) {
    		// 	out("*** Sending input: " + input);

    		// 	BufferedWriter bw = new BufferedWriter( new OutputStreamWriter( p.getOutputStream() ) );

    		// 	bw.write(input);
		    //     bw.newLine();
		    //     bw.close();
    		// }
    		BufferedReader rd = new BufferedReader( new InputStreamReader( p.getInputStream() ) );

    		String line = null;
    		while ( (line = rd.readLine()) != null ) {
    			sb.append(line + "\n");
    		}
    		rd.close();

    	} catch (Exception ex) {
    		ex.printStackTrace();
    	}

    	return sb.toString();
    }

    public static String extractCert(String input) {

    	StringBuffer sb = new StringBuffer("");
    	String lines[] = input.split("\\r?\\n");

    	String line = "";
    	boolean keep = false;
    	for (int i=0; i<lines.length; i++) {
    		line = lines[i];
    		if ("-----BEGIN CERTIFICATE-----".equals(line)) {
    			keep = true;
    		}

    		if (keep) {
    			sb.append(line + "\n");
    		}

    		if ("-----END CERTIFICATE-----".equals(line)) {
    			keep = false;
    		}
    	}

    	return sb.toString();
    }

    public static String encodeCSR(String csr) {
		String csrEncoded = java.net.URLEncoder.encode(csr);
		return csrEncoded;
    }

    public static String submitIntCSR(String caServer, String csr) {

    	out("** Submitting intermediate CA CSR ...");

		// curl -X POST  --insecure --data "csrText=${CSR_e}&submit=Submit%26for%26Processing\n" $CA_SERVER > $INT_CA_CERT_FILE_TMP

    	try {

    		String[] args = new String[] { "curl", "--trace-ascii", "/tmp/curl-trace", "-s", "-S", "-X", "POST", "--insecure", "--data", "csrText=" + encodeCSR(csr) + "&submit=Submit%26for%26Processing", caServer };

    		String fullOutput = runCommand(args);
    		out("fullOutput: " + fullOutput);

    		String cert = extractCert(fullOutput);

    		out("Submission results: ");
    		out(cert);

    		return cert;

    	} catch (Exception ex) {
    		ex.printStackTrace();
    	}

    	return "";
    }

    public static String installIntCert(String certBlock, String passphrase) {

    	out("** Installing intermediate CA cert ...");

		try {
	    	Security.addProvider(new BouncyCastleProvider());

	    	CertificateFactory cf = CertificateFactory.getInstance("X.509", "BC");
	    	X509Certificate cert = (X509Certificate) cf.generateCertificate(new ByteArrayInputStream(Base64.decode(WikidCert.blockUnformat(certBlock))));
	    	if (cert != null) {
	    		char[] pp = passphrase.trim().toCharArray();
	    		File f = new File(BASEPATH + "/private/intCAKeys.p12");
	    		KeyStore ks = KeyStore.getInstance("PKCS12", "BC");
    			ks.load(new FileInputStream(f), pp);
    			KeyPair keys = new KeyPair(cert.getPublicKey(), (PrivateKey) ks.getKey("key", pp));
    			Certificate[] newChain = new Certificate[1];
    			newChain[0] = cert;
    			f.delete();
    			KeyStore ks2 = KeyStore.getInstance("PKCS12", "BC");
    			ks2.load(null, null);
    			ks2.setKeyEntry("", keys.getPrivate(), pp, newChain);
    			FileOutputStream fOut = new FileOutputStream(f);
    			ks2.store(fOut, pp);
    			fOut.close();
    			ks = KeyStore.getInstance("JKS");
    			ks.load(null, null);
    			ks.setCertificateEntry(cert.getSubjectDN().getName(), cert);
    			ks.setCertificateEntry("WiKID", WikidCert.readCertFromFile(BASEPATH + "/private/WiKIDCA.cer"));
    			fOut = new FileOutputStream(BASEPATH + "/private/CACertStore");
    			ks.store(fOut, "changeit".toCharArray());
    			fOut.close();

    			out("*** Intermediate cert installation completed!");
    		} else {
    			error("cert is null!");
    		}
    	} catch (Exception ex) {
    		ex.printStackTrace();
    	}

        return "";
    }

    public static void main(String[] args) {
    	try {

    		if (args.length > 0){

    			conn = PooledConnectionManager.getConnection();
    			stmt = conn.createStatement();

    			if ( "servercerts".equals(args[0]) ) {

    				String caServer = args[1];
    				String passphrase = args[2];

    				String[] certArgs = new String[args.length-2];
    				System.arraycopy(args, 2, certArgs, 0, args.length-2);
    				String csr = setupIntCert(certArgs);
    				out("CSR: " + csr);

    				String cert = submitIntCSR(caServer, csr);
    				out("CERT: " + cert);

    				setupTomcatCert( certArgs );
    				installIntCert( cert, passphrase );

    				setupLocalCert( certArgs );

    				//out(output);

    			} else if ( "domainkeys".equals(args[0]) ) {

	    			String domainCode = args[1];

	    			if (checkForDomain(domainCode)) {
	    				out("adding keys ...");
	    				boolean domainKeysUpdated = addDomainKeys(domainCode);
	    			}

	    		}

    			PooledConnectionManager.closeConnection(conn);

    		} else {
    			System.out.println("no key file specified!");

    		}
            //wClient wc = new wClient(args[0], Integer.parseInt(args[1]), args[2], args[3]);
    	} catch (Exception e) {
    		e.printStackTrace();
    	}
    }

}