#!/bin/bash
VERS="1.6aa"

# Clear screen
 clear

# Error Trapping with Cleanup
errexit() {
  # Draw 5 lines of + and message
   for i in {1..5}; do echo "+"; done
   echo -e "\e[91mError raised! Cleaning Up and Exiting.\e[39m"
  
  # Remove _source directory if found.
   if [ -d "$SCRIPTPATH/_source" ]; then rm -r $SCRIPTPATH/_source; fi
  
  # Remove xmrig directory if found.
   if [ -d "$SCRIPTPATH/xmrig" ]; then rm -r $SCRIPTPATH/xmrig; fi
  
  # Dirty Exit
  exit 1
}

# Phase Header
phaseheader() {
  echo
  echo -e "\e[32m=======================================\e[39m"
  echo -e "\e[35m- $1..."
  echo -e "\e[32m=======================================\e[39m"
}

# Phase Footer
phasefooter() {
  echo -e "\e[32m=======================================\e[39m"
  echo -e "\e[35m $1 Completed"
  echo -e "\e[32m=======================================\e[39m"
  echo
}

# Intro/Outro Header
inoutheader() {
  echo -e "\e[32m=================================================="
  echo -e "==================================================\e[39m"
  echo " XMRig Build Script v$VERS"

  if [[ "$BUILD" = "7" ]]; then echo " for ARMv7"; fi
  if [[ "$BUILD" = "8" ]]; then echo " for ARMv8"; fi
  if [[ "$BUILD" = "0" ]]; then echo " for x86-64"; fi

  echo " by DocDrydenn @ getpimp.org"
  echo

  if [[ "$DEBUG" = "1" ]]; then echo -e "\e[5m\e[96mDEBUG ENABLED - SKIPPING BUILD PROCESS\e[39m\e[0m"; echo; fi
}

# Intro/Outro Footer
inoutfooter() {
  echo -e "\e[32m=================================================="
  echo -e "==================================================\e[39m"
  echo
}

# Error Trap
 trap 'errexit' ERR

# Setup Variables
 SCRIPTPATH="$( cd "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
 BUILD=0
 DEBUG=0

# Parse Commandline Arguments
 if [[ "$1" = "7" ]]; then BUILD=7; fi
 if [[ "$1" = "8" ]]; then BUILD=8; fi
 if [[ "$1" = "d" ]]; then DEBUG=1; fi
 if [[ "$2" = "d" ]]; then DEBUG=1; fi

# Opening Intro
 inoutheader
 inoutfooter

# Pause for Effect LOL
 sleep 5

### Start Phase 6
 PHASE="Verifying/Installing Dependancies"
 phaseheader $PHASE 

# Install required tools for building from source
 if [[ "$DEBUG" = "1" ]]; then echo -e "\e[96mRunning the apt stuff\e[39m"; fi
 apt update && apt upgrade -y
 apt install git build-essential cmake libuv1-dev libssl-dev libhwloc-dev screen p7zip-full -y

# Install optional tools apt install htop nano
# if [[ "$DEBUG" = "1" ]]; then echo -e "\e[96mRunning the extra apt stuff\e[39m"; fi
# apt install htop nano -y

### End Phase 6
 phasefooter $PHASE

### Start Phase 5
 PHASE="Backup"
 phaseheader $PHASE

 if [ -d "$SCRIPTPATH/xmrig" ]
  then
   if [ -f "$SCRIPTPATH/xmrig/xmrig-build.7z.bak" ]
    then
     # Remove last backup archive
      echo "xmrig-build.7z.bak removed"
      rm $SCRIPTPATH/xmrig/xmrig-build.7z.bak
    else
     echo "xmrig-build.7z.bak doesn't exist - Skipping Delete..."
   fi
   if [ -f "$SCRIPTPATH/xmrig/xmrig.bak" ]
    then
     # Remove last backup binary
      echo "xmrig.bak removed"
      rm $SCRIPTPATH/xmrig/xmrig.bak
    else
     echo "xmrig.bak doesn't exist - Skipping Delete..."
   fi
   if [ -f "$SCRIPTPATH/xmrig/xmrig-build.7z" ]
    then
     # Backup last archive
      echo "xmrig-build.7z renamed to xmrig-build.7z.bak"
      mv $SCRIPTPATH/xmrig/xmrig-build.7z $SCRIPTPATH/xmrig/xmrig-build.7z.bak
    else
     echo "xmrig-build.7z doesn't exist - Skipping Backup..."
   fi
   if [ -f "$SCRIPTPATH/xmrig/xmrig" ]
    then
     # Backup last binary
      echo "xmrig renamed to xmrig.bak"
      mv $SCRIPTPATH/xmrig/xmrig $SCRIPTPATH/xmrig/xmrig.bak
    else
     echo "xmrig doesn't exist - Skipping Backup..."
   fi
  else
  # Make xmrig folder if it doesn't exist
   echo "Creating xmrig directory..."
   mkdir -p $SCRIPTPATH/xmrig
 fi

