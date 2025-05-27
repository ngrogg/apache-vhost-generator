#!/usr/bin/bash

# Vhost Generator
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
    "Usage, ./vhostGenerator.sh generate"
}

# Function to run program
function runProgram(){
    printf "%s\n" \
    "Generate" \
    "----------------------------------------------------"

    ## Check for output directory, create it if it doesn't exist
    if [[ ! -d output ]]; then
            mkdir output
    fi

    ## RPM or DEB based distro, self-signed SSL filepath
	if [[ -e /usr/bin/dnf ]]; then
		apacheDir="/etc/httpd/"
	elif [[ -e /usr/bin/apt ]]; then
		apacheDir="/etc/apache2"
	else
		#### This message shouldn't be reachable with our configs and may suggest a more serious issue
		printf "%s\n" \
		"${red}ISSUE DETECTED - DNF/APT not found! "\
		"----------------------------------------------------" \
		"Script is for RPM/DEB servers only!${normal}"
		exit 1
	fi

    ## Private IP to variable, filter private IP of server
    privateIP=$(hostname -i | awk '{print $1}')

    ## Domain
	printf "%s\n" \
	"${yellow}Site Domain" \
	"----------------------------------------------------" \
	"Enter site domain to use:${normal}" \
	" "
    read siteDomain

    ## WWW Redirect?
	printf "%s\n" \
	"${yellow}" \
	"----------------------------------------------------" \
	"WWW redirect for domain?" \
	"Enter: 1 for yes or 2 for no${normal}" \
	" "
    read wwwredirect

    ## HTTP -> HTTPS?
	printf "%s\n" \
	"${yellow}" \
	"----------------------------------------------------" \
    "Redirect HTTP (port 80) traffic to HTTPS on (port 443)? " \
	"Enter: 1 for yes or 2 for no${normal}" \
	" "
    read httpredirect

    #TODO Change your output dir if desired
    ## Check for vhost with file name already, move to new name and disable old vhost if so
    if [[ -f output/$siteDomain.conf ]]; then
            mv output/$siteDomain.conf output/$siteDomain.$(date +%Y%m%d).conf
    fi

    ## Begin HTTP Virtualhost section
    ### If HTTP -> HTTPS = 1
    if [[ $httpredirect -eq "1" ]]; then
        echo "<VirtualHost $privateIP:80>" >> output/$siteDomain.conf
        echo "  ServerName $siteDomain" >> output/$siteDomain.conf

        #### If WWW Redirect = 1
        if [[ $wwwredirect -eq "1" ]]; then
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
    echo "" >> output/$siteDomain.conf
    #### If WWW Redirect = 1
    echo "" >> output/$siteDomain.conf

    ## Add options
    ### Explanation of options

    ## Error logging

    #TODO Replace with your own SSL if desired
    ## Self-signed SSL
    ### Created self-signed SSL directory based on RPM or DEB based distro

    #TODO Replace with your own protocols as needed
    ### SSL Protocols

    #TODO Replace with your own ciphers as desired

    ## Proxy Pass to another server?
	printf "%s\n" \
	"${yellow}" \
	"----------------------------------------------------" \
	" " \
	"Enter:${normal}" \
	" "
    read junkInput

    ## Create a docroot for domain?

    ## WordPress?
    ### WordPress upload directory
	printf "%s\n" \
	"${yellow}" \
	"----------------------------------------------------" \
	" " \
	"Enter: 1 for yes or 2 for no${normal}" \
	" "
    read junkInput

    #TODO Update your own security changes as needed
    ## File security
}

# Main, read passed flags
printf "%s\n" \
"Vhost Generator" \
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
    runProgram
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
