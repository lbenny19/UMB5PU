#!/usr/bin/bash

BASE_SHA=$1
HEAD_SHA=$2
COMMIT_MSG_CC=$3

SITE_FILE="./validation/site_cntl"
META_FILE="./metadata"
CHECKOWN_PATH="./hooks/owner_check"
VAL_DIR="./validation"
# ==============================================================================
# 1. RUNNER PATH & CONFIGURATION VERIFICATION
# ==============================================================================
echo "=== STARTING ZOWE CONFIGURATION VERIFICATION ==="

# Define the absolute target paths
TARGET_HOME="C:\\Users\\LBenny\\.zowe"
TARGET_CONFIG="C:\\Users\\LBenny\\.zowe\\zowe.config.json"

echo "Current Execution User Context:"
whoami

echo "Checking if Zowe Home Directory exists..."
if [ -d "$TARGET_HOME" ] || [ -d "/c/Users/LBenny/.zowe" ]; then
    echo "  [SUCCESS] Pipeline can see the .zowe folder structure."
else
    echo "  [FAILURE] Pipeline cannot resolve the path to the .zowe folder."
fi

echo "Checking read access to your real zowe.config.json..."
if [ -f "$TARGET_CONFIG" ] || [ -f "/c/Users/LBenny/.zowe/zowe.config.json" ]; then
    echo "  [SUCCESS] Pipeline found your real zowe.config.json file!"
    echo "  ----------------- CONFIG PREVIEW -----------------"
    # Print the first 15 lines of the config to verify the profile host details safely
    head -n 15 "/c/Users/LBenny/.zowe/zowe.config.json"
    echo "  --------------------------------------------------"
else
    echo "  [FATAL ERROR] Pipeline cannot locate or read your zowe.config.json file."
    echo "  Please verify that 'LBenny' matches your actual Windows user folder name."
    exit 1
fi

echo "=== VERIFICATION COMPLETE - SETTING RUNTIME ENVIRONMENT ==="

# Force the execution parameters to bind to your verified configuration paths
export ZOWE_CLI_TELEMETRY_OPTOUT=true
export ZOWE_CLI_HOME="$TARGET_HOME"
export ZOWE_CONFIG_FILE="$TARGET_CONFIG"

read_site_cntl()  {
    echo "site file: "$SITE_FILE""
    if [ -f "$SITE_FILE" ]; then
        echo "site exist"
    else
        echo "Site control file doesn't exist. Merge rejected."
        exit 1
    fi
    
    val_to_own=$(awk -F ':' -v val="VAL-CC-TO-APPL" '$1 == val {print substr($2, 1)}' $SITE_FILE)
    no_own_change=$(awk -F ':' -v val="PROHIBIT-OWNER-CHG" '$1 == val {print substr($2, 1)}' $SITE_FILE)
}

