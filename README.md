# Apache Vhost Generator

## Overview
BASH script for generating an Apache Vhost. Designed for DEB and RPM servers.

## Usage
* **help/help**, Display help message and exit. <br>
* **generate/Generate**, generate Apache Vhost. <br>
  Script is guided, saves to locally generated output folder. <br>
  To bypass guide and generate vhost the following questions are asked : <br>
  - **What is the domain?**, Ex. `rustyspoon.com` <br>
    Enter a string. <br>
  - **Is there a WWW redirect?**, Ex. `www.rustyspoon.com` <br>
    If there isn't any kind of CNAME redirect this is likely to be no. <br>
    Enter "1" for yes, or "0" for no. <br>
  - **Should HTTP traffic redirect to HTTPS?**. <br>
    In most cases this will be port 80 traffic to port 443. <br>
    There may be cases where this action is not desired. <br>
    Enter "1" for yes, or "0" for no. <br>
  - **Is the site a WordPress site?** <br>
    If the site is a WordPress site the script will add some security flags for the uploads directory. <br>
    Enter "1" for yes, or "0" for no. <br>
  - **Is there a Docroot?** <br>
    If the VirtualHost is on a server where the site files are, a Docroot should be defined. <br>
    This configures a generic DocRoot that should be reviewed after Vhost is created. <br>
    While there may be exceptions, this option should not be used with the "Proxy Pass" option following. <br>
    Enter "1" for yes, or "0" for no. <br>
  - **Is there a Proxy Pass?** <br>
    If the VirtualHost is being configured to proxy traffic to another server, a Proxy Pass should be defined. <br>
    While there may be exceptions, this option should not be used with the preceeding "Docroot" option. <br>
    Enter "1" for yes, or "0" for no. <br> <br>
  Usage. `./apache-vhost-generator.sh DOMAIN WWW_REDIRECT? HTTP_TO_HTTPS? WORDPRESS? DOCROOT? PROXY_PASS?` <br>
  Ex. `./apache-vhost-generator.sh rustyspoon.com 1 1 0 1 0` <br>

  **IMPORTANT:** Vhost will need reviewed before used as some values are generic! See next section for details. <br>

## Review
Once the VirtualHost is generated at least the following items should be reviewed before the VirtualHost is used: <br>
* **SSL Certifications**, script will put placeholder SSL filepaths in place. <br>
  These should be updated before the VirtualHost is used. <br>
* **SSL Protocols**, script will put a few SSL Protocols in place. <br>
  These are _probably_ fine but may not cover all use cases. <br>
* **SSL Ciphers**, script will put a few SSL Ciphers in place. <br>
  These will _probably_ need expanded to be used safely in a Production environment. <br>
* **ProxyPass**, if ProxyPass option is used a placeholder variable is put in place. <br>
  Use `sed` or whatever find and replace tool is preferred to replace the placeholder `SERVER_IP` with the actual server's IP. <br>
* **Docroot**, if Docroot option is used a placeholder docroot based on the domain is added. <br>
  Adjust to whatever preferred docroot is used. <br>
  - **Docroot Options**, Some default Docroot options are put in place as well. These may also need updated depending on use case. <br>
* **WordPress**, If WordPress option is used some default configurations are put in place for the uploads directory. <br>
  These may require adjustment depending on configuration requirements. <br>
  The filepath is also based on the docroot configuration and may need reviewed as well. <br>
* **File Security changes**, these are simple placeholders and cover a few encountered examples. <br>
  These may need adjusted and should be reviewed before deployment. <br>
