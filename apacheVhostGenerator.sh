#!/usr/bin/bash

# Apache Vhost Generator
# BASH script for generating an Apache vhost
# By Nicholas Grogg

# Color variables
## Errors
red=$(tput setaf 1)
## Clear checks
green=$(tput setaf 2)
## User input required
yellow=$(tput setaf 3)
## Set text back to standard terminal font
normal=$(tput sgr0)

# Help function
function helpFunction(){
    printf "%s\n" \
    "Help" \
    "----------------------------------------------------" \
    " " \
    "help/Help" \
    "* Display this help message and exit" \
    " " \
    "generate/Generate" \
    "* Generate an Apache Vhost" \
    "* Designed for DEB/RPM servers only " \
    "* Saves to a locally created output folder" \
    "Usage, ./apacheVhostGenerator.sh generate" \
    " " \
    "Script can also take answers to questions as arguments." \
    "Usage. ./apacheVhostGenerator.sh generate DOMAIN WWW_REDIRECT? HTTP_TO_HTTPS? WORDPRESS? DOCROOT? PROXY_PASS?" \
    "Ex. ./apacheVhostGenerator.sh generate rustyspoon.com 1 1 0 1 0" \
    " " \
    "See README for breakdown of questions. " \
    "If unsure, run guided script. "
}

