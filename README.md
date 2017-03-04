# check_scalance_fault

A plugin that uses SNMP to get error codes from a __Siemens Scalance X300__ or __X400__ switch.
The plugin outputs the fault in a human readable form,
as long as there are not several faults.

The script reads the OID snX300X400FaultValue and outputs the fault.


### Faults reported by this script:

* Power error
* Linkdown error
* Power error and Linkdown error
* Internal error
* Standby error
* rm error
* observer error
* non-recoverable ring error
* c-plug error
* pnio error
* module error
* loopd error
* Standby observer error

If there are more than one fault, the script will output "More than one error on device!".


## USAGE
Add the script as a check in any Nagios compatible product with proper variables.

The script expects either two variables for __SNMPv2c__ or six variables for __SNMPv3__.

The variables are documented in the script.


## Version history
* 1.1 2015-08-04 Cleaned up some minor ambiguities.
* 1.0 2014-10-27 Initial release. Tested with CentOS, Op5 and Scalance X300. 


___

Licensed under the [__Apache License Version 2.0__](https://www.apache.org/licenses/LICENSE-2.0)

Written by __farid@joubbi.se__

http://www.joubbi.se/monitoring.html

