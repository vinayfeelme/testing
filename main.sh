#!/bin/bash
#set -x
#export TMPDIR="/tmp"

# Record start time
START_TIME=$(date +%s)

# Basic color codes
RED='\033[0;31;1m'        # Red
GREEN='\033[0;32;1m'      # Green
YELLOW='\033[1;33;1m'     # Yellow
BLUE='\033[0;34;1m'       # Blue
MAGENTA='\033[0;35;1m'    # Magenta
CYAN='\033[0;36;1m'       # Cyan
RESET='\033[0m'         # Reset to default color

#Current Running SID Output Location: /tmp/sid.out
# Define the path to the source file
source_file="https://raw.githubusercontent.com/vinayfeelme/testing/config.txt"  # Replace with the actual path to your source file

# Check if the source file exists
if [ ! -f "$source_file" ]; then
    echo "Error: Source file $source_file not found. Please ensure the file exists."
    exit 1
fi

# If the source file exists, source it
source "$source_file"

#echo "Source file $source_file successfully sourced."
initial_dir=$(pwd)
echo $LOGS
DAT=$(date +'%d/%m/%Y')
DATE=$(date +'%d_%m_%Y_%H_%M_%S')
HOSTNAME=$(hostname)
LOGS=/tmp/Auto_Patch_log
rm -rf $LOGS
mkdir -p $LOGS
#from="hostname"
LOG_FILE=$LOGS/Patcing_${HOSTNAME}_${DATE}.log
SQL_SID_LISTS=$LOGS/running_sid_${DATE}.lck
SQL_SID_LISTS1=$LOGS/primary_sid_${DATE}.lck
SQL_SID_LISTS2=$LOGS/standby_sid_${DATE}.lck
ORA_HOME=$LOGS/ora_db_home_${DATE}.lck
TNS_LISTS=$LOGS/tns_${DATE}.lck
PATCH_LOCATION=$LOGS/PATCH_LOC.lck
email_file=$LOGS/sql_query_output.txt
# Clear the log file before writing new data
> "$LOG_FILE"
> "$SQL_SID_LISTS"
> "$SQL_SID_LISTS1"
> "$SQL_SID_LISTS2"
> "$ORA_HOME"
> "$TNS_LISTS"
> "$PATCH_LOCATION"
> "$email_file"

#############################################################################################################################################
#Block 1

{
echo
echo "                  *****************************************************************************************"
echo "                  *             Program Description : ORACLE DATABASE AUTO PATCHING SCRIPT                *"
echo "                  *                                                                                       *"
echo "                  *             Program Name:  Auto_Oracle_Patching.sh                                    *"
echo "                  *                     Date:  10/01/2025                                                 *"
echo "                  *                     Logs:  /tmp/Auto_Patch_log                                        *"
echo "                  *                  version:  V 1.1                                                      *"
echo "                  *                   Author:  SANDEEP KUMAR TOMAR                                        *"
echo "                  *             Return Codes:                                                             *"
echo "                  *                            0 - Success                                                *"
echo "                  *                            1 - Error check log file                                   *"
echo "                  *****************************************************************************************"
echo "                  *             MODIFICATION HISTORY                                                      *"
echo "                  *             --------------------                                                      *"
echo "                  *             VERSION     DATE           CHANGED BY      DESCRIPTION / PURPOSE          *"
echo "                  *             ---------   ----------     --------------  -------------------------------*"
echo "                  *             V 1.0       10/01/2025     SANDEEP TOMAR   Initial Version                *"
echo "                  *             V 1.1       20/01/2025     VINAY KUMAR     Updated Version                *"
echo "                  *                                                                                       *"
echo "                  *****************************************************************************************"
echo
} | tee -a $LOG_FILE


##########################################################################################################################
#Block 2

echo
echo
echo "###############################################################################################" | tee -a $LOG_FILE
echo


# Ask for user's name
echo -n -e "${CYAN}PLEASE ENTER YOUR NAME (You have 20 Sec): ${RESET}"
read -t 20 name

# Check if the user responded within 20 seconds
if [ -z "$name" ]; then
    echo "It can't be blank. OR No response received within 20 seconds. Exiting the automated patching script."
    exit 1
fi

# Convert the entered name to uppercase
name=$(echo "$name" | tr 'a-z' 'A-Z')

# Check if the entered name matches the allowed user
if [[ ! " ${allowed_user[@]} " =~ " ${name} " ]]; then
    echo "Sorry, $name. You are not authorized to run this script. Exiting."
    exit 1
fi

# If the user matches the allowed user, continue with the script
echo
echo "Welcome, $name! You are authorized to run this script."  | tee -a $LOG_FILE
# Add further code for patching or other operations here

echo
echo "###############################################################################################" | tee -a $LOG_FILE
echo
echo -n -e "${CYAN}HOPE YOU HAVE UPDATED CONFIGURATION FILE CORRECTLY IF NOT THEN PLEASE ADD CORRECT INFORMATION AND WELCOME BACK${RESET}" | tee -a $LOG_FILE
echo
echo
sleep 5

echo
echo "###############################################################################################" | tee -a $LOG_FILE
echo
echo -n -e "${CYAN}Do you want to continue automated patching script? (30 Sec) (yes/no): ${RESET}"
read -t 30 answer
echo
# Check if the user responded within 20 seconds
if [ -z "$answer" ]; then
    echo "No response received within 20 seconds. Exiting the automated patching script."
    exit 1
fi

answer=$(echo "$answer" | tr '[:upper:]' '[:lower:]')

# Check the user's response
if [[ "$answer" == "yes" || "$answer" == "y" ]]; then
echo
echo "Proceeding with the automated patching script..."
else
    echo "Exiting the automated patching script."
    exit 1
fi
echo


##########################################################################################################################
#Block 3

echo
echo "###############################################################################################" | tee -a $LOG_FILE
# Variables
# Ask for patch directory location
echo
echo -n -e "${CYAN}Please enter patch directory location(Directory should have 30GB free space): ${RESET}"
read PATCH_DIR
echo

# Check if there is at least 30 GB of free space in the directory
free_space=$(df "$PATCH_DIR" | tail -n 1 | awk '{print $4}')  # Get the available space in KB

# Convert 30 GB to KB (30 * 1024 * 1024 = 31457280 KB)
required_space=$((30 * 1024 * 1024))

free_space_gb=$((free_space / 1024 / 1024))
echo | tee -a $LOG_FILE
echo "Space available on the directory: $free_space_gb GB"  | tee -a $LOG_FILE
echo | tee -a $LOG_FILE

# Check if free space is less than the required space
if (( free_space < required_space )); then
  echo "Not enough space in $PATCH_DIR. At least 30 GB is required. Exiting..." | tee -a $LOG_FILE
  exit 1
fi

echo "Enough space is available in $PATCH_DIR." | tee -a $LOG_FILE
echo | tee -a $LOG_FILE

# Function that uses the global variable
function print_location  {
    echo "Your location is: $PATCH_DIR"
}

# Call the function to print the location
print_location 

echo "$PATCH_DIR " | tee -a $LOG_FILE &
echo "$PATCH_DIR" | tee -a $PATCH_LOCATION &
echo
wait 

echo "###############################################################################################" | tee -a $LOG_FILE
echo 
echo
echo -n -e "${CYAN}Enter Change No for Proceeding this Patching: ${RESET}"
read CHG_NO
echo "$CHG_NO" | tee -a $LOG_FILE
echo
echo
echo "###############################################################################################" | tee -a $LOG_FILE
echo 
echo -e "${CYAN}Pulling DB-RU/OJVM/JDK patches...${RESET}" | tee -a $LOG_FILE
# Ask the user if they want to proceed with downloading the patch
read -p "Do you want to proceed with downloading the patch? (yes/no): " response

# Convert the response to lowercase for case insensitivity
response=$(echo "$response" | tr '[:upper:]' '[:lower:]')

if [[ "$response" == "yes" ]]; then
    echo "Proceeding with patch download..."

    echo
	# Execute the inner script and show progress
	./pull_script.sh "$LOG_FILE" "$PATCH_DIR" "$LOGS" &  # Running the inner script in the background
	inner_pid=$!  # Capture the PID of the inner script
	
	# Display progress using dots while the script runs
	while kill -0 $inner_pid 2>/dev/null; do
	echo -n "." | tee -a $LOG_FILE
	sleep 1
	done
	
	echo " "  # Add a newline after the dots
	echo "Inner script has completed....." | tee -a $LOG_FILE
	echo

    if [[ $? -eq 0 ]]; then
        echo "Patch downloaded successfully!"
    else
        echo "Failed to download the patch."
        exit 1  # Exit if the download fails
    fi
else
    echo "Skipping patch download."
fi
echo
#######################################################################################################

echo "###############################################################################################" | tee -a $LOG_FILE
echo
echo "Verifying Patches are available or not on the $PATCH_DIR location...." | tee -a $LOG_FILE
echo

# Show dots every second for 10 seconds
for i in {1..10}; do
    echo -n "."
    sleep 1
done

echo ""  # Print a newline after the dots
echo
##Unzip DB Patch S/W
##COMBO_ZIP="p37262172_190000_Linux-x86-64.zip"
#RU_ZIP="p36912597_190000_Linux-x86-64.zip"                   # Replace with your OPatch zip file - Static
#OJVM_ZIP="p36878697_190000_Linux-x86-64.zip"                 # Replace with your OPatch zip file - Static
##JDK_ZIP="p37213431_190000_Linux-x86-64.zip"                 # Replace with your OPatch zip file - Static
##OPATCH_ZIP="p6880880_190000_Linux-x86-64.zip"                # Replace with your OPatch zip file - Static

# List of files to check
FILES=("$COMBO_ZIP" "$JDK_ZIP" "$OPATCH_ZIP")

