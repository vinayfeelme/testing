#!/bin/bash

# Record start time
#START_TIME=$(date +%s)

# Basic color codes
RED='\033[0;31m'        # Red
GREEN='\033[0;32m'      # Green
YELLOW='\033[1;33m'     # Yellow
BLUE='\033[0;34m'       # Blue
MAGENTA='\033[0;35m'    # Magenta
CYAN='\033[0;36m'       # Cyan
RESET='\033[0m'         # Reset to default color

#Current Running SID Output Location: /tmp/sid.out
# Define the path to the source file
source_file="./config.txt"  # Replace with the actual path to your source file

# Check if the source file exists
if [ ! -f "$source_file" ]; then
    echo "Error: Source file $source_file not found. Please ensure the file exists."
    exit 1
fi

# If the source file exists, source it
source "$source_file"

#echo "Source file $source_file successfully sourced."

LOG_FILE=$1
PATCH_DIR=$2
LOGS=$3

echo "--------------------------------------------------------"
echo
echo "Downloading OPATCH patch......"
./wget_OPATCH.sh &
echo
  # Get the process ID of the OPatch process
  opatch_pid=$!

  # Display progress using dots
  while kill -0 $opatch_pid 2>/dev/null; do
    echo -n "."  # Print a dot every second to show progress
    sleep 1
  done

  echo " "  # Add a newline after the dots
echo
echo "OPATCH patch downloaded!!!"
echo

echo "--------------------------------------------------------"

echo
echo "Downloading Combo patch for DB-RU & OJVM patch....."
./wget_37262172_combo.sh &
echo
  # Get the process ID of the OPatch process
  opatch_pid=$!

  # Display progress using dots
  while kill -0 $opatch_pid 2>/dev/null; do
    echo -n "."  # Print a dot every second to show progress
    sleep 1
  done

  echo " "  # Add a newline after the dots
echo
echo "DB-RU & OJVM patch downloaded!!!"
echo "--------------------------------------------------------"
echo
echo "Downloading JDK patch......"
./wget_37213431_JDK.sh &
echo
  # Get the process ID of the OPatch process
  opatch_pid=$!

  # Display progress using dots
  while kill -0 $opatch_pid 2>/dev/null; do
    echo -n "."  # Print a dot every second to show progress
    sleep 1
  done

  echo " "  # Add a newline after the dots
echo

echo "JDK patch downloaded!!!"
echo


##########################################################################################################################
#Block 8

echo | tee -a $LOG_FILE
echo "###############################################################################################" | tee -a $LOG_FILE
echo | tee -a $LOG_FILE
echo -e "${RED}----------------------------${RESET}" | tee -a $LOG_FILE
echo -e "${RED}UNZIPPING PATCHES${RESET}" | tee -a $LOG_FILE
echo -e "${RED}----------------------------${RESET}" | tee -a $LOG_FILE
echo | tee -a $LOG_FILE
#Combo patch unzip

# Check if the patch exists
if [ ! -f "$PATCH_DIR/$COMBO_ZIP" ]; then
    echo "Error: COMBO_ZIP Patch file not found in $PATCH_DIR" | tee -a $LOG_FILE
    exit 1
fi

# If patch is found, unzip the patch
echo
echo "Unzipping Combo Patch $PATCH_DIR/$COMBO_ZIP ....." | tee -a $LOG_FILE
echo
cd $PATCH_DIR
# Start the unzip process in the background and capture output to the log file

# Unzip and show progress
(
  yes y | unzip -q "$PATCH_DIR/$COMBO_ZIP" >> "$LOGS/combo_patch_$DAT.txt" 2>&1 &

  # Capture the PID of the unzip process
  UNZIP_PID=$!

  # Show progress while unzip is running
  while kill -0 $UNZIP_PID 2>/dev/null; do
    echo -n "."  | tee -a $LOG_FILE # Print dot without a new line
    sleep 1      # Sleep for 1 second (adjust if needed)
  done

  echo ""  # Move to the next line after progress dots
) &

# Wait for the unzip process to finish
wait $UNZIP_PID
echo
echo "$COMBO_ZIP Unzip completed. Check the log at $LOG_FILE" | tee -a $LOG_FILE
echo


#####################################################################################################################


echo
echo "*********************************************" | tee -a $LOG_FILE
echo
#JDK patch unzip
# Check if the patch exists
if [ ! -f "$PATCH_DIR/$JDK_ZIP" ]; then
    echo "Error: JDK Patch file not found in $PATCH_DIR" | tee -a $LOG_FILE
    exit 1
fi

# If patch is found, unzip the patch
echo
echo "Unzipping JDK Patch $PATCH_DIR/$JDK_ZIP ....." | tee -a $LOG_FILE
echo
cd $PATCH_DIR
# Start the unzip process in the background and capture output to the log file

# Unzip and show progress
(
 yes y | unzip -q "$PATCH_DIR/$JDK_ZIP" >> "$LOGS/JDK_patch_$DAT.txt" 2>&1 &

  # Capture the PID of the unzip process
  UNZIP_PID=$!

  # Show progress while unzip is running
  while kill -0 $UNZIP_PID 2>/dev/null; do
    echo -n "."  | tee -a $LOG_FILE # Print dot without a new line
    sleep 1      # Sleep for 1 second (adjust if needed)
  done

  echo ""  # Move to the next line after progress dots
) &

# Wait for the unzip process to finish
wait $UNZIP_PID
echo
echo "$JDK_ZIP Unzip completed. Check the log at $LOG_FILE" | tee -a $LOG_FILE
echo

echo  "Exiting from pull_script.sh script" | tee -a $LOG_FILE
exit 0  # Exit with status 0 (success)


