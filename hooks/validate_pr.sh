#!/usr/bin/bash

BASE_SHA=$1
HEAD_SHA=$2
COMMIT_MSG_CC=$3


SITE_FILE="./validation/site_cntl"
META_FILE="./metadata"
CHECKOWN_PATH="./hooks/owner_check"

read_site_cntl()  {
    echo "site file: "$SITE_FILE""
    if [ -f "$SITE_FILE" ]; then
        echo "site exist"
    else
        echo "Site control file doesn't exist. Push rejected."
        exit 1
    fi
    
    val_to_own=$(awk -F ':' -v val="VAL-CC-TO-APPL" '$1 == val {print substr($2, 1)}' $SITE_FILE)
    no_own_change=$(awk -F ':' -v val="PROHIBIT-OWNER-CHG" '$1 == val {print substr($2, 1)}' $SITE_FILE)
}

Filename_check()   {
    file_noext="${MFILE%.*}"
    if [ "${#file_noext}" -gt 8 ]; then
        echo "Filename '$MFILE' is longer than 8 characters. Push rejected."
                exit 1
    fi

    echo ""
    if [[ $file_noext =~ ^[a-zA-Z0-9$#@]+$ ]]; then
        echo "Filename '$MFILE' contains only valid characters."
    else
        echo "Filename '$MFILE' is invalid. Module Name should can contain only Alphabet Letters, Numbers, or National Characters @#$ only. Push rejected."
                exit 1
    fi

    echo ""
    if [[ $file_noext =~ ^[a-zA-Z] ]]; then
        echo "Filename '$MFILE' starts with an alphabet."
    else
        echo "Filename '$MFILE' is invalid. Module Name should start with an alphabet. Push rejected."
                exit 1
    fi
}

Check_suffix()   {
    file_noext="${MFILE%.*}"
    key="$mlang:$mtype"
	case "$key" in
	    "ASM:PROGRAM") extn=".asm" ;;
		"COB:PROGRAM") extn=".cbl" ;;
		"ASM:MACRO") extn=".mac" ;;
		"COB:MACRO") extn=".cpy" ;;
		"COB:COPY BOOK") extn=".cpy" ;;
		"IST:ISPF") extn=".itbl" ;;
		IST:*) extn=".tbl" ;;
		"ISS:ISPF") extn=".iskl" ;;
		ISS:*) extn=".skl" ;;
		"ISM:ISPF") extn=".imsg" ;;
		ISM:*) extn=".msg" ;;
		"ISP:ISPF") extn=".ipnl" ;;
		ISP:*) extn=".pnl" ;;
		IMS:*) extn=".ims" ;;	
		ISR:*) extn=".rexx" ;;
		ISC:*) extn=".clist" ;;
		CIC:*) extn=".cics" ;;
		*:JCL) extn=".jcl" ;;
		"DAT:DATA") extn=".dat" ;;
		*) extn="" ;;
	esac
		
    newfile="${file_noext}$extn"
	if [ "$MFILE" != "$newfile" ] || [ -z "$extn" ]; then
		echo "File extension for $file_noext incorrect."
		echo "Expected: $newfile  Found: $MFILE" 
		echo "Push rejected."
		exit 1
	fi
}

echo "COMMIT_MSG_CC: $COMMIT_MSG_CC"
if ! echo "$COMMIT_MSG_CC" | grep -qE '^[0-9]+$'; then
    echo "Invalid commit message: CC must be numeric"
    exit 1
fi

cat << EOF > zowe.config.json
{
    "\$schema": "https://zowe.github.io/docs-site/latest/schemas/zowe.config.json",
    "profiles": {
        "zosmf": {
            "type": "zosmf",
            "properties": {
                "host": "hog-mfrm-osa-vir.fsg.aus.csc.co",
                "port": 10443,
                "user": "Y01137",
                "rejectUnauthorized": false
            }
        }
    },
    "defaults": {
        "zosmf": "zosmf"
    }
}
EOF

echo "Executing REXX check via Zowe..."