# Iterate over the files and check if they exist in the Patch directory

for file in "${FILES[@]}"; do
  if [ -f "$PATCH_DIR/$file" ]; then
    echo  -n -e "${GREEN}Patch $file is found in the $PATCH_DIR directory. ${RESET}"
        echo
  else
    echo -n -e "${CYAN}Patch $file is NOT found in the $PATCH_DIR directory. Terminating the script${RESET}"
    echo
    echo
    exit 1
  fi
done

# Define global variables
RU="$PATCH_DIR/$COMBO_PATCH_DIR/$RU_PATCH_ID"
OJVM="$PATCH_DIR/$COMBO_PATCH_DIR/$OJVM_PATCH_ID"
JDK="$PATCH_DIR/$JDK_PATCH_ID"
echo
echo
# Function that uses the global variables
function print_patch_paths {
    echo "RU Patch Location: $RU"
    echo "OJVM Patch Location: $OJVM"
    echo "JDK Patch Location: $JDK"
}

# Call the function to print the patch paths
print_patch_paths

echo
echo "###############################################################################################" | tee -a $LOG_FILE
echo


echo "--------------------------------------------------------"
echo
echo -n -e "${CYAN}Auto Patch Logs are available on: ${RESET}"  $LOGS | tee -a $LOG_FILE
echo
echo
# Print the log file location
echo -n -e "${CYAN}Log file will be created at: ${RESET}" $LOG_FILE
echo
echo
sleep 5

##########################################################################################################################
#Block 4

echo
echo "###############################################################################################" | tee -a $LOG_FILE
echo

echo
echo -e "${CYAN}----------------------------------------------${RESET}" | tee -a $LOG_FILE
echo -e "${CYAN}Currently Running Database Environment Details${RESET}" | tee -a $LOG_FILE
echo -e "${CYAN}----------------------------------------------${RESET}" | tee -a $LOG_FILE
echo | tee -a $LOG_FILE

## ORACLE HOME Block

echo "Checking running Oracle Database and their Oracle Homes:" | tee -a $LOG_FILE
echo "--------------------------------------------------------" | tee -a $LOG_FILE
echo | tee -a $LOG_FILE

# Check if /etc/oratab file exists
if [ ! -f /etc/oratab ]; then
    echo "/etc/oratab file not found."
    exit 1
fi

# Loop through each line of /etc/oratab, ignoring comments and empty lines
grep -v -E '(^#|^$|^OEM|^OMS|^LISTENER|^AGENT|^Agent|^EMAgent|^ EMAgent)' /etc/oratab | while IFS=: read -r SID ORACLE_HOME _; do
    # Check if Oracle Home path exists
    if [ -d "$ORACLE_HOME" ]; then
	
        echo "Checking Oracle Home for SID '$SID'  =====> '$SID' : $ORACLE_HOME"
		#echo "$ORACLE_HOME" | tee -a $ORA_HOME
        # Set Oracle environment variables for the current Oracle Home
        export ORACLE_HOME
        export PATH=$ORACLE_HOME/bin:$PATH
        export ORACLE_SID=$SID

        # Check if the database is running using sqlplus (sysdba or other privileged user)
        db_status=$(sqlplus -S / as sysdba <<-EOF
                SET HEADING OFF;
                SET FEEDBACK OFF;
                SET PAGESIZE 0;
                SET LINESIZE 1000;
                SELECT STATUS FROM v\$instance;
                EXIT;
EOF
    )

        DB_ROLE=$(sqlplus -S / as sysdba <<-EOF
    SET HEADING OFF;
    SET FEEDBACK OFF;
    SET PAGESIZE 0;
    SET LINESIZE 1000;
    SELECT
    'DB_NAME: ' || d.NAME ||
    ' | DB_ROLE: ' || d.DATABASE_ROLE ||
    ' | DB_OPEN_MODE: ' || d.OPEN_MODE ||
    ' | DB_VERSION: ' || REGEXP_SUBSTR(p.VERSION_FULL, '^\d+\.\d+') AS DB_VERSION
FROM
    V\$DATABASE d,
    product_component_version p;
    EXIT;
EOF
    )
        # Check if sqlplus returned a valid result
        if [[ "$db_status" == "OPEN" ]]; then
           # echo "Database $SID is running."
            echo "SID: $SID -  $DB_ROLE"
            echo
        else
            echo "Database $SID is not running or could not be connected."
            echo
        fi
    else
        echo "Oracle Home for SID '$SID' does not exist: $ORACLE_HOME"
    fi
done


echo
echo

## LISTENER Block

# Check if the Oracle Listener process is running
listener_processes=$(ps -ef | grep '[t]nslsnr')

if [ -z "$listener_processes" ]; then
    echo "No Oracle Listener processes are running."
#    exit 
sleep 5
fi

# Loop through each listener process found
echo "Checking running Oracle Listeners and their Oracle Homes:"
echo "--------------------------------------------------------"
echo
# Loop over each running listener process
echo "$listener_processes" | while read -r process; do
    # Extract the PID
    pid=$(echo "$process" | awk '{print $2}')

    # Extract the listener name, which is the first argument in the command line (after tnslsnr)
    listener_name=$(echo "$process" | awk '{print $9}')  # Assuming listener name is the 8th field in ps output

    # Get the environment variables of the process (specifically, ORACLE_HOME)
    oracle_home=$(cat /proc/$pid/environ 2>/dev/null | tr '\0' '\n' | grep -i "ORACLE_HOME=" | cut -d= -f2)

    # Output the listener status and Oracle Home in the requiCYAN format
    if [ -n "$oracle_home" ]; then
        echo "Listener: $listener_name (PID $pid) is running. Oracle Home: $oracle_home"
    else
        echo "Listener: $listener_name (PID $pid) is running, but Oracle Home could not be determined."
    fi
done
sleep 5
echo
echo
echo


#############################################################################################################################################
#Block 7
echo
echo "###############################################################################################" | tee -a $LOG_FILE
echo   | tee -a $LOG_FILE


echo -e "${CYAN}----------------------------------------------------${RESET}"  | tee -a $LOG_FILE
echo -e "${CYAN}SET ORACLE_HOME/ENVIRONMENTS FOR PROCEEDING PATCHING${RESET}"  | tee -a $LOG_FILE
echo -e "${CYAN}----------------------------------------------------${RESET}"  | tee -a $LOG_FILE

# Ask for Oracle Home input
#echo -n -e "${CYAN}Enter the Oracle Home path (e.g., /u01/app/oracle/product/19.0.0/dbhome_1):${RESET} "   | tee -a $LOG_FILE
#read ORACLE_HOME
echo   | tee -a $LOG_FILE

# Step 1: Get a list of Oracle Home locations from /etc/oratab, excluding unwanted entries
oracle_homes=$(grep -v -E '(^#|^$|^OEM|^OMS|^LISTENER|^AGENT|^Agent|^EMAgent|^ EMAgent)' /etc/oratab | cut -d ':' -f 2 | sort -u)

# Step 2: Check if we have any Oracle Homes to process
if [[ -z "$oracle_homes" ]]; then
    echo "No valid Oracle Homes found in /etc/oratab." | tee -a "$LOG_FILE"
    exit 1
fi

# Step 3: Display the list of available Oracle Homes to the user
echo "Available Oracle Homes:" | tee -a "$LOG_FILE"
echo | tee -a "$LOG_FILE"
PS3="Please select the Oracle Home you want to proceed with: "
echo | tee -a "$LOG_FILE"
select oracle_home in $oracle_homes; do
    if [[ -n "$oracle_home" ]]; then
        echo "You have selected: $oracle_home" | tee -a "$LOG_FILE"
        break
    else
        echo "Invalid selection, please try again." | tee -a "$LOG_FILE"
    fi
done

# Proceed with your script using the selected Oracle Home (stored in $oracle_home)
echo | tee -a "$LOG_FILE"
echo "Proceeding with Oracle Home: $oracle_home" | tee -a "$LOG_FILE"

# Step 4: Check if the provided Oracle Home exists
if [ ! -d "$oracle_home" ]; then
    echo "The specified Oracle Home directory does not exist: $oracle_home" | tee -a "$LOG_FILE"
    exit 1
fi

# Set the environment variable ORACLE_HOME for the session
export ORACLE_HOME="$oracle_home"
export PATH="$ORACLE_HOME/bin:$PATH"

# Optional: Confirming the set environment variables
echo "ORACLE_HOME is set to: $ORACLE_HOME" | tee -a "$LOG_FILE"
export PATH=$ORACLE_HOME/bin:$PATH

# Find the SID(s) associated with this Oracle Home
echo   | tee -a $LOG_FILE
echo "Searching for SID(s) associated with Oracle Home: $ORACLE_HOME"   | tee -a $LOG_FILE
echo   | tee -a $LOG_FILE

# Check the ORACLE_SID from the environment (if it's set)
ORACLE_SID=$(echo $ORACLE_SID)

if [ -z "$ORACLE_SID" ]; then
    echo "ORACLE_SID environment variable is not set."  | tee -a $LOG_FILE
else
    echo "Current ORACLE_SID: $ORACLE_SID"  | tee -a $LOG_FILE
fi

# Check the oratab file for potential SID entries
if [ -f "/etc/oratab" ]; then
    echo
    echo "Looking for All SID(s) associated with ORACLE_HOME: $ORACLE_HOME"  | tee -a $LOG_FILE
    grep -i "$ORACLE_HOME" /etc/oratab | grep -viE "OEM|OMS|LISTENER|AGENT|Agent"  | awk -F: '{print $1}'
else
    echo "No oratab file found at /etc/oratab"  | tee -a $LOG_FILE
fi

