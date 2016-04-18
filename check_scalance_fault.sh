#!/bin/sh
###########################################################################################
#                                                                                         #
# A plugin that uses SNMP to get error codes from a Siemens Scalance X300 or X400 switch. #
# The plugin outputs the fault in a human readable form,                                  #
# as long as there are not several faults.                                                #
#                                                                                         #
#                                                                                         #
# USAGE:                                                                                  #
# Add as a check in any Nagios compatible product with proper variables                   #
# The script expects either two variables for SNMPv2c or six variables for SNMPv3.        #
#                                                                                         #
# Version history:                                                                        #
# 1.1 2015-08-04 Cleaned up some minor ambiguities.                                       #
# 1.0 2014-10-27 Initial release. Tested with CentOS, Op5 and Scalance X300.              #
#                                                                                         #
# Written by Farid.Joubbi@consign.se                                                      #
###########################################################################################


if [ $# == 6 ]; then
  SNMPOPT="-v 3 -u $2 -a $3 -A $4 -l authPriv -x $5 -X $6 $1 -Ov -t 0.5 -Lo"
fi 

if [ $# == 2 ]; then
  SNMPOPT="-v 2c -c $2 $1 -Ov -t 0.5 -Lo"
fi

if [ $# != 2 ] && [ $# != 6 ]; then
  echo "Wrong amount of arguments!"
  echo
  echo "Usage:"
  echo "SNMPv2c: check_scalance_fault HOSTNAME community"
  echo "SNMPv3: check_scalance_fault HOSTNAME username MD5/SHA authpass DES/AES privpass"
  exit 3
fi



#Get the fault value and clean it up.
faultvalue=`/usr/bin/snmpget $SNMPOPT 1.3.6.1.4.1.4196.1.1.5.4.100.2.2.3.0 | /bin/sed -e 's/\STRING: //g' | /bin/sed -e 's/\"//g' | /bin/sed -e 's/\Hex-//g' | /bin/sed -e 's/\s*$//'`


# eveluate the fault value.
if [ "$faultvalue" == "00 00 00 00" ]; then
  echo "OK - No errors on this device."
  exit 0
fi
if [ "$faultvalue" == "00 00 00 01" ]; then
  echo "Power error!"
  exit 1
fi
if [ "$faultvalue" == "00 00 00 02" ]; then
  echo "Linkdown error!"
  exit 2
fi

if [ "$faultvalue" == "00 00 00 03" ]; then
  echo "Power error and Linkdown error!"
  exit 2
fi

if [ "$faultvalue" == "00 00 00 04" ]; then
  echo "Internal error!"
  exit 2
fi
if [ "$faultvalue" == "00 00 00 08" ]; then
  echo "Standby error!"
  exit 2
fi
if [ "$faultvalue" == "00 00 00 0f" ]; then
  echo "rm error!"
  exit 2
fi

if [ "$faultvalue" == "00 00 01 00" ]; then
  echo "observer error!"
  exit 2
fi
if [ "$faultvalue" == "00 00 02 00" ]; then
  echo "non-recoverable ring error!"
  exit 2
fi
if [ "$faultvalue" == "00 00 04 00" ]; then
  echo "c-plug error!"
  exit 2
fi
if [ "$faultvalue" == "00 00 08 00" ]; then
  echo "pnio error!"
  exit 2
fi
if [ "$faultvalue" == "00 00 0f 00" ]; then
  echo "module error!"
  exit 2
fi
if [ "$faultvalue" == "00 00 10 00" ]; then
  echo "loopd error!"
  exit 2
fi
if [ "$faultvalue" == "00 00 11 00" ]; then
  echo "Standby observer error!"
  exit 2
fi

echo "More than one error on device!"
echo ""Error code: $faultvalue""
exit 2

# Excerpt from the MIB-file:
#
#snX300X400FaultValue  OBJECT-TYPE
#    	SYNTAX  BITS 
#    	ACCESS  read-only
#    	STATUS  mandatory
#    	DESCRIPTION "Fault value:        0  = no fault,
#      		 		0. Octet LSB  	 bit 0   = power,
#      				0. Octet      	 bit 1   = linkdown,
#      				0. Octet      	 bit 2   = internal error,
#      				0. Octet      	 bit 3   = standby,
#      				0. Octet      	 bit 4   = rm,
#      				0. Octet      	 bit 5   = reserved,				
#      				0. Octet      	 bit 6   = reserved,				
#      				0. Octet MSB  	 bit 7   = reserved,				
#      				1. Octet LSB  	 bit 8   = reserved,   				
#				1. Octet 	 bit 9   = reserved,				
#				1. Octet 	 bit 10  = reserved,				
#				1. Octet 	 bit 11  = reserved,				
#				1. Octet 	 bit 12  = reserved,				
#				1. Octet 	 bit 13  = reserved,				
#				1. Octet 	 bit 14  = reserved,				
#      				1. Octet MSB  	 bit 15  = reserved,				
#      				2. Octet LSB  	 bit 16  = observer error,
#      				2. Octet      	 bit 17  = non-recoverable ring error,
#      				2. Octet      	 bit 18  = c-plug error,
#				2. Octet      	 bit 19  = pnio error,
#				2. Octet      	 bit 20  = module error,
#				2. Octet      	 bit 21  = loopd error,
#				2. Octet      	 bit 22  = standby observer error,
#				2. Octet MSB     bit 23  = reserved,
#				3. Octet LSB  	 bit 24  = reserved,
#      				3. Octet      	 bit 25  = reserved,
#      				3. Octet      	 bit 26  = reserved,
#				3. Octet      	 bit 27  = reserved,
#				3. Octet      	 bit 28  = reserved,
#				3. Octet      	 bit 29  = reserved,
#				3. Octet      	 bit 30  = reserved,
#				3. Octet MSB     bit 31  = reserved"
#        ::= { snX300X400Report 3 }