RES=$(zowe zos-uss issue command "./cext.sh $COMMIT_MSG_CC; exit" --password="$MF_PASSWORD" | sed -n '3p')
echo "RES: $RES"

rm zowe.config.json
echo "Temporary configuration removed."

read rcode stat ccown desc <<< "$RES"

if [ "$stat" = 'C' ] ; then
    echo "$COMMIT_MSG_CC has already been closed. Push rejected."
    exit 1
fi
if [ "$rcode" = 4 ] ; then
    echo "Could not get change control details. Push rejected."
    exit 1
fi

read_site_cntl
metadata_content=$(cat "$META_FILE")

Mfiles=$(git diff --name-status "$BASE_SHA" "$HEAD_SHA" | \
         grep -v '[[:space:]]validation/' | grep -v '[[:space:]]hooks/' | grep -v '[[:space:]]\.git*' | grep -v '[[:space:]]metadata' )   
META_CHANGES=$(git diff "$BASE_SHA" "$HEAD_SHA" -- "$META_FILE" | grep '^\+')
echo $META_CHANGES
echo "m: $Mfiles "
if [ -z "$Mfiles" ]; then
    echo "No source files changed. Exiting."
    exit 0
fi

while IFS=$'/t' read -r M_MODE M_FILE; do
    MFILE=$(basename "$M_FILE")
    echo "mfile: $MFILE "
    Filename_check

    mod_exist=$(echo "$META_CHANGES" | awk -F ';;' -v val="$MFILE" '$1 == val ')
    echo "mod_exist : $mod_exist " 

    if [  -n "$mod_exist" ]; then
        pro_type=$(echo "$META_CHANGES" | awk -F ';;' -v val="$MFILE" '$1 == val {print substr($2, 1)}')
        
        if [[ ("$M_MODE" = "A" || "$M_MODE" = "M" ) &&  "$pro_type" = "DELETED" ]]; then
            echo "Modified or Added file $MFILE is deleted as per metadata file. Push rejected."
            exit 1
        fi
        
        if [ "$M_MODE" = "D" ] && [ "$pro_type" != "DELETED" ]; then
            echo "Deleted file $MFILE is not deleted as per metadata file. Push rejected."
            exit 1
        fi
        
        mown=$(echo "$metadata_content" | awk -F ';;' -v val="$MFILE" '$1 == val {print substr($6, 1)}' )
        mtype=$(echo "$metadata_content" | awk -F ';;' -v val="$MFILE" '$1 == val {print substr($3, 1)}' )
        mlang=$(echo "$metadata_content" | awk -F ';;' -v val="$MFILE" '$1 == val {print substr($4, 1)}' )
        
        echo "mown: $mown"
        echo "val: $val_to_own"
        
        # Local Ownership Logic
        if [ "$val_to_own" = 'N' ]; then
            option=2
            echo "ccown: $ccown"
            result=$("$CHECKOWN_PATH" $option "$mown" "$ccown")
            echo "result: $result"
            if [ "$result" != "Y" ]; then
                echo "Ownership of $MFILE not compatible with CC. Push rejected."
                exit 1
            fi
        fi
        
        if [ "$val_to_own" = 'Y' ]; then
            if [ "$ccown" != "$mown" ]; then
                echo "Ownership of $MFILE not compatible with CC. Push rejected."
                exit 1
            fi
        fi
        
        if [ "$val_to_own" = 'X' ]; then
            if [ "$ccown" != '===' ]; then
                option=2
                result=$("$CHECKOWN_PATH" $option "$mown" "$ccown")
                if [ "$result" != "Y" ]; then
                    echo "Ownership of $MFILE not compatible with CC. Push rejected."
                    exit 1
                fi
            else
                option=1
                result=$("$CHECKOWN_PATH" $option "$mown")
                if [ "$result" = 'UMB' ]; then
                    echo "Ownership of $MFILE not compatible with CC. Push rejected."
                    exit 1
                fi
            fi
        fi
        Check_suffix
    else
        echo "Metadata entry not updated for module $MFILE. Push rejected."
        exit 1
    fi
done <<< "$Mfiles"

echo "Validation successful!"