# List running Oracle processes related to PMON (oracle instance processes)
echo  | tee -a $LOG_FILE
echo "Searching for running Oracle instances status with their Oracle Homes..."  | tee -a $LOG_FILE
echo   | tee -a $LOG_FILE
ps -ef | grep -v 'grep' | grep -i "ora_pmon" | while read -r process; do
    # Extract the PID (Process ID) of the process
    pid=$(echo "$process" | awk '{print $2}')

    # Extract the SID from the process name (i.e., ora_pmon_<SID>)
    sid=$(echo "$process" | awk '{print $8}' | cut -d'_' -f3)  # Extract the SID after "ora_pmon_"

    # Get the environment variables for the process (specifically ORACLE_HOME)
    oracle_home=$(cat /proc/$pid/environ 2>/dev/null | tr '\0' '\n' | grep -i "ORACLE_HOME=" | cut -d= -f2)

    # Display the Oracle SID and Oracle Home if it matches the input Oracle Home
    if [ -n "$oracle_home" ]; then
        if [ "$oracle_home" == "$ORACLE_HOME" ]; then
            echo "Oracle SID: $sid is running from Oracle Home: $oracle_home"   | tee -a $LOG_FILE
            echo "$sid" | tee -a $SQL_SID_LISTS
			echo
        fi
    else
        echo "Oracle SID: $sid is running, but ORACLE_HOME could not be determined."  | tee -a $LOG_FILE
    fi
done

PSID=$(head -n 1 $SQL_SID_LISTS)
#echo "oRACLE sid: "$PSID
export ORACLE_SID=$PSID
#echo $ORACLE_SID

# Check for running Listener related to the given ORACLE_HOME
echo
echo "Checking for running Listener(s) for Oracle Home: $ORACLE_HOME"  | tee -a $LOG_FILE
#ps -ef | grep -i "$ORACLE_HOME" | grep -i "tnslsnr" | awk '{print $9}'
TNSS=$(ps -ef | grep -i "$ORACLE_HOME" | grep -i "tnslsnr" | awk '{print $9}')
echo "$TNSS" | tee -a $TNS_LISTS

echo  | tee -a $LOG_FILE
echo -e "${CYAN}-----------------------------${RESET}"  | tee -a $LOG_FILE
echo -e "${CYAN}Environment Set in Background${RESET}"  | tee -a $LOG_FILE
echo -e "${CYAN}-----------------------------${RESET}"  | tee -a $LOG_FILE
echo
echo -e "ORACLE HOME: ${GREEN}$ORACLE_HOME${RESET}"  | tee -a $LOG_FILE
echo -e "ORACLE SID : ${GREEN}$ORACLE_SID${RESET}"  | tee -a $LOG_FILE
echo   | tee -a $LOG_FILE
sleep 5
echo
## Show dots every second for 20 seconds
#for i in {1..10}; do
#    echo -n "👉"
#    sleep 1
#done
#
#echo ""  # Print a newline after the dots

echo   | tee -a $LOG_FILE
echo "###############################################################################################" | tee -a $LOG_FILE
echo   | tee -a $LOG_FILE

echo -e "${CYAN}-----------------------------------${RESET}"  | tee -a $LOG_FILE
echo -e "${CYAN}COMPARING DATABASE RELEASE VERSIONS${RESET}"  | tee -a $LOG_FILE
echo -e "${CYAN}-----------------------------------${RESET}"  | tee -a $LOG_FILE
sleep 5

# Blcok for take release output
for ORACLE_SID in $(cat $SQL_SID_LISTS)
do
        # Log attempting to shut down the database
        echo
        echo "Checking database releases $ORACLE_SID ......" | tee -a $LOG_FILE
        echo
        # Export the ORACLE_SID for the current iteration
        export ORACLE_SID=$ORACLE_SID

        # Run the SQL*Plus command to shutdown the database
        DB_RELEASE=$(sqlplus -S / as sysdba <<-EOF
                SET HEADING OFF;
                SET FEEDBACK OFF;
                SET PAGESIZE 0;
                SET LINESIZE 1000;
                select VERSION_FULL from product_component_version;
                EXIT;
EOF
    )
        # Check if SQL*Plus command was successful
        if [ $? -eq 0 ]; then
                echo
                echo "Database $ORACLE_SID release found successfully" | tee -a $LOG_FILE
        else
                echo
                echo "Failed to connect database... $ORACLE_SID" | tee -a $LOG_FILE
                exit 1  # Exit the script if there is an error shutting down any database
        fi
                # Compare the releases
                if [[ "$DB_RELEASE" == "$PATCH_RELEASE" ]]; then
                        echo -e "${CYAN}DB_RELEASE${RESET} ($DB_RELEASE) is equal to ${CYAN}PATCH_RELEASE${RESET} ($PATCH_RELEASE). Terminating the program." | tee -a $LOG_FILE

echo
                        for i in {1..10}; do
    echo -n "."
    sleep 1
done

echo ""  # Print a newline after the dots
                        exit 0  # Exit the script as they are equal, terminating the process
                fi
        echo
                # If DB_RELEASE is greater than PATCH_RELEASE, exit as well
                if [[ "$DB_RELEASE" > "$PATCH_RELEASE" ]]; then
                    echo -e "${CYAN}DB_RELEASE${RESET} ($DB_RELEASE) is higher than ${CYAN}PATCH_RELEASE${RESET} ($PATCH_RELEASE). Terminating the program." | tee -a $LOG_FILE

                        echo
                        for i in {1..10}; do
    echo -n "."
    sleep 1
done

echo ""  # Print a newline after the dots
                        exit 0  # Exit the script as the DB version is higher than the patch release
                fi
        echo
                # If DB_RELEASE is less than PATCH_RELEASE, continue the process
    echo -e "${CYAN}DB_RELEASE${RESET} $DB_RELEASE is lower than ${CYAN}PATCH_RELEASE${RESET} $PATCH_RELEASE . Database are ready for patch. " | tee -a $LOG_FILE
echo
echo
echo "..............................................."
sleep 5
echo
done
echo


#############################################################################################################################################
#Block 9
echo
echo "###############################################################################################" | tee -a $LOG_FILE
echo   | tee -a $LOG_FILE



# Function to display the menu
display_menu() {
        echo -e "${CYAN}---------------------------------------------${RESET}"
		echo "Please select an option to perform: "
        echo "1. Take Database Prechecks [DB's shoule be up] "
        echo "2. Run Patch Conflicts "
        echo "3. Take DB Binary Backup "
		echo "4. Remove Inactive Patches from Oracle Home "
        echo "5. Start Implementing Blackout "
        echo "6. Bring down db & Start Database Patching       =>BLOCK FOR PATCHING"
        echo "7. Take Database Postchecks "
        echo "8. Stop Blackout "
		echo "9. Remove Inactive Patches from Oracle Home. Job will run in background "
        echo "10. Binary Cleanup "
        echo "11. Exit "
		echo -e "${CYAN}---------------------------------------------${RESET}"
    echo
}

# Loop until the user selects "Exit"
while true; do
    # Display the menu
    display_menu

    # Read user input
    read -p "Enter your choice (1-11): " USER_CHOICE 

    # Log the user choice
    #echo "User selected option: $USER_CHOICE" | tee -a $LOG_FILE



    # Perform actions based on user input using a case statement
    case $USER_CHOICE in
        1)
            echo
                        echo -e "${CYAN}--------------------------------------${RESET}" | tee -a $LOG_FILE
                        echo -e "${CYAN} YOU CHOSE TO TAKE DATABASE PRECHECKS ${RESET}" | tee -a $LOG_FILE
                        echo -e "${CYAN}--------------------------------------${RESET}" | tee -a $LOG_FILE
            echo
                        echo
           if [ ! -s "$SQL_SID_LISTS" ]; then
                echo "Error: $SQL_SID_LISTS is empty or does not exist." | tee -a $LOG_FILE
                exit 1  # Exit the script if no SID entries are found
           fi

               # Loop through each Oracle SID listed in /tmp/sid.out
               for ORACLE_SID in $(cat $SQL_SID_LISTS)
               do
                   # Export the ORACLE_SID variable
                   export ORACLE_SID=$ORACLE_SID

                   echo -e "${GREEN}DB Prechecks are running on $ORACLE_SID ....${RESET}" | tee -a $LOG_FILE
                   echo
cd "$initial_dir"
# Get the current working directory
current_dir=$(pwd)

# Print the current working directory
echo "Current working directory: $current_dir"
echo
                   # Run the SQL script and append output to the log file
                   #echo "@DB_Prechecks.sql" | sqlplus -S / as sysdba >> $LOG_FILE 2>&1
sqlplus -S / as sysdba @DB_Prechecks.sql >> $LOG_FILE 2>&1
echo "Spool file location: $LOGS Name: DB_Prechecks_$ORACLE_SID" | tee -a $LOG_FILE
echo | tee -a $LOG_FILE

                   # Check if SQL*Plus ran successfully
                   if [ $? -eq 0 ]; then
                       echo "Database $ORACLE_SID prechecks completed successfully" | tee -a $LOG_FILE
                   else
                       echo "Failed to run DB Prechecks for database $ORACLE_SID" | tee -a $LOG_FILE
                       exit 1  # Exit the script if there is an error
                   fi

                   echo

               done

               echo "All Oracle prechecks completed successfully." | tee -a $LOG_FILE
