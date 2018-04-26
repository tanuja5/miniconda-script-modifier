#!/bin/bash
hops=0
download_script="Miniconda2-latest-Linux-ppc64le.sh"
folder_transferred="min_installer"

#Download the original installer script
wget -O https://repo.continuum.io/miniconda/$download_script

#set_manually
set_locally(){
hop3=""
hop3_Remote_directory=""
hop2=""
hop2_Remote_directory=""
hop1=""
hop1_Remote_directory=""
hops=""
}

#set_from_env or use default
set_externally()
{
if [[ -z "${HOP3}" ]] && [[ -z "${HOP3_PORTN}" ]]; then
  hop3="root@10.0.3.67"
  hop3_port_num=""
  hop3_Remote_directory="tanuja"
  hops=0
else
  hop3="${HOP3}"
  hop3_port_num="${HOP3_PORTN}"
  hops=3
  if [[ -z "${HOP3_REMOTE_DIRECTORY}" ]]; then
    hop3_Remote_directory="${HOP3_REMOTE_DIRECTORY}"
  fi
fi
if [[ -z "${HOP2}" ]] && [[ -z "${HOP2_PORTN}" ]]; then
  hops=0
  hop2="hpcroot@ibm-oprf-compute1"
  hop2_port_num=""
  hop2_Remote_directory="tanuja"
else
  hop2="${HOP2}"
  hop2_port_num="${HOP2_PORTN}"
  hops=2
  if [[ -z "${HOP2_REMOTE_DIRECTORY}" ]]; then
      hop2_Remote_directory="${HOP2_REMOTE_DIRECTORY}"
    fi
fi
if [[ -z "${HOP1}" ]] && [[ -z "${HOP1_PORTN}" ]]; then
  hop1="ibm_oprf@103.21.126.139"
  hop1_port_num="22022"
  hop1_Remote_directory="tanuja"
  hops=0
else
  hop1="${HOP1}"
  hop1_port_num="${HOP1_PORTN}"
  hops=1
  if [[ -z "${HOP1_REMOTE_DIRECTORY}" ]]; then
        hop1_Remote_directory="${HOP1_REMOTE_DIRECTORY}"
  fi
fi
}

Transfer()
{
scp -rP $hop1_port_num $folder_transferred $hop1:~/$hop1_Remote_directory
if [ $hops -eq 3 ] || [ $hops -eq 0 ]
then
ssh -t $hop1 -p $hop1_port_num 'cd $hop1_Remote_directory; scp -rP $hop2_port_num $folder_transferred $hop2:~/$hop2_Remote_directory'
ssh -t $hop1 -p $hop1_port_num "ssh \$hop2 -p \$hop2_port_num -t 'cd \$hop2_Remote_directory;scp -rP \$hop3_port_num \$folder_transferred \$hop3:~/\$hop3_Remote_directory'"
ssh -t $hop1 -p $hop1_port_num "ssh \$hop2 -p \$hop2_port_num -t 'cd \$hop2_Remote_directory;cd \$folder_transferred;bash -x ./hopsc.sh'"
fi

if [ $hops -eq 2 ]
then
ssh -t $hop1 -p $hop1_port_num 'cd $hop1_Remote_directory; scp -rP $hop2_port_num $folder_transferred $hop2:~/$hop2_Remote_directory'
ssh -t $hop1 -p $hop1_port_num 'cd $hop2_Remote_directory;cd $folder_transferred;bash -x ./hopsc.sh'
fi

if [ $hops -eq 1 ]
then
cd $folder_transferred
bash -x ./hopsc.sh
fi
}

set_externally
Transfer