Filename_check()   {
    file_noext="${MFILE%.*}"
    if [ "${#file_noext}" -gt 8 ]; then
        echo "Filename '$MFILE' is longer than 8 characters. Merge rejected."
                exit 1
    fi

    echo ""
    if [[ $file_noext =~ ^[a-zA-Z0-9$#@]+$ ]]; then
        echo "Filename '$MFILE' contains only valid characters."
    else
        echo "Filename '$MFILE' is invalid. Module Name should can contain only Alphabet Letters, Numbers, or National Characters @#$ only. Merge rejected."
                exit 1
    fi

    echo ""
    if [[ $file_noext =~ ^[a-zA-Z] ]]; then
        echo "Filename '$MFILE' starts with an alphabet."
    else
        echo "Filename '$MFILE' is invalid. Module Name should start with an alphabet. Merge rejected."
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
		echo "Merge rejected."
		exit 1
	fi
}

echo "COMMIT_MSG_CC: $COMMIT_MSG_CC"
if ! echo "$COMMIT_MSG_CC" | grep -qE '^[0-9]+$'; then
    echo "Invalid commit message: CC must be numeric"
    exit 1
fi



read_site_cntl
metadata_content=$(cat "$META_FILE")

#Invalid_changes=$(git diff --name-only "$BASE_SHA" "$HEAD_SHA" | grep -E '^(hooks/|validation/)')
#echo "invalid: $Invalid_changes"
#if [[ -n "$Invalid_changes" ]]; then
#    echo "Changes to hooks or validation folder not allowed"
#	exit 1
#fi
Mfiles=$(git diff --name-status "$BASE_SHA" "$HEAD_SHA" | \
         grep -v '[[:space:]]validation/' | grep -v '[[:space:]]hooks/' | grep -v '[[:space:]]\.git*' | grep -v '[[:space:]]metadata' )   
META_CHANGES=$(git diff "$BASE_SHA" "$HEAD_SHA" -- "$META_FILE" | grep '^\+' | sed 's/^+//' | \
         grep -v '[[:space:]]validation/' | grep -v '[[:space:]]hooks/' | grep -v '[[:space:]]\.git*' | grep -v '[[:space:]]metadata' )
echo $META_CHANGES
echo "m: $Mfiles "
if [ -z "$Mfiles" ]; then
    echo "No source files changed. Exiting."
    exit 0
fi

ALL_CHANGED_FILES=$(git diff --name-only "$BASE_SHA" "$HEAD_SHA")

MFILE_CHANGES=$(git diff "$BASE_SHA" "$HEAD_SHA" -- "$META_FILE" | grep -E '^(\+|-)' | grep -vE '^(---|\+\+\+)')

if [[ -n "$MFILE_CHANGES" ]]; then
    while read -r line; do
        mod_name=$(echo "$line" | sed 's/^[+-]//' | awk -F';;' '{print $1}')
        
        if ! echo "$ALL_CHANGED_FILES" | grep -q "$mod_name"; then
            echo "Metadata entry for '$mod_name' has been modified, but no code changes were found for this module."
            exit 1
        fi
    done <<< "$MFILE_CHANGES"
fi


cc_check="N"
while IFS=$'/t' read -r M_MODE M_FILE; do
    MFILE=$(basename "$M_FILE")
    echo "mfile: $MFILE "
    Filename_check

    mod_exist=$(echo "$META_CHANGES" | awk -F ';;' -v val="$MFILE" '$1 == val ')
    echo "mod_exist : $mod_exist " 

    if [  -n "$mod_exist" ]; then
        pro_type=$(echo "$META_CHANGES" | awk -F ';;' -v val="$MFILE" '$1 == val {print substr($2, 1)}')
        
        if [[ ("$M_MODE" = "A" || "$M_MODE" = "M" ) &&  "$pro_type" = "DELETED" ]]; then
            echo "Modified or Added file $MFILE is deleted as per metadata file. Merge rejected."
            exit 1
        fi
        
        if [ "$M_MODE" = "D" ] && [ "$pro_type" != "DELETED" ]; then
            echo "Deleted file $MFILE is not deleted as per metadata file. Merge rejected."
            exit 1
        fi
        
        mown=$(echo "$metadata_content" | awk -F ';;' -v val="$MFILE" '$1 == val {print substr($6, 1)}' )
		mptype=$(echo "$metadata_content" | awk -F ';;' -v val="$MFILE" '$1 == val {print substr($2, 1)}' )
        mtype=$(echo "$metadata_content" | awk -F ';;' -v val="$MFILE" '$1 == val {print substr($3, 1)}' )
        mlang=$(echo "$metadata_content" | awk -F ';;' -v val="$MFILE" '$1 == val {print substr($4, 1)}' )

		chk_own=$(awk -F ':' -v val="$mown" '$2 == val '  "$VAL_DIR/owner_list")
        if [ -z "$chk_own" ]; then
            echo "Owner is not valid for $MFILE" 
		    exit 1
		fi

		chk_lang=$(awk -v val="$mlang" '$0 == val'  "$VAL_DIR/lang_list")
        if [ -z "$chk_lang" ]; then
            echo "Language is not valid for $MFILE" 
		    exit 1
		fi		
		
		chk_ptype=$(awk -F ';' -v val="$mptype" '$1 == val '  "$VAL_DIR/endv_type_list")
        if [[ -z "$chk_ptype" && "$mptype" != "DELETED" ]]; then
            echo "Processor type is not valid for $MFILE" 
		    exit 1
		fi

		TYPE_LIST="|PROGRAM|COPY BOOK|MACRO|JCL|TABLE|DATA|SUBROUTINE|ISPF|"

        if [[ ! "$TYPE_LIST" =~ "|$mtype|" ]]; then
            echo "Type is not valid for $MFILE"
            exit 1
        fi
		
        echo "mown: $mown"
        echo "val: $val_to_own"

        if [ "$cc_check" = 'N' ]; then
		    echo "DEBUG: Password length is ${#MF_PASSWORD} characters."
		    echo "Executing REXX check via Zowe..."
            RES=$(zowe zos-uss issue command "./cext.sh $COMMIT_MSG_CC; exit" --password="$MF_PASSWORD" --show-inputs-only )
            echo "RES: $RES"
            rm zowe.config.json
            read rcode stat ccown desc <<< "$RES"
            cc_check="Y"
            if [ "$stat" = 'C' ] ; then
                echo "$COMMIT_MSG_CC has already been closed. Merge rejected."
                exit 1
            fi
            if [ "$rcode" = 4 ] ; then
                echo "Could not get change control details. Merge rejected."
                exit 1
            fi			
		fi
        if [ "$val_to_own" = 'N' ]; then
            option=2
            echo "ccown: $ccown"
            result=$("$CHECKOWN_PATH" $option "$mown" "$ccown")
            echo "result: $result"
            if [ "$result" != "Y" ]; then
                echo "Ownership of $MFILE not compatible with CC. Merge rejected."
                exit 1
            fi
        fi
        
        if [ "$val_to_own" = 'Y' ]; then
            if [ "$ccown" != "$mown" ]; then
                echo "Ownership of $MFILE not compatible with CC. Merge rejected."
                exit 1
            fi
        fi
        
        if [ "$val_to_own" = 'X' ]; then
            if [ "$ccown" != '===' ]; then
                option=2
                result=$("$CHECKOWN_PATH" $option "$mown" "$ccown")
                if [ "$result" != "Y" ]; then
                    echo "Ownership of $MFILE not compatible with CC. Merge rejected."
                    exit 1
                fi
            else
                option=1
                result=$("$CHECKOWN_PATH" $option "$mown")
                if [ "$result" = 'UMB' ]; then
                    echo "Ownership of $MFILE not compatible with CC. Merge rejected."
                    exit 1
                fi
            fi
        fi
        Check_suffix
    else
        echo "Metadata entry not updated for module $MFILE. Merge rejected."
        exit 1
    fi
done <<< "$Mfiles"

echo "Validation successful!"