;;

        2)
            echo
            echo -e "${CYAN}-------------------------------------${RESET}" | tee -a $LOG_FILE
            echo -e "${CYAN} YOU CHOSE TO TO RUN PATCH CONFLICTS ${RESET}" | tee -a $LOG_FILE
            echo -e "${CYAN}-------------------------------------${RESET}" | tee -a $LOG_FILE
            echo
             
			 #Step 1
                                # Ensure the PATCH_DIR and OPATCH_ZIP variables are set
                                if [ ! -f "$PATCH_DIR/$OPATCH_ZIP" ]; then
                                    echo "Error: OPATCH Patch file not found in $PATCH_DIR/$PATCH_DIR" | tee -a $LOG_FILE
                                    exit 1
                                fi

                                # Ensure the ORACLE_HOME is set and exists
                                if [ ! -d "$ORACLE_HOME" ]; then
                                    echo "Error: ORACLE_HOME is not set or does not exist." | tee -a $LOG_FILE
                                    exit 1
                                fi

                                echo
                                echo "Opatch Upgrading...." | tee -a $LOG_FILE
                                echo
                                echo "Current OPATCH Version" | tee -a $LOG_FILE
                                echo

                                # Display the current OPatch version
                                $ORACLE_HOME/OPatch/opatch version | tee -a $LOG_FILE

                                echo
                                # Check if OPatch directory exists and move it to the old folder
                                if [ -d "$ORACLE_HOME/OPatch" ]; then
                                    echo "Moving OPatch directory to OPatch_OLD_$DATE..." | tee -a $LOG_FILE

                                    # Move OPatch to OPatch_OLD_<current_date>
                                    cd  $ORACLE_HOME
                                    #mv $ORACLE_HOME/OPatch "$ORACLE_HOME/OPatch_OLD_$DATE"
                                    rm -rf OPatch_OLD_$DATE
                                    mv OPatch $PATCH_DIR/OPatch_OLD_$DATE

                                    # Check if the move was successful
                                    if [ $? -eq 0 ]; then
                                        echo "OPatch has been successfully moved to OPatch_OLD_$DATE." | tee -a $LOG_FILE
                                    else
                                        echo "Failed to move OPatch to OPatch_OLD_$DATE." | tee -a $LOG_FILE
                                        exit 1  # Exit if the move operation fails
                                    fi
                                else
                                    echo "OPatch directory does not exist." | tee -a $LOG_FILE
                                    exit 1
                                fi

                                echo
                                echo "Unzipping OPATCH Software..." | tee -a $LOG_FILE
                                echo

                                # Unzip the patch software
                                (
                                        yes y | unzip -q "$PATCH_DIR/$OPATCH_ZIP" -d $ORACLE_HOME/ >> "$PATCH_DIR/opatch.txt" 2>&1 &

                                # Capture the PID of the unzip process
                                UNZIP_PID=$!

                                # Show progress while unzip is running
                                while kill -0 $UNZIP_PID 2>/dev/null; do
                                        echo -n "."  # Print dot without a new line
                                        sleep 1      # Sleep for 1 second (adjust if needed)
                                done

                                echo ""  # Move to the next line after progress dots
                                ) &

                                # Wait for the unzip process to finish
                                wait $UNZIP_PID

                                echo "OPATCH Unzip completed. Check the log at $LOG_FILE"
                                echo
                                # Exit the script

                                # Check if unzip was successful
                                if [ $? -eq 0 ]; then
                                    echo "OPatch software unzipped successfully." | tee -a $LOG_FILE
                                else
                                    echo "Error unzipping OPATCH software." | tee -a $LOG_FILE
                                    exit 1  # Exit if unzip fails
                                fi

                                echo
                                echo -e "${CYAN}OPATCH Version after Upgrade${RESET}" | tee -a $LOG_FILE
                                echo -e "${CYAN}----------------------------${RESET}"

                                # Display the new OPatch version
                                $ORACLE_HOME/OPatch/opatch version | tee -a $LOG_FILE

                                echo
                                echo
                                #Pasue
                                echo "Waiting for user to press Enter to proceed with patch conflict.."  | tee -a $LOG_FILE
                               # Wait for the user to press Enter
                                read -p "Press Enter to continue..."
			 
             # Step 2[A]: Checking RU patch conflict
             echo "Checking RU patch conflict..." | tee -a $LOG_FILE
			 echo
             cd $RU | tee -a $LOG_FILE
			 echo "Current directory $RU"
			 echo
            # Start the OPatch command in the background and show progress dots
 (
   # Run the OPatch command
   $ORACLE_HOME/OPatch/opatch prereq CheckConflictAgainstOHWithDetail -ph ./ >> $LOG_FILE 2>&1 &

   # Get the process ID of the OPatch process
   opatch_pid=$!

   # Display progress using dots
     count=0
     while kill -0 $opatch_pid 2>/dev/null; do
     echo -n "."  # Print a dot every second to show progress
     count=$((count + 1))  # Increment the counter
     if [ $count -eq 5 ]; then
         # Every 5 dots, print the time
         echo -n " $(date +'%H:%M:%S')"  # Print the current time
         count=0  # Reset the counter
     fi
     sleep 1
   done

   echo " "  # Add a newline after the dots
 ) &

 # Wait for the OPatch process to finish
 wait $opatch_pid

 # Print a new line to clean up the output
 echo ""


 # Check the exit status of the OPatch command and handle errors
 if [ $? -ne 0 ]; then
     echo "Error: There is a conflict with the patch. Aborting patching." | tee -a $LOG_FILE
     echo "FAILED: DB-RU patch conflict..." | tee -a $LOG_FILE
     exit 1
 fi

 # Success message
 echo "PASSED: DB-RU patch conflict..." | tee -a $LOG_FILE
 echo
 for i in {1..5}; do
     echo -n "."
     sleep 1
 done
echo
# echo ""  # Print a newline after the dots
# echo "20 seconds have passed."
# echo
# echo "Bye!!!" | tee -a $LOG_FILE

 echo
 echo "-----------------------------------------------------"
 echo

 # Step 2[B]: Checking OJVM patch conflict
 echo "Checking OJVM patch conflict..." | tee -a $LOG_FILE
 echo
 cd $OJVM | tee -a $LOG_FILE
 echo "Current directory $OJVM"
 echo
 # Start the OPatch command in the background and show progress dots
 (
   # Run the OPatch command
   $ORACLE_HOME/OPatch/opatch prereq CheckConflictAgainstOHWithDetail -ph ./ >> $LOG_FILE 2>&1 &

   # Get the process ID of the OPatch process
   opatch_pid=$!

   # Display progress using dots
     count=0
     while kill -0 $opatch_pid 2>/dev/null; do
     echo -n "."  # Print a dot every second to show progress
     count=$((count + 1))  # Increment the counter
     if [ $count -eq 5 ]; then
         # Every 5 dots, print the time
         echo -n " $(date +'%H:%M:%S')"  # Print the current time
         count=0  # Reset the counter
     fi
     sleep 1
   done

   echo " "  # Add a newline after the dots
 ) &

 # Wait for the OPatch process to finish
 wait $opatch_pid

 # Print a new line to clean up the output
 echo ""

 # Check the exit status of the OPatch command and handle errors
 if [ $? -ne 0 ]; then
     echo "Error: There is a conflict with the OJVM patch. Aborting patching." | tee -a $LOG_FILE
     echo "FAILED: OJVM patch conflict..." | tee -a $LOG_FILE
     exit 1
 fi

 # Success message
 echo "PASSED: OJVM patch conflict..." | tee -a $LOG_FILE
 echo
 for i in {1..5}; do
     echo -n "."
     sleep 1
 done
echo
 echo
 echo "-----------------------------------------------------"
 echo

 # Step 2[C]: Checking JDK patch conflict
 echo "Checking JDK patch conflict..." | tee -a $LOG_FILE
 echo
 cd $JDK  | tee -a $LOG_FILE
 echo "Current directory $JDK"
 echo
 # Start the OPatch command in the background and show progress dots
 (
   # Run the OPatch command
  $ORACLE_HOME/OPatch/opatch prereq CheckConflictAgainstOHWithDetail -ph ./ >> $LOG_FILE 2>&1 &

   # Get the process ID of the OPatch process
   opatch_pid=$!

   # Display progress using dots
     count=0
     while kill -0 $opatch_pid 2>/dev/null; do
     echo -n "."  # Print a dot every second to show progress
     count=$((count + 1))  # Increment the counter
     if [ $count -eq 5 ]; then
         # Every 5 dots, print the time
         echo -n " $(date +'%H:%M:%S')"  # Print the current time
         count=0  # Reset the counter
     fi
     sleep 1
   done

   echo " "  # Add a newline after the dots
 ) &

 # Wait for the OPatch process to finish
 wait $opatch_pid

 # Print a new line to clean up the output
 echo ""

 # Check the exit status of the OPatch command and handle errors
 if [ $? -ne 0 ]; then
     echo "Error: There is a conflict with the JDK patch. Aborting patching." | tee -a $LOG_FILE
     echo "FAILED: JDK patch conflict..." | tee -a $LOG_FILE
     exit 1
 fi

 # Success message
 echo "PASSED: JDK patch conflict..." | tee -a $LOG_FILE
 echo
 for i in {1..5}; do
     echo -n "."
     sleep 1
 done

 echo ""  # Print a newline after the dots