### End Phase 5
 phasefooter $PHASE

### Start Phase 4
 PHASE="Setting Up Source"
 phaseheader $PHASE

# If a _source directory is found, remove it.
 if [ -d "$SCRIPTPATH/_source" ]
  then
   rm -r $SCRIPTPATH/_source
 fi

# Make new source folder
 if [[ "$DEBUG" = "1" ]]; then echo -e "\e[96mCreating _source directory\e[39m"; fi
 mkdir $SCRIPTPATH/_source

# Change working dir to source folder
 if [[ "$DEBUG" = "1" ]]; then echo -e "\e[96mEnter _source directory\e[39m"; fi
 cd $SCRIPTPATH/_source

# Clone XMRig from github into source folder
 if [[ "$DEBUG" = "1" ]]; then echo -e "\e[96mCloning xmrig git\e[39m"; fi
 git clone https://github.com/xmrig/xmrig.git

# Change working dir to clone - Create build folder - Change working dir to build folder
 if [[ "$DEBUG" = "1" ]]; then echo -e "\e[96mEnter xmrig, make build, and enter build directories\e[39m"; fi
 cd xmrig && mkdir build && cd build

### End Phase 4
 phasefooter $PHASE

### Start Phase 3
 PHASE="Building"
 phaseheader $PHASE

# Setup build enviroment
 if [[ "$BUILD" = "7" ]]; then cmake .. -DCMAKE_BUILD_TYPE=Release -DARM_TARGET=7 -DWITH_OPENCL=OFF -DWITH_CUDA=OFF -DWITH_HWLOC=OFF -DWITH_ASM=OFF; fi
 if [[ "$BUILD" = "8" ]]; then cmake .. -DCMAKE_BUILD_TYPE=Release -DARM_TARGET=8 -DWITH_OPENCL=OFF -DWITH_CUDA=OFF -DWITH_HWLOC=OFF -DWITH_ASM=OFF; fi
 if [[ "$BUILD" = "0" ]]; then cmake .. -DCMAKE_BUILD_TYPE=Release; fi

# Bypass make process if debug is enabled.
 if [[ "$DEBUG" = "1" ]]
  then
   echo -e "\e[96mSkipping Build and touching xmrig\e[39m"
   touch xmrig
  else
   make
 fi

# End Phase 3
 phasefooter $PHASE

### Start Phase 2
 PHASE="Compressing and Moving"
 phaseheader $PHASE

# Compress built xmrig into archive
 7z a xmrig-build.7z $SCRIPTPATH/xmrig

# Copy archive to xmrig folder
 cp xmrig-build.7z $SCRIPTPATH/xmrig/xmrig-build.7z

# Copy built xmrig to xmrig folder
 cp $SCRIPTPATH/_source/xmrig/build/xmrig $SCRIPTPATH/xmrig/xmrig

# End Phase 2
 phasefooter $PHASE

# Start Phase 1
 PHASE="Cleaning Up"
 phaseheader $PHASE

# Change working dir back to root
 cd $SCRIPTPATH

# Remove source folder
 echo "Source directory removed."
 rm -r _source

# Create start-example.sh
 if [ ! -f "$SCRIPTPATH/xmrig/start-example.sh" ]
  then
   echo "start-example.sh created."

cat > $SCRIPTPATH/xmrig/start-example.sh <<EOF
#! /bin/bash

screen -wipe
screen -dm $SCRIPTPATH/xmrig/xmrig -o <pool_IP>:<pool_port> -l /var/log/xmrig-cpu.log --donate-level 1 --rig-id <rig_name>
screen -r
EOF

   # Make start-example.sh executable
    echo "start-example.sh made executable."
    chmod +x $SCRIPTPATH/xmrig/start-example.sh
  fi

# End Phase 1
 phasefooter $PHASE

# Close Out
 inoutheader
 echo " Folder Location: $SCRIPTPATH/xmrig/"
 echo " Bin: $SCRIPTPATH/xmrig/xmrig"
 echo " Example Start Script: $SCRIPTPATH/xmrig/start-example.sh"
 echo
 inoutfooter

# Clean exit of script
 exit 0