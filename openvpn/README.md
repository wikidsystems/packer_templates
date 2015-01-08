# Overview

This packer script builds an openvpn community server that is ready for two-factor authentication using pam-radius. 

Why use pam-radius and one-time passwords when openvpn includes certs?  A few reasons"

1.  Radius allows you to perform authorization in your directory and use a third-party two-factor auth server for authentication which you can do with [NPS and Active Directory](https://www.wikidsystems.com/support/wikid-support-center/how-to/how-to-add-two-factor-authentication-to-nps) or [freeradius/openldap](https://www.wikidsystems.com/support/wikid-support-center/how-to/how-to-add-two-factor-authentication-to-openldap-and-freeradius). Managing your users in your directory is a Good Thing.
2.  Radius is an open protocol supported by all enterprise-class remote access solutions and two-factor authentication servers.  So, when you outgrow your Openvpn server, you can easily switch to [Cisco](https://www.wikidsystems.com/support/wikid-support-center/how-to/how-to-configure-a-cisco-vpn-concentrator-for-two-factor-authentication-from-wikid), [Juniper](https://www.wikidsystems.com/support/wikid-support-center/how-to/how-to-use-wikid-strong-authentication-with-juniper-uac-appliance), [Citrix](https://www.wikidsystems.com/support/wikid-support-center/how-to/how-to-add-two-factor-authentication-to-a-citrix-access-gateway), etc. 
3.  Because Radius works with so many services, you can use the same two-factor setup for say [VMWare View](https://www.wikidsystems.com/support/wikid-support-center/how-to/how-to-add-two-factor-authentication-to-a-citrix-access-gateway) as you for openvpn, instead of managing certs for one and software tokens for another.

# Installation

Please see the installation instructions here: https://www.wikidsystems.com/support/wikid-support-center/tutorials/build-a-2fa-ready-openvpn-community-virtual-appliance.