echo
;;
        3)
            echo
            echo -e "${CYAN}---------------------------------------------------${RESET}" | tee -a $LOG_FILE
            echo -e "${CYAN} YOU CHOSE TO RUN BINARY BACKUP ${RESET}" | tee -a $LOG_FILE
            echo -e "${CYAN}---------------------------------------------------${RESET}" | tee -a $LOG_FILE
                        echo
                                                
                               #Binary Backup Block
                                echo
                                echo "Proceeding with Binary Backkup...." | tee -a $LOG_FILE
                                echo
                                BACKUP_DIR=$PATCH_DIR
                                BACKUP_FILE="oracle_binary_backup_${ORACLE_SID}_${DATE}.tar"
                                BACKUP_ZIP_FILE="oracle_binary_backup_${ORACLE_SID}_${DATE}.tar.zip"
                               # Log the start time
							   echo
                                echo "Starting backup of Oracle binaries and data files at $(date)" >> "$BACKUP_DIR/backup_log.txt" | tee -a $LOG_FILE
                               # Step 1: Perform the backup using tar (includes $ORACLE_HOME and $ORACLE_DATA)
                                echo
                                echo "Tar Backup Inprogress............" | tee -a $LOG_FILE
                                echo
                                tar -cvf "$BACKUP_DIR/$BACKUP_FILE" "$ORACLE_HOME" >> "$BACKUP_DIR/backup_log.txt" 2>&1 &
                                TAR_PID=$!
                               # Show progress dots while tar is running
                                while kill -0 $TAR_PID 2>/dev/null; do
                                    echo -n "."  # print a dot without a newline
                                    sleep 1      # wait for 1 second before printing the next dot
                                done
                               # Once tar finishes, print a new line
                               echo
                               # Check if tar command finished successfully
                                wait $TAR_PID
                                if [ $? -eq 0 ]; then
                                    echo "tar backup completed successfully." >> "$BACKUP_DIR/backup_log.txt" | tee -a $LOG_FILE
                                else
                                    echo "tar backup failed!" >> "$BACKUP_DIR/backup_log.txt" | tee -a $LOG_FILE
                                    exit 1
                                fi
#                               # Step 2: Compress the tar file using zip
#                               #gzip -r "$BACKUP_DIR/$BACKUP_ZIP_FILE" "$BACKUP_DIR/$BACKUP_FILE" >> "$BACKUP_DIR/backup_log.txt" 2>&1
#                                echo
#                                echo "Zip creating for tar  Backup. Inprogress............" | tee -a $LOG_FILE
#                                echo
#                                gzip -r "$BACKUP_DIR/$BACKUP_ZIP_FILE" "$BACKUP_DIR/$BACKUP_FILE" >> "$BACKUP_DIR/backup_log.txt" 2>&1 &
#                                GZIP_PID=$!
#
#                                # Show progress dots while gzip is running
#                                while kill -0 $GZIP_PID 2>/dev/null; do
#                                    echo -n "."  # Print a dot without a newline
#                                    sleep 1      # Wait for 1 second before printing the next dot
#                                done
#
#                                # Once gzip finishes, print a new line
#                                echo
#
#                                # Wait for gzip to finish and check the result
#                                wait $GZIP_PID
#
#                                #if [ $? -eq 0 ]; then
#                                    echo "Backup has been compressed to: $BACKUP_DIR/$BACKUP_ZIP_FILE" >> "$BACKUP_DIR/backup_log.txt" | tee -a $LOG_FILE
#                                #else
#                                #    echo "Compression with zip failed!" >> "$BACKUP_DIR/backup_log.txt"
#                                #    exit 1
#                                #fi
#
#                                # Step 3: Clean up the tar file if zip was successful (optional)
#                                rm -f "$BACKUP_DIR/$BACKUP_FILE"
#                                echo "Tar file removed after compression." >> "$BACKUP_DIR/backup_log.txt" | tee -a $LOG_FILE
#
#                                # Log the end time
#                                echo "Backup finished at $(date)" >> "$BACKUP_DIR/backup_log.txt" | tee -a $LOG_FILE

                                echo
                                echo "Taking OPATCH LSINVENTORY Backup" | tee -a $LOG_FILE
                                echo
                                $ORACLE_HOME/OPatch/opatch lsinv >> $PATCH_DIR/Opatch_Inventory.txt
                                echo
                                echo "OPATCH LSINVENTORY Backup Completed!!!" | tee -a $LOG_FILE
                                echo

                                echo
                                echo "End of opatch upgrade and binary backup block" | tee -a $LOG_FILE
                                echo
                ;;
                4)
                        echo
                        echo -e "${CYAN}-------------------------------------------------------------------${RESET}" | tee -a $LOG_FILE
                        echo -e "${CYAN} YOU CHOSE TO START REMOVING INACTIVE PATCHES FROM THE ORACLE HOME ${RESET}" | tee -a $LOG_FILE
                        echo -e "${CYAN}-------------------------------------------------------------------${RESET}" | tee -a $LOG_FILE
                        echo
						# Step 1[A]: Listing Inactive Patches using OPatch
             echo "listing inactive patches..." | tee -a $LOG_FILE
			 echo
             {
			 $ORACLE_HOME/OPatch/opatch util listordeCYANinactivepatches >> $LOG_FILE 2>&1 &
			 
			    # Get the process ID of the OPatch process
   opatch_pid=$!

   # Display progress using dots
     count=0
     while kill -0 $opatch_pid 2>/dev/null; do
     echo -n "."  # Print a dot every second to show progress
     count=$((count + 1))  # Increment the counter
     if [ $count -eq 5 ]; then
         # Every 5 dots, print the time
         echo -n " $(date +'%H:%M:%S')"  # Print the current time
         count=0  # Reset the counter
     fi
     sleep 1
   done

   echo " "  # Add a newline after the dots
			 
			 } &
			 
			  # Wait for the OPatch process to finish
 wait $opatch_pid

 # Print a new line to clean up the output
 echo ""
             echo
                        echo "-----------------------------------------------------"
                        echo
             # Step 1[B]: Remove Inactive Patches using OPatch
             echo "Remore Inactive Patches..." | tee -a $LOG_FILE
			 echo
			 {
             $ORACLE_HOME/OPatch/opatch util deleteinactivepatches -silent >> $LOG_FILE 2>&1 &
			 #nohup $ORACLE_HOME/OPatch/opatch util deleteinactivepatches -silent >> $LOG_FILE 2>&1 &
			 # Get the process ID of the OPatch process
   opatch_pid=$!

   # Display progress using dots
     count=0
     while kill -0 $opatch_pid 2>/dev/null; do
     echo -n "."  # Print a dot every second to show progress
     count=$((count + 1))  # Increment the counter
     if [ $count -eq 5 ]; then
         # Every 5 dots, print the time
         echo -n " $(date +'%H:%M:%S')"  # Print the current time
         count=0  # Reset the counter
     fi
     sleep 1
   done

   echo " "  # Add a newline after the dots
			 } &
			 # Wait for the OPatch process to finish
 wait $opatch_pid

 # Print a new line to clean up the output
 echo ""
             echo
                        echo "Inactive Patches removed...."
                        echo
						
				;;
				5)
                        echo
                        echo -e "${CYAN}------------------------------------------------------------------${RESET}" | tee -a $LOG_FILE
                        echo -e "${CYAN} YOU CHOSE TO START IMPLEMENTING BLACKOUT ON EM AGENT AND CRONJOB ${RESET}" | tee -a $LOG_FILE
                        echo -e "${CYAN}------------------------------------------------------------------${RESET}" | tee -a $LOG_FILE
                        echo
                        echo  "Implementing Blackout on EM Agent......" | tee -a $LOG_FILE
                        echo

                        # Extract the directory path of the EM agent location from the command line of the process
                        EMAGENT_LOCATION=$(grep -iE "EM_Agent|AGENT|Agent" /etc/oratab | awk -F: '{print $2}')
                        echo -n "EM Agent Home Location in ORATAB : $EMAGENT_LOCATION" | tee -a $LOG_FILE
                        echo
                        # Check if the location is found
                        if [[ -z "$EMAGENT_LOCATION" ]]; then
                            echo "Unable to extract the Oracle EM Agent location." | tee -a $LOG_FILE
                            exit 1
                        fi
						echo
                        # Print the location
                        echo -n -e "${CYAN}Oracle Enterprise Manager Agent is located at: ${RESET}$EMAGENT_LOCATION" | tee -a $LOG_FILE
                        echo
                                                echo

                        # Prompt for blackout hours
                        echo -n -e "${CYAN}Enter EM Agent Blackout Name: ${RESET}" | tee -a $LOG_FILE
                        read BLACKOUT_NAME
                        echo


                        # Prompt for blackout hours
                        echo -n -e "${CYAN}Enter EM Agent Blackout Hours [1-6 Hours]: ${RESET}" | tee -a $LOG_FILE
                        read BLACKOUT_HOURS
                        echo

                        # Validate the enteCYAN blackout hours (must be an integer between 1 and 6)
                        if [[ ! "$BLACKOUT_HOURS" =~ ^[1-6]$ ]]; then
                            echo -e "${CYAN}Invalid input. Please enter a number between 1 and 6 for the blackout hours.${RESET}" | tee -a $LOG_FILE
                            exit 1
                        fi

                        # Calculate blackout minutes (blackout hours * 60)
                        BLACKOUT_MINUTES=$((BLACKOUT_HOURS * 60))

                        # Print the calculated blackout minutes
                        echo "Blackout period in minutes: $BLACKOUT_MINUTES minutes." | tee -a $LOG_FILE

                        # Start the EM agent blackout
                        echo "Starting Oracle Enterprise Manager Agent blackout..." | tee -a $LOG_FILE
                        echo
                        echo "EMAgent Blackout Status.." | tee -a $LOG_FILE
                        $EMAGENT_LOCATION/bin/emctl status blackout | tee -a $LOG_FILE
                        echo

                        echo "Start EMAgent Blackout.." | tee -a $LOG_FILE
                        $EMAGENT_LOCATION/bin/emctl start blackout $BLACKOUT_NAME -nodeLevel -d $BLACKOUT_MINUTES | tee -a $LOG_FILE
                        echo

                        echo "EMAgent Blackout Status.." | tee -a $LOG_FILE
                        $EMAGENT_LOCATION/bin/emctl status blackout | tee -a $LOG_FILE
                        echo

                        echo "Stop EMAgent.." | tee -a $LOG_FILE
                        $EMAGENT_LOCATION/bin/emctl stop agent | tee -a $LOG_FILE
                        echo

                        echo "EMAgent Status.." | tee -a $LOG_FILE
                        $EMAGENT_LOCATION/bin/emctl status agent | tee -a $LOG_FILE
                        echo

                        # Check if the blackout command was successful
                        if [ $? -eq 0 ]; then
                            echo "Oracle Enterprise Manager Agent has been successfully blacked out for $BLACKOUT_HOURS hours/$BLACKOUT_MINUTES minutes." | tee -a $LOG_FILE
                        else
                            echo -e "${CYAN}Failed to start the blackout. Please check the EM Agent logs.${RESET}" | tee -a $LOG_FILE
                            exit 1
                        fi

                        echo
                        echo "-----------------------------------------------------" | tee -a $LOG_FILE
                        echo
                        echo "Commenting out all cron jobs....." | tee -a $LOG_FILE
                        echo
                        # Get the current user's crontab
                        crontab -l | tee -a $LOG_FILE
                        crontab -l > current_cron

                        # Comment out every line
                        sed -i 's/^/##AUTOPATCHING##/' current_cron

                        # Install the modified crontab
                        crontab current_cron

                        # Clean up
                        rm current_cron
                        crontab -l | tee -a $LOG_FILE
                        echo "All cron jobs commented out." | tee -a $LOG_FILE

                        echo
                        echo "-----------------------------------------------------" | tee -a $LOG_FILE
                        echo
                                ;;
        6)
            echo
                        echo -e "${CYAN}------------------------------------------${RESET}" | tee -a $LOG_FILE
                        echo -e "${CYAN} YOU CHOSE TO START THE DATABASE PATCHING ${RESET}" | tee -a $LOG_FILE
                        echo -e "${CYAN}------------------------------------------${RESET}" | tee -a $LOG_FILE
                        echo
                        #Bringing down listener
                        echo "Bringing down listener: $TNSS ...." | tee -a $LOG_FILE

                        lsnrctl stop $TNSS | tee -a $LOG_FILE

                        echo
                        echo "listener stopped...." | tee -a $LOG_FILE
                        echo

                            # Assuming ORACLE_SID is already set for each SID
                        for ORACLE_SID in $(cat $SQL_SID_LISTS)
                        do
                            export ORACLE_SID=$ORACLE_SID
                            echo "Checking the role for database $ORACLE_SID ..." | tee -a $LOG_FILE

                            # Run SQL*Plus to get the database role
                            ROLE=$(echo "SELECT DATABASE_ROLE FROM V\$DATABASE;" | $ORACLE_HOME/bin/sqlplus -s / as sysdba)

                            # Check the role of the database
                            if [[ $ROLE == *"PRIMARY"* ]]; then
                                echo "Database $ORACLE_SID is the Primary database."  | tee -a $LOG_FILE
                                echo "$ORACLE_SID" | tee -a $SQL_SID_LISTS1
                                echo
                            elif [[ $ROLE == *"PHYSICAL STANDBY"* ]]; then
                                echo "Database $ORACLE_SID is the Standby database. " | tee -a $LOG_FILE
                                echo "$ORACLE_SID" | tee -a $SQL_SID_LISTS2                                
                            else
                                echo "Could not determine the role of database $ORACLE_SID." | tee -a $LOG_FILE
                            fi
                        done
                    echo
                        # Loop through each Oracle SID listed in /tmp/sid.out
                        for ORACLE_SID in $(cat $SQL_SID_LISTS)
                        do
                                # Log attempting to shut down the database
                                                                echo
                                echo "Attempting to shut down database $ORACLE_SID" | tee -a $LOG_FILE

                                # Export the ORACLE_SID for the current iteration
                                export ORACLE_SID=$ORACLE_SID

                                # Log the shutdown action
                                echo "Shutting down $ORACLE_SID..." | tee -a $LOG_FILE

                                # Run the SQL*Plus command to shutdown the database
                                $ORACLE_HOME/bin/sqlplus -s / as sysdba <<-EOF
                                shutdown immediate;
                                exit;
