# LG-DVD-REGION-RESET
Reset dvd player region setting for LG DVD GUD0N, GUD1N, GCC-4243N and probably others.

LG DVD players have secret SCSI commands to reset the region.
There are two different commands, the region can be changed on a drive for 5 times (or reset to "no region" for 4.
This is called "user reset" or "user change", then there is a vendor reset which resets the user reset counter back to five.
On GUD0N and GUD1N (and maybe all GT drives) the vendor reset can be executed an unlimited number of times.
In this repository you [will] find bash scripts or executable programs to accomplish that on different operative system.

Installation:

       $ git clone https://github.com/Zibri/LG-DVD-REGION-RESET.git
       $ cd LG-DVD-REGION-RESET
       $ chmod a+x rpcreset.sh
       $ ./rpcreset.sh --install

Note: this script works AS IS also on windows using CYGWIN!

Example usage:

       $ ./rpcreset.sh 
       User and Vendor reset for LG GUD*N drives.
       By Zibri.
       http://www.zibri.org
       Usage: ./rpcreset.sh [-u|-v|-r region] [-model modelname]
              ./rpcreset --install

       $ ./rpcreset.sh --install
       Program installed in /usr/local/sbin.

       $ rpcreset -i
       Drive is set to region: not set
       User resets left: 4
       User changes left: 5

See [rpcreset_example.txt](https://raw.githubusercontent.com/Zibri/LG-DVD-REGION-RESET/master/rpcreset_example.txt) for more examples.