# Function to run program
function runProgram(){
    printf "%s\n" \
    "Generate" \
    "----------------------------------------------------"

    ## Variables
    siteDomain=$1
    wwwRedirect=$2
    httpRedirect=$3
    wordpressSite=$4
    docrootDefined=$5
    proxyPass=$6

    ## Check for output directory, create it if it doesn't exist
    if [[ ! -d output ]]; then
            mkdir output
    fi

    ## RPM or DEB based distro, assign filepaths based on output
	if [[ -e /usr/bin/dnf ]]; then
		apacheDir="/etc/httpd/"
        logDir="/var/log/httpd/"
	elif [[ -e /usr/bin/apt ]]; then
		apacheDir="/etc/apache2"
        logDir="/var/log/apache2"
	else
		### Script is designed for RPM/DEB servers.
		printf "%s\n" \
		"${red}ISSUE DETECTED - DNF/APT not found! "\
		"----------------------------------------------------" \
		"Script is for RPM/DEB servers only!${normal}"
		exit 1
	fi

    ## Private IP to variable, filter private IP of server
    privateIP=$(hostname -i | awk '{print $1}')

    ## Questions for VirtualHost, all assume a flag wasn't passed
    ### Domain
    if [[ -z $siteDomain ]]; then
            printf "%s\n" \
            "${yellow}What is the Domain?" \
            "----------------------------------------------------" \
            "Ex. rustyspoon.com" \
            " " \
            "Enter site domain to use:${normal}" \
            " "
            read siteDomain
    fi

    ### WWW Redirect?
    if [[ -z $wwwRedirect ]]; then
            printf "%s\n" \
            "${yellow}Is there a WWW Redirect?" \
            "----------------------------------------------------" \
            "WWW redirect for domain?" \
            "This is not needed if there isn't a CNAME redirect." \
            " " \
            "Ex. www.rustyspoon.com would redirect to rustyspoon.com" \
            " " \
            "Enter: 1 for yes or 0 for no${normal}" \
            " "
            read wwwRedirect
    fi

    ### HTTP -> HTTPS?
    if [[ -z $httpRedirect ]]; then
            printf "%s\n" \
            "${yellow}Should HTTP traffice redirect to HTTPS?" \
            "----------------------------------------------------" \
            "Redirect HTTP (port 80) traffic to HTTPS on (port 443)? " \
            " " \
            "Enter: 1 for yes or 0 for no${normal}" \
            " "
            read httpRedirect
    fi

    ### WordPress site?
    if [[ -z $wordpressSite ]]; then
            printf "%s\n" \
            "${yellow}Is the site a WordPress Site?" \
            "----------------------------------------------------" \
            "Script will add security options for upload dir" \
            " " \
            "Enter: 1 for yes or 0 for no${normal}" \
            " "
            read wordpressSite
    fi

    ### Docroot defined?
    if [[ -z $docrootDefined ]]; then
            printf "%s\n" \
            "${yellow}Is there a Docroot?" \
            "----------------------------------------------------" \
            "Should a Docroot be defined?" \
            "This option should not be used with Proxy Pass" \
            " " \
            "A Generic docroot will be defined" \
            " " \
            "Enter: 1 for yes or 0 for no${normal}" \
            " "
            read docrootDefined
    fi

    ### Proxy Pass to another server?
    if [[ -z $proxyPass ]]; then
            printf "%s\n" \
            "${yellow}Is there a Proxy Pass?" \
            "----------------------------------------------------" \
            "Will traffic be proxied to another server?" \
            "This option should not be used with Docroot" \
            " " \
            "A Generic Proxy Pass will be defined " \
            " " \
            "Enter: 1 for yes or 0 for no${normal}" \
            " "
            read proxyPass
    fi

    ## Value Confirmation, last chance to bail out
    printf "%s\n" \
    "${yellow}IMPORTANT: Value Confirmation" \
    "----------------------------------------------------" \
    "Site Domain: " "$siteDomain" \
    " " \
    "Should there be a WWW Redirect?" "$wwwRedirect" \
    " " \
    "Should there be a HTTP -> HTTPS Redirect?" "$httpRedirect" \
    " " \
    "Is site a WordPress site?" "$wordpressSite" \
    " " \
    "Should a Docroot be defined?" "$docrootDefined" \
    " " \
    "Should a Proxy Pass be defined?" "$proxyPass" \
    " " \
    "If all clear, press enter to proceed or ctrl-c to cancel${normal}" \
    " "
    read junkInput

    ## Check for vhost with file name already, move to new name and disable old vhost if so
    if [[ -f output/$siteDomain.conf ]]; then
            mv output/$siteDomain.conf output/$siteDomain.$(date +%Y%m%d).conf-DIS
    fi

    ## Begin HTTP Virtualhost section
    ### If HTTP -> HTTPS = 1
    if [[ $httpRedirect -eq "1" ]]; then
        echo "<VirtualHost $privateIP:80>" >> output/$siteDomain.conf
        echo "  ServerName $siteDomain" >> output/$siteDomain.conf

        #### If WWW Redirect = 1
        if [[ $wwwRedirect -eq "1" ]]; then
            echo "  ServerAlias www.$siteDomain" >> output/$siteDomain.conf
        fi

        #### Redirect to HTTPS
        echo "  # Use 302 for SEO" >> output/$siteDomain.conf
        echo "  Redirect 302 / https://$siteDomain/" >> output/$siteDomain.conf

        #### Close HTTP Virtualhost section
        echo "</VirtualHost>" >> output/$siteDomain.conf

        #### Whitespace
        echo "" >> output/$siteDomain.conf
    fi

    ### Begin HTTPS Virtualhost section
    echo "<VirtualHost $privateIP:443>" >> output/$siteDomain.conf
    echo "  ServerName $siteDomain" >> output/$siteDomain.conf

    #### If WWW Redirect = 1
    if [[ $wwwRedirect -eq "1" ]]; then
        echo "  ServerAlias www.$siteDomain" >> output/$siteDomain.conf
    fi

    #### Whitespace
    echo "" >> output/$siteDomain.conf

    ### Add options
    #### Explanation of options
    #### Do not follow simlinks (idea is to limit access to docroot)
    #### Do not follow indexes (idea is to prevent directory listing from web)
    echo "  # Add options" >> output/$siteDomain.conf
    echo "  ## Explanation of options" >> output/$siteDomain.conf
    echo "  ## Do not follow simlinks (idea is to limit access to docroot)" >> output/$siteDomain.conf
    echo "  ## Do not folow indexes (idea is to prevent directory listing from web)" >> output/$siteDomain.conf
    echo "  Options -FollowSymLinks -Indexes" >> output/$siteDomain.conf

    #### Whitespace
    echo "" >> output/$siteDomain.conf

    ### Apache logging
    echo "  # Apache Error logging" >> output/$siteDomain.conf
    echo "  ErrorLog $logDir/$siteDomain.error.log" >> output/$siteDomain.conf
    echo "  # Apache Access logging" >> output/$siteDomain.conf
    echo "  CustomLog $logDir/$siteDomain.access.log combined" >> output/$siteDomain.conf

    #### Whitespace
    echo "" >> output/$siteDomain.conf

    ### SSL Placeholder
    echo "  #TODO Replace with correct SSL filepaths" >> output/$siteDomain.conf
    echo "  SSLEngine on" >> output/$siteDomain.conf
    echo "  SSLCertificateFile $apacheDir/path/to/certfile" >> output/$siteDomain.conf
    echo "  SSLCertificateChainFile $apacheDir/path/to/chainfile" >> output/$siteDomain.conf
    echo "  SSLCertificateKeyFile $apacheDir/path/to/keyfile" >> output/$siteDomain.conf

    #### Whitespace
    echo "" >> output/$siteDomain.conf

    #TODO Replace with protocols as needed
    #### SSL Protocols
    echo "  # Allowed and Denied SSL Protocols, update as desired" >> output/$siteDomain.conf
    echo "  SSLProtocol all -SSLv2 -SSLv3 -TLSv1 -TLSv1.1 +TLSv1.2 +TLSv1.3" >> output/$siteDomain.conf

    #### Whitespace
    echo "" >> output/$siteDomain.conf

    #TODO Replace with ciphers as desired
    #### SSL Ciphers
    echo "  # Denied Ciphers, update as desired" >> output/$siteDomain.conf
    echo "  SSLCipherSuite \"HIGH:!aNULL:!MD5:!3DES:!CAMELLIA:!AES128\"" >> output/$siteDomain.conf

    #### Whitespace
    echo "" >> output/$siteDomain.conf

    ### Proxy Pass to another server?
    if [[ $proxyPass -eq "1" ]]; then
        echo "" >> output/$siteDomain.conf
        echo "  # Disable ProxyRequests for security" >> output/$siteDomain.conf
        echo "  ProxyRequests Off" >> output/$siteDomain.conf
        echo "  # Enable preserve host, helpful for generating proper responses and handling redirects" >> output/$siteDomain.conf
        echo "  ProxyPreserveHost on" >> output/$siteDomain.conf
        echo "  # Proxy Pass to IP, TODO: update with IP as needed" >> output/$siteDomain.conf
        echo "  ProxyPass / https://SERVER_IP/ retry=0" >> output/$siteDomain.conf
        echo "  # Proxy Pass Reverse Proxy, TODO: update with IP as needed" >> output/$siteDomain.conf
        echo "  ProxyPassReverse / https://SERVER_IP/" >> output/$siteDomain.conf
    fi

    ### Create a docroot for domain?
    if [[ $docrootDefined -eq "1" ]]; then
        echo "" >> output/$siteDomain.conf
        echo "  #TODO Adjust Docroot as needed" >> output/$siteDomain.conf
        echo "  DocumentRoot /var/www/$siteDomain" >> output/$siteDomain.conf
        echo "  DirectoryIndex index.php index.html" >> output/$siteDomain.conf
        echo "  # Docroot options, adjust as needed" >> output/$siteDomain.conf
        echo "  <Directory /var/www/$siteDomain>" >> output/$siteDomain.conf
        echo "    Options +FollowSymlinks -Indexes" >> output/$siteDomain.conf
        echo "    AllowOverride All" >> output/$siteDomain.conf
        echo "  </Directory>" >> output/$siteDomain.conf
    fi

    ### WordPress?
    #### WordPress upload directory
    if [[ $wordpressSite -eq "1" ]]; then
        echo "" >> output/$siteDomain.conf
        echo "  # Options to limit WordPress upload dir, adjust as needed" >> output/$siteDomain.conf
        echo "  <Directory /var/www/$siteDomain/wp-content/uploads" >> output/$siteDomain.conf
        echo "    AllowOverride None" >> output/$siteDomain.conf
        echo "    SetHandler None" >> output/$siteDomain.conf
        echo "    SetHandler default-handler" >> output/$siteDomain.conf
        echo "    Options -ExecCGI" >> output/$siteDomain.conf
        echo "    php_flag engine off" >> output/$siteDomain.conf
        echo "    #TODO: Expand or limit as needed" >> output/$siteDomain.conf
        echo "    RemoveHandler .cgi .php .php3 .php4 .php5 .php7 .php8 .phtml .pl .py .pyc .pyo .sh .bash .rb .exe .scr .dll .msi .jsp .asp .aspx .shtml .phar .jar .wsf" >> output/$siteDomain.conf
        echo "  </Directory>" >> output/$siteDomain.conf
    fi

    #### Whitespace
    echo "" >> output/$siteDomain.conf

    #TODO Update security changes as needed
    ### File security
    #### FileMatch Blocks
    echo "  #TODO Update Security Changes as needed" >> output/$siteDomain.conf
    echo "  # FileMatch blocks, deny access to extensions" >> output/$siteDomain.conf
    echo "  <FilesMatch \"\.(php|php[0-9]|phtml|phar|pl|py|sh|cgi|asp|aspx|jsp|jar|exe|dll|scr|msi|wsf)$\">" >> output/$siteDomain.conf
    echo "    Order Allow,Deny" >> output/$siteDomain.conf
    echo "    Deny from all" >> output/$siteDomain.conf
    echo "  </FilesMatch>" >> output/$siteDomain.conf

    #### Whitespace
    echo "" >> output/$siteDomain.conf

    #### Deny access to xmlrpc.php
    echo "  # Deny access to xmlrpc.php" >> output/$siteDomain.conf
    echo "  <files xmlrpc.php>" >> output/$siteDomain.conf
    echo "    order allow,deny" >> output/$siteDomain.conf
    echo "    deny from all" >> output/$siteDomain.conf
    echo "  </files>" >> output/$siteDomain.conf

    #### Whitespace
    echo "" >> output/$siteDomain.conf

    #### LocationMatch blocks, adjust/expand as needed
    echo "  # LocationMatch Blocks, adjust/expand as needed" >> output/$siteDomain.conf
    echo "  <LocationMatch \"/\.git\">" >> output/$siteDomain.conf
    echo "    require all denied" >> output/$siteDomain.conf
    echo "  </LocationMatch>" >> output/$siteDomain.conf
    echo "  <LocationMatch \"/\.env\">" >> output/$siteDomain.conf
    echo "    require all denied" >> output/$siteDomain.conf
    echo "  </LocationMatch>" >> output/$siteDomain.conf
    echo "  <LocationMatch  \"log(.*)\.txt$\">" >> output/$siteDomain.conf
    echo "    require all denied" >> output/$siteDomain.conf
    echo "  </LocationMatch>" >> output/$siteDomain.conf
    echo "  <LocationMatch \"/\.sftp-config\.json\">" >> output/$siteDomain.conf
    echo "    require all denied" >> output/$siteDomain.conf
    echo "  </LocationMatch>" >> output/$siteDomain.conf
    echo "  <LocationMatch \"/sftp-config\.json\">" >> output/$siteDomain.conf
    echo "    require all denied" >> output/$siteDomain.conf
    echo "  </LocationMatch>" >> output/$siteDomain.conf

    #### Whitespace
    echo "" >> output/$siteDomain.conf

    #### Enable Forward Proxying and Access Control for Reverse Proxy, disable if not needed.
    echo "  # Enable Proxy, disable if not needed" >> output/$siteDomain.conf
    echo "  <Proxy *>" >> output/$siteDomain.conf
    echo "    Order deny,allow" >> output/$siteDomain.conf
    echo "    Allow from all" >> output/$siteDomain.conf
    echo "  </Proxy>" >> output/$siteDomain.conf

    ### Close HTTPS Virtualhost tag
    echo "</VirtalHost>" >> output/$siteDomain.conf

    ## Closing notes
    printf "%s\n" \
    "${green}VirtualHost generated" \
    "----------------------------------------------------" \
    "Check output dir" \
    "Verify values correct before deploying VirtualHost${normal} "
}

# Main, read passed flags
printf "%s\n" \
"Apache Vhost Generator" \
"----------------------------------------------------" \
" " \
"Checking flags passed" \
"----------------------------------------------------"

# Check passed flags
case "$1" in
[Hh]elp)
    printf "%s\n" \
    "Running Help function" \
    "----------------------------------------------------"
    helpFunction
    exit
    ;;
[Gg]enerate)
    printf "%s\n" \
    "Running script" \
    "----------------------------------------------------"
    runProgram $2 $3 $4 $5 $6 $7
    ;;
*)
    printf "%s\n" \
    "${red}ISSUE DETECTED - Invalid input detected!" \
    "----------------------------------------------------" \
    "Running help script and exiting." \
    "Re-run script with valid input${normal}"
    helpFunction
    exit
    ;;
esac