EOF

                                # Check if SQL*Plus command was successful
                                if [ $? -eq 0 ]; then
                                        echo
                                        echo "Database $ORACLE_SID shut down successfully" | tee -a $LOG_FILE
                                else
                                        echo "Failed to shut down database $ORACLE_SID" | tee -a $LOG_FILE
                                        exit 1  # Exit the script if there is an error shutting down any database
                                fi
                        done

                        # Final message
                        echo "All DB shutdown tasks completed." | tee -a $LOG_FILE

                        #Patching Steps
                        echo "Proceeding with Patching...." | tee -a $LOG_FILE

echo
echo "-----------------------------------------------------" | tee -a $LOG_FILE
echo


# Step 1: Apply the RU patch using OPatch
echo
echo -n -e "${CYAN}Waiting for user to press Enter for proceeding DB-RU patching....${RESET}"  | tee -a $LOG_FILE
# Wait for the user to press Enter
read -p "Press Enter to continue..."
echo
cd $RU || { echo "Error: Unable to change directory to $RU"; exit 1; }

# Log the current directory
echo "Current directory: $RU" | tee -a $LOG_FILE
echo
echo "Applying DB-RU patch..." | tee -a $LOG_FILE

# Run the OPatch apply command in the background
$ORACLE_HOME/OPatch/opatch apply -silent >> $LOG_FILE 2>&1 &

# Get the process ID of OPatch
OPATCH_PID=$!

# Show progress with '.' every second while OPatch is running
while kill -0 $OPATCH_PID 2>/dev/null; do
    # Print a dot every second to show that the process is still running
    echo -n "."
    sleep 1
done

# Check if OPatch applied successfully
wait $OPATCH_PID  # Wait for OPatch to finish and capture exit status

# Check the exit status of the OPatch command
if [ $? -ne 0 ]; then
    # If OPatch fails, prompt the user to resolve the issue
    echo -e "\n\nDB-RU patch apply failed. Please resolve the issues and rerun the script."
    echo "Do you want to continue troubleshooting and rerun OPatch? (y/n): "
    read user_response

    # If the user wants to rerun the OPatch
    if [ "$user_response" == "y" ]; then
        echo "Rerunning OPatch..."
        $ORACLE_HOME/OPatch/opatch apply -silent >> $LOG_FILE 2>&1
        
        # Check again after rerunning
        if [ $? -ne 0 ]; then
            echo "DB-RU patch apply failed again. Please resolve the issue manually and rerun."
            exit 1  # Exit script with error if OPatch still fails
        else
            echo "DB-RU patch applied successfully on the second attempt!"
        fi
    else
        echo "Please resolve the issue manually and rerun the script later."
        exit 1  # Exit script if user doesn't want to proceed
    fi
else
    echo -e "\n\nDB-RU patch applied successfully!"
fi
echo
# Success message
echo "DB-RU patching successfully completed..." | tee -a $LOG_FILE
sleep 5
echo
echo
echo "-----------------------------------------------------" | tee -a $LOG_FILE
echo

# Step 2: Apply the OJVM patch using OPatch
echo
echo -n -e "${CYAN}Waiting for user to press Enter for proceeding OJVM patching....${RESET}"  | tee -a $LOG_FILE
# Wait for the user to press Enter
read -p "Press Enter to continue..."
echo

echo "Applying patch $PATCH_DIR/$COMBO_PATCH_DIR/$OJVM_PATCH_ID..." | tee -a $LOG_FILE

cd $OJVM || { echo "Error: Unable to change directory to $OJVM"; exit 1; }

# Log the current directory
echo "Current directory: $OJVM" | tee -a $LOG_FILE
echo

echo "Applying OJVM patch..." | tee -a $LOG_FILE

$ORACLE_HOME/OPatch/opatch apply -silent >> $LOG_FILE 2>&1 &

# Get the process ID of OPatch
OPATCH_PID=$!

# Show progress with '.' every second while OPatch is running
while kill -0 $OPATCH_PID 2>/dev/null; do
    # Print a dot every second to show that the process is still running
    echo -n "."
    sleep 1
done

# Check if OPatch applied successfully
wait $OPATCH_PID  # Wait for OPatch to finish and capture exit status

# Check the exit status of the OPatch command
if [ $? -ne 0 ]; then
    # If OPatch fails, prompt the user to resolve the issue
    echo -e "\n\nOJVM patch apply failed. Please resolve the issues and rerun the script."
    echo "Do you want to continue troubleshooting and rerun OPatch? (y/n): "
    read user_response

    # If the user wants to rerun the OPatch
    if [ "$user_response" == "y" ]; then
        echo "Rerunning OPatch..."
       $ORACLE_HOME/OPatch/opatch apply -silent >> $LOG_FILE 2>&1
 
        # Check again after rerunning
        if [ $? -ne 0 ]; then
            echo "OJVM patch apply failed again. Please resolve the issue manually and rerun."
            exit 1  # Exit script with error if OPatch still fails
        else
            echo "OJVM patch applied successfully on the second attempt!"
        fi
    else
        echo "Please resolve the issue manually and rerun the script later."
        exit 1  # Exit script if user doesn't want to proceed
    fi
else
    echo -e "\n\nOJVM patch applied successfully!"
fi
echo
# Success message
echo "OJVM patching successfully completed..." | tee -a $LOG_FILE
echo
sleep 5
echo
echo "-----------------------------------------------------" | tee -a $LOG_FILE
echo

# Step 3: Apply the JDK patch using OPatch
echo
echo -n -e "${CYAN}Waiting for user to press Enter for proceeding JDK patching....${RESET}"  | tee -a $LOG_FILE
# Wait for the user to press Enter
read -p "Press Enter to continue..."
echo

echo "Applying patch $PATCH_DIR/$JDK_PATCH_ID..." | tee -a $LOG_FILE
echo
cd $JDK || { echo "Error: Unable to change directory to $JDK"; exit 1; }
echo
# Log the current directory
echo "Current directory: $JDK" | tee -a $LOG_FILE
echo


