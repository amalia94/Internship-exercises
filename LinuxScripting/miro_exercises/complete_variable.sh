#!/bin/bash

#!/bin/bash
# bashcrc.sh        - see the attached files. The mentioned fields in bashcrc.txt are empty in bascrc.
#  Create a script that will search and replace the missing data from bashcrc with the correct
#  data from bashcrc.txt.
# (ARTIFACTORY_API_KEY, ARTIFACTORY_USER, ANDROID_HOME, JAVA_HOME, IVI_ADB_SERIAL)


VARS=("ARTIFACTORY_API_KEY"
    "ARTIFACTORY_USER"
    "ANDROID_HOME"
    "JAVA_HOME"
    "IVI_ADB_SERIAL")

SRC_FILE="bashcrc.txt"
DEST_FILE="bashcrc"


for var in "${VARS[@]}"; do
    value=$(grep "$var=" "$SRC_FILE" | cut -d '=' -f2)
    sed -i "s|^export $var=.*$|export $var=$value|" "$DEST_FILE"

done

