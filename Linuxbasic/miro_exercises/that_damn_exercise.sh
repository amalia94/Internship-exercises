#!/bin/bash

#!/bin/bash
# bashcrc.sh        - see the attached files. The mentioned fields in bashcrc.txt are empty in bascrc.
#  Create a script that will search and replace the missing data from bashcrc with the correct
#  data from bashcrc.txt.
# (ARTIFACTORY_API_KEY, ARTIFACTORY_USER, ANDROID_HOME, JAVA_HOME, IVI_ADB_SERIAL)



grep 'ARTIFACTORY_API_KEY' bashcrc.txt >> bashcrc.sh
grep 'ARTIFACTORY_USER' bashcrc.txt >> bashcrc.sh
grep 'ANDROID_HOME' bashcrc.txt >> bashcrc.sh
grep 'JAVA_HOME' bashcrc.txt >> bashcrc.sh
grep 'IVI_ADB_SERIAL' bashcrc.txt >> bashcrc.sh
 