echo "Applying JDK patch..." | tee -a $LOG_FILE
#Pasue
echo
$ORACLE_HOME/OPatch/opatch apply -silent >> $LOG_FILE 2>&1 &

# Get the process ID of OPatch
OPATCH_PID=$!

# Show progress with '.' every second while OPatch is running
while kill -0 $OPATCH_PID 2>/dev/null; do
    # Print a dot every second to show that the process is still running
    echo -n "."
    sleep 1
done

# Check if OPatch applied successfully
wait $OPATCH_PID  # Wait for OPatch to finish and capture exit status

# Check the exit status of the OPatch command
if [ $? -ne 0 ]; then
    # If OPatch fails, prompt the user to resolve the issue
    echo -e "\n\nJDK patch apply failed. Please resolve the issues and rerun the script."
    echo "Do you want to continue troubleshooting and rerun OPatch? (y/n): "
    read user_response

    # If the user wants to rerun the OPatch
    if [ "$user_response" == "y" ]; then
        echo "Rerunning OPatch..."
       $ORACLE_HOME/OPatch/opatch apply -silent >> $LOG_FILE 2>&1
 
        # Check again after rerunning
        if [ $? -ne 0 ]; then
            echo "JDK patch apply failed again. Please resolve the issue manually and rerun."
            exit 1  # Exit script with error if OPatch still fails
        else
            echo "JDK patch applied successfully on the second attempt!"
        fi
    else
        echo "Please resolve the issue manually and rerun the script later."
        exit 1  # Exit script if user doesn't want to proceed
    fi
else
    echo -e "\n\nJDK patch applied successfully!"
fi

# Success message
echo "JDK patching successfully completed..." | tee -a $LOG_FILE
echo
sleep 5
echo
echo "-----------------------------------------------------" | tee -a $LOG_FILE
echo
echo "Applied Patch Information" | tee -a $LOG_FILE
$ORACLE_HOME/OPatch/opatch lsinv|grep -i applied | tee -a $LOG_FILE
echo
echo "Kindly Match Patch..." | tee -a $LOG_FILE
echo
echo "-----------------------------------------------------" | tee -a $LOG_FILE
echo
echo -n -e "${CYAN}Are we applied correct patch?  If YES the good to proceed, If NO the exit from the script and reapply patches. (yes/no): ${RESET}"
read answer

answer=$(echo "$answer" | tr '[:upper:]' '[:lower:]')

# Check the user's response
if [[ "$answer" == "yes" || "$answer" == "y" ]]; then
echo "Proceeding for the DB starup..."
else
    echo "Exiting the automated patching script."
    exit 1
fi


#PRIMARY DB Startup
# Loop through each Oracle SID listed in /tmp/sid.out
for ORACLE_SID in $(cat $SQL_SID_LISTS1)
do
        # Log attempting to startup  the database
                                        echo
        echo "Attempting to startup database $ORACLE_SID" | tee -a $LOG_FILE

        # Export the ORACLE_SID for the current iteration
        export ORACLE_SID=$ORACLE_SID

        # Log the shutdown action
        echo "Starting up $ORACLE_SID..." | tee -a $LOG_FILE

        # Run the SQL*Plus command to shutdown the database
        $ORACLE_HOME/bin/sqlplus -s / as sysdba <<-EOF
        startup;
        exit;
EOF
echo
# Run SQL*Plus to get the database role
ROLE1=$(echo "SELECT DATABASE_ROLE FROM V\$DATABASE;" | $ORACLE_HOME/bin/sqlplus -s / as sysdba)

        if [ $? -eq 0 ]; then
                echo
                echo "Database $ORACLE_SID startup successfully" | tee -a $LOG_FILE
        else
                echo
                echo "Failed to start database... $ORACLE_SID" | tee -a $LOG_FILE
                exit 1  # Exit the script if there is an error shutting down any database
        fi

# Final message
echo "DB $ORACLE_SID started in $ROLE1 role..." | tee -a $LOG_FILE
echo
echo "-----------------------------------------------------" | tee -a $LOG_FILE
echo
echo -n -e "${CYAN}Waiting for user to press Enter for running Post Patch Steps on $ORACLE_SID..${RESET}"  | tee -a $LOG_FILE
# Wait for the user to press Enter
read -p "Press Enter to continue..."
echo
echo "Proceeding with Post Patch Steps" | tee -a $LOG_FILE
echo
echo "Database Verbose Running on $ORACLE_SID...." | tee -a $LOG_FILE

$ORACLE_HOME/OPatch/datapatch -verbose | tee -a $LOG_FILE

if [ $? -eq 0 ]; then
    echo
    echo "Datapatch Verbose successfully completed!!!" | tee -a $LOG_FILE
else
    echo "Datapatch Verbose Failed. Listener also down!!!" | tee -a $LOG_FILE
    exit 1  # Exit the script
fi

echo
echo "-----------------------------------------------------" | tee -a $LOG_FILE
echo
echo -n -e "${CYAN}Waiting for user to press Enter for Running utlrp on $ORACLE_SID..${RESET}"  | tee -a $LOG_FILE
# Wait for the user to press Enter
read -p "Press Enter to continue..."
echo
echo "Running utlrp.sql on $ORACLE_SID" | tee -a $LOG_FILE

# Run utlrp on the database
$ORACLE_HOME/bin/sqlplus -s / as sysdba <<EOF
@$ORACLE_HOME/rdbms/admin/utlrp.sql
exit;
EOF

# Check if SQL*Plus command was successful
if [ $? -eq 0 ]; then
                                                echo
        echo "UTLRP successfully completed on $ORACLE_SID database" | tee -a $LOG_FILE
else
        echo "Failed to apply utlrp on $ORACLE_SID database" | tee -a $LOG_FILE
        exit 1  # Exit the script if there is an error shutting down any database
fi
done
echo
echo "......................................."
echo

#STANDBY DB Startup
# Loop through each Oracle SID listed in /tmp/sid.out
for ORACLE_SID in $(cat $SQL_SID_LISTS2)
do
        # Log attempting to startup  the database
                                        echo
        echo "Attempting to startup database $ORACLE_SID" | tee -a $LOG_FILE

        # Export the ORACLE_SID for the current iteration
        export ORACLE_SID=$ORACLE_SID

        # Log the shutdown action
        echo "Starting up $ORACLE_SID..." | tee -a $LOG_FILE

        # Run the SQL*Plus command to shutdown the database
        $ORACLE_HOME/bin/sqlplus -s / as sysdba <<-EOF
        startup mount;
		ALTER DATABASE RECOVER MANAGED STANDBY DATABASE DISCONNECT FROM SESSION;
        exit;
EOF
echo
# Run SQL*Plus to get the database role
ROLE2=$(echo "SELECT DATABASE_ROLE FROM V\$DATABASE;" | $ORACLE_HOME/bin/sqlplus -s / as sysdba)

        if [ $? -eq 0 ]; then
                echo
                echo "Database $ORACLE_SID startup successfully" | tee -a $LOG_FILE
        else
                echo
                echo "Failed to start database... $ORACLE_SID" | tee -a $LOG_FILE
                exit 1  # Exit the script if there is an error shutting down any database
        fi
done
# Final message
echo "DB $ORACLE_SID started in $ROLE2 role..." | tee -a $LOG_FILE
echo
echo "-----------------------------------------------------" | tee -a $LOG_FILE
echo
echo
#Bringing up listener
echo -n -e "${CYAN}Waiting for user to press Enter for Bringing up listener: $TNSS for ORACLE_HOME: $ORACLE_HOME ....${RESET}"  | tee -a $LOG_FILE
# Wait for the user to press Enter
read -p "Press Enter to continue..."
echo
#Bringing up listener
echo "Bringing up listener: $TNSS ...." | tee -a $LOG_FILE

lsnrctl start $TNSS | tee -a $LOG_FILE

if [ $? -eq 0 ]; then
                                                echo
        echo "listener successfully started for $ORACLE_HOME" | tee -a $LOG_FILE
else
        echo "Failed to start listener on for $ORACLE_HOME" | tee -a $LOG_FILE
        exit 1  # Exit the script if there is an error shutting down any database
fi

echo
echo "listener started...." | tee -a $LOG_FILE
echo
echo "-----------------------------------------------------" | tee -a $LOG_FILE
echo
		;;
        7)
            echo
                        echo -e "${CYAN}---------------------------------------${RESET}"
                        echo -e "${CYAN} YOU CHOSE TO TAKE DATABASE POSTCHECKS ${RESET}"
                        echo -e "${CYAN}---------------------------------------${RESET}"
            echo
            #echo "DB Post Patch are running on $ORACLE_SID ...." | tee -a $LOG_FILE
            #echo

# Loop through each ORACLE_SID in the list
for ORACLE_SID in $(cat $SQL_SID_LISTS); do
    # Export the ORACLE_SID variable
    export ORACLE_SID=$ORACLE_SID

    echo -e "${GREEN} DB Postchecks are running on $ORACLE_SID .... ${RESET}" | tee -a $LOG_FILE
    echo | tee -a $LOG_FILE

    # Ensure you're in the initial directory
    cd "$initial_dir"

    # Run the SQL script for Postchecks and append output to the log file
    echo "@DB_Postchecks.sql" | sqlplus -S / as sysdba >> $LOG_FILE

    echo "Spool file location: $LOGS Name: DB_Postchecks_$ORACLE_SID" | tee -a $LOG_FILE
    echo | tee -a $LOG_FILE

    # Check if SQL*Plus ran successfully
    if [ $? -eq 0 ]; then
        echo "Database $ORACLE_SID Postchecks completed successfully" | tee -a $LOG_FILE
    else
        echo "Failed to run DB Postchecks for database $ORACLE_SID" | tee -a $LOG_FILE
        exit 1  # Exit the script if there is an error
    fi

    echo

    # Run SQL query for email status and capture the output
    echo "@email_db_status.sql" | sqlplus -S / as sysdba >> $email_file

    # Define the recipients list, including the user’s email and other fixed recipients
    #recipients="$recipient1 $email"  # Add the name's corresponding email
    subject="$ORACLE_SID@$HOSTNAME | Post Patching Information"
    email_body="Patching Performed By: $name"

    echo
    export TMPDIR="/tmp"

    # Check if the email file exists
    if [ -f "$email_file" ]; then
        # Read the file and send its content as the email body using 'mail'
        { echo "$email_body"; echo ""; echo "CHG No: $CHG_NO"; echo "";  echo ""; cat "$email_file"; } | mail -s "$subject" "$recipient1"
    else
        echo "File not found: $email_file" | tee -a $LOG_FILE
    fi

    # Clean up
    rm -f $email_file

    echo "Post Patching Email sent successfully for $ORACLE_SID running on $HOSTNAME." | tee -a $LOG_FILE
    echo
