#!/bin/bash
#
# User and Vendor reset for LG GUD*N drives.
# By Zibri.
# http://www.zibri.org
#
unset regionmsk
unset rinq
bold=$(tput bold)
normal=$(tput sgr0)
dvdmodel="DVDRAM GU"
if [ "${1^^}" == "-U" ]; then
    scmd=81
else
    if [ "${1^^}" == "-V" ]; then
        scmd=80
    else
        if [ "${1^^}" == "-I" ]; then
            rinq="i"
        else
            if [ "${1^^}" == "-R" ]; then
                if [ "$2" -le "0" -o "$2" -ge "7" ]; then
                    echo "Region must be 1,2,3,4,5 or 6."
                    exit 1
                fi
                regionmask=$(printf "%X" $((255-2**(($2-1)))))
                shift
            else
                if [ "${1^^}" == "--INSTALL" ]; then
                    sudo cp rpcreset.sh /usr/local/sbin/rpcreset
                    chmod 755 /usr/local/sbin/rpcreset
                    echo "Program installed in /usr/local/sbin."
                    exit 0
                else
                    echo "User and Vendor reset for LG GU**N drives."
                    echo "By Zibri."
                    echo "http://www.zibri.org"
                    echo
                    echo "Usage: $0 [-u|-v|-r region] [-model modelname]"
                    echo "       $0 --install"
                    echo
                    exit 1
                fi
            fi
        fi
    fi
fi
if [ "${2^^}" == "-MODEL" ]; then
    dvdmodel="$3"
fi
if [[ $(uname -s) == *"inux"* ]]; then
    function checksg3 () 
    { 
        return $([ "" == "$(dpkg-query -W --showformat='${Status}\n' sg3-utils 2>/dev/null|grep installed)" ])
    }
    if checksg3; then
        echo "Installing pre-requisites."
        sudo apt-get install sg3-utils
    fi
else
    if [[ $(uname -s) == *"CYGWIN"* ]]; then
        function checksg3 () 
        { 
            return $([ "$(which sg_raw 2>/dev/null)" == "" ];)
        }
        if checksg3; then
            echo "Installing pre-requisites."
            wget "http://sg.danny.cz/sg/p/sg3_utils-1.42exe.zip" -O /tmp/sg.zip
            unzip /tmp/sg.zip -d /usr/local/bin/
            chmod a+x /usr/local/bin/sg_*
            rm /tmp/sg.zip
        fi
    fi
fi
sync
if checksg3; then
    echo "Can't download necessary files."
    exit 1
fi
if [[ $(uname -s) == *"inux"* ]]; then
    dvddev=$(sg_scan -i 2>/dev/null|grep -1 "$dvdmodel"|head -1|cut -d ":" -f 1)
else
    if [[ $(uname -s) == *"CYGWIN"* ]]; then
        dvddev=$(sg_scan 2>/dev/null|grep "$dvdmodel"|cut -d " " -f 1)
    fi
fi
if [ "" == "$dvddev" ]; then
    echo Device not found.
    exit 1
fi
function get_region () 
{ 
    regiondata=$(sg_raw -r 8 "$dvddev" A4 00 00 00 00 00 00 00 00 08 08 00 2>&1|grep "00 06"|cut -d " " -f 11,12)
    regionmask=$(echo "$regiondata"|cut -d " " -f 2)
    if [ "ff" == "$regionmask" ]; then
        region="not set"
    else
        region=$(echo "l($((255-16#$regionmask)))/l(2)+1" | bc -l | cut -d "." -f 1)
    fi
    umask=$(echo "$regiondata"|cut -d " " -f 1)
    echo Drive is set to region: "${bold}$region${normal}"
    ur=$(($((16#$umask))&7))
    vr=$(($((16#$umask))>>3))
    echo User resets left: "${bold}$((vr&7))${normal}"
    echo User changes left: "${bold}$ur${normal}"
    exit 0
}
if [ "i" == "$rinq" ]; then
    get_region
fi
if [ "" == "$regionmask" ]; then
    echo -ne "\x10\x00\x00\x00\x00\x00\x00\x00\x21\x02\x$scmd\x00" | sg_raw -s 12 "$dvddev" 55 00 00 00 00 00 00 00 0C 00 2> /dev/null
else
    echo -ne "\x00\x06\x00\x00\x$regionmask\x00\x00\x00" | sg_raw -s 8 "$dvddev" A3 00 00 00 00 00 00 00 00 08 06 00 2> /dev/null
fi
get_region
