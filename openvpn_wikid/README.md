# Overview

Over the years we've published a number of tutorials on [how to add two-factor authentication](https://www.wikidsystems.com/support/wikid-support-center/how-to) to various opensource remote access solutions.  We've recently started working with packer to create various virtual appliances, primarily for testing and potentially software distribution.

It occurred to me that using packer we could actually share not just the knowledge of how to create various two-factor-enabled virtual appliances, but also the scripts to do so. So, here's our first one for OpenVPN.  You can [see the detailed instructions](https://www.wikidsystems.com/support/wikid-support-center/tutorials/build-a-2fa-ready-openvpn-community-virtual-appliance) on our website. 

My main concern is that people will use these without securing them.  Please note that images created with these scripts are just proof-of-concepts, bare starting points. They are offered without warranty or support. We will update them periodically. For example, a recent update disabled IPv6 due to DNS leakage issues.

Find more information about the WiKID [two-factor authentication system](https://www.wikidsystems.com) including our the 5 free users licenses, pricing, install docs, etc.  
~                                      