done

               echo "All Oracle Postchecks completed successfully." | tee -a $LOG_FILE
                           echo
            ;;

                8)
            echo
            echo -e "${CYAN}-----------------------------------${RESET}" | tee -a $LOG_FILE
            echo -e "${CYAN} YOU CHOSE TO STOP BLACKOUT OPTION ${RESET}" | tee -a $LOG_FILE
            echo -e "${CYAN}-----------------------------------${RESET}" | tee -a $LOG_FILE
            echo
                        echo "Removing Blackout from EM Agent....." | tee -a $LOG_FILE
                        echo

                        # Extract the directory path of the EM agent location from the command line of the process
                        EMAGENT_LOCATION=$(grep -iE "EM_Agent|AGENT|Agent" /etc/oratab | awk -F: '{print $2}')
                        echo "EM Agent Home Location in ORATAB : $EMAGENT_LOCATION" | tee -a $LOG_FILE

                        # Check if the location is found
                        if [[ -z "$EMAGENT_LOCATION" ]]; then
                            echo "Unable to extract the Oracle EM Agent location." | tee -a $LOG_FILE
                            exit 1
                        fi
						echo
                        # Print the location
                        echo -n -e "${CYAN}Oracle Enterprise Manager Agent is located at: ${RESET}$EMAGENT_LOCATION" | tee -a $LOG_FILE
                        echo

                        # Stop the EM agent blackout
                        echo "Start Agent and Stopping Oracle Enterprise Manager Agent blackout..." | tee -a $LOG_FILE
                        # Check if the blackout status is active
                        # Uncomment this line to actually perform the blackout
                        echo
                        echo "EMAgent Status.." | tee -a $LOG_FILE
                        $EMAGENT_LOCATION/bin/emctl status agent >> $LOG_FILE 2>&1
                        echo

                        echo "Start EMAgent.." | tee -a $LOG_FILE
                        $EMAGENT_LOCATION/bin/emctl start agent >> $LOG_FILE 2>&1
                        echo

                        echo "EMAgent Blackout Status.." | tee -a $LOG_FILE
                        $EMAGENT_LOCATION/bin/emctl status blackout >> $LOG_FILE 2>&1
                        echo

                        echo "Stop EMAgent Blackout.." | tee -a $LOG_FILE
                        $EMAGENT_LOCATION/bin/emctl stop blackout $BLACKOUT_NAME  >> $LOG_FILE 2>&1
                        echo

                        echo "EMAgent Blackout Status.." | tee -a $LOG_FILE
                        $EMAGENT_LOCATION/bin/emctl status blackout >> $LOG_FILE 2>&1
                        echo



                        # Check if the blackout command was successful
                        if [ $? -eq 0 ]; then
                            echo "Oracle Enterprise Manager Agent has been successfully started and backout removed" | tee -a $LOG_FILE
                        else
                            echo -e "${CYAN}Failed to start the blackout. Please check the EM Agent logs.${RESET}" | tee -a $LOG_FILE
                            exit 1
                        fi

                        echo
                        echo "-----------------------------------------------------" | tee -a $LOG_FILE
                        echo
                        echo "Commenting out all cron jobs......." | tee -a $LOG_FILE
                        echo

                        # Get the current user's crontab
                        crontab -l | tee -a $LOG_FILE
                        crontab -l > current_cron

                        # Uncomment all lines
                        sed -i 's/^##AUTOPATCHING##//' current_cron

                        # Install the modified crontab
                        crontab current_cron

                        # Clean up
                        rm current_cron
                        crontab -l | tee -a $LOG_FILE
                        echo "All cron jobs uncommented." | tee -a $LOG_FILE

                        echo
                        echo "-----------------------------------------------------" | tee -a $LOG_FILE
                        echo
                        ;;

        9)
                        echo
                        echo -e "${CYAN}-----------------------------------------------------------------------------------------------${RESET}" | tee -a $LOG_FILE
                        echo -e "${CYAN} YOU CHOSE TO START REMOVING INACTIVE PATCHES FROM THE ORACLE HOME. JOB WILL RUN IN BACKGROUND ${RESET}" | tee -a $LOG_FILE
                        echo -e "${CYAN}-----------------------------------------------------------------------------------------------${RESET}" | tee -a $LOG_FILE
                        echo
						
             # Step 1[B]: Remove Inactive Patches using OPatch
             echo "Remore Inactive Patches..." | tee -a $LOG_FILE
			 echo
			 
             #$ORACLE_HOME/OPatch/opatch util deleteinactivepatches -silent >> $LOG_FILE 2>&1 &
			 nohup $ORACLE_HOME/OPatch/opatch util deleteinactivepatches -silent &
			 # Get the process ID of the OPatch process
             echo
             # Get the process ID of the last background process
			 PID=$!
			 
			 # Print the PID
			 echo "The process ID of the OPatch command is: $PID" | tee -a $LOG_FILE
			 echo		
		;;
		10)
           		echo | tee -a $LOG_FILE
                        echo -e "${CYAN}----------------------------------${RESET}" | tee -a $LOG_FILE
                        echo -e "${CYAN} YOU CHOSE TO TAKE CLEANUP OPTION ${RESET}" | tee -a $LOG_FILE
                        echo -e "${CYAN}----------------------------------${RESET}" | tee -a $LOG_FILE
            echo | tee -a $LOG_FILE
                                    echo
                        echo "Removing patch biniaries......" | tee -a $LOG_FILE
                        echo | tee -a $LOG_FILE
			echo "Patch list" | tee -a $LOG_FILE
                        echo $COMBO_ZIP $JDK_ZIP $OPATCH_ZIP $COMBO_PATCH_DIR $RU_PATCH_ID $OJVM_PATCH_ID $JDK_PATCH_ID | tee -a $LOG_FILE
                        echo $COMBO_ZIP $JDK_ZIP $OPATCH_ZIP $COMBO_PATCH_DIR $RU_PATCH_ID $OJVM_PATCH_ID $JDK_PATCH_ID | tee -a $LOG_FILE
echo | tee -a $LOG_FILE
echo
ls -ltr $PATCH_DIR/$COMBO_ZIP  | tee -a $LOG_FILE
ls -ltr $PATCH_DIR/$JDK_ZIP  | tee -a $LOG_FILE
ls -ltr $PATCH_DIR/$OPATCH_ZIP  | tee -a $LOG_FILE
ls -ltr $PATCH_DIR/$COMBO_PATCH_DIR  | tee -a $LOG_FILE
ls -ltr $PATCH_DIR/$JDK_PATCH_ID | tee -a $LOG_FILE
sleep 5
rm -rf $COMBO_ZIP $JDK_ZIP $OPATCH_ZIP $COMBO_PATCH_DIR $RU_PATCH_ID $OJVM_PATCH_ID $JDK_PATCH_ID
rm -rf $PATCH_DIR/$COMBO_ZIP 
rm -rf $PATCH_DIR/$JDK_ZIP 
rm -rf $PATCH_DIR/$OPATCH_ZIP 
rm -rf $PATCH_DIR/$COMBO_PATCH_DIR 
rm -rf $PATCH_DIR/$JDK_PATCH_ID
rm -rf $PATCH_DIR/wgetlog*
rm -rf $PATCH_DIR/*.lck
#rm -rf $PATCH_DIR/*.sh
#rm -rf $PATCH_DIR/*.sql
rm -rf $PATCH_DIR/OPatch_OLD*
#rm -rf $PATCH_DIR/*.txt
mv $LOGS/DB_P* $PATCH_DIR/
echo
echo "Removed patch biniaries!!!" | tee -a $LOG_FILE


                        ;;

        11)
            echo
                        echo -e "${CYAN}-----------------------${RESET}"
                        echo -e "${CYAN} EXIST FROM THE SCRIPT ${RESET}"
                        echo -e "${CYAN}-----------------------${RESET}"
            echo
                                                # Record end time
                        END_TIME=$(date +%s)
                        # Calculate and display the time taken
                        DURATION=$((END_TIME - START_TIME))
                        echo -e "${CYAN} Script took $DURATION seconds in completion. ${RESET}"
                        echo

                        echo -e "${CYAN}Thank you for using the Oracle Database Patching Script! 🚀 We hope it helped make your patching process smooth.${RESET}"
                        echo -e "${CYAN}We’d love to hear from you! 📬 ${RESET}"
                        echo -e "${CYAN}Please feel free to share your feedback with the author—your thoughts matter to us!${RESET}"
                        echo -e "${CYAN}👉 Send us your feedback: [infra-oracle@haleon.com]${RESET}"
                        echo -e "${CYAN}Looking forward to hearing from you! 😊 ${RESET}"
                        echo
                        exit 0
            ;;
        *)
            echo "Invalid choice. Please select a number between 1 and 5."
            ;;
    esac

    # After completing the task, the loop continues until the user chooses "Exit"
    echo ""
done






