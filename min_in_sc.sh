#!/bin/bash

new_script="Miniconda-version1-Linux-ppc64le.sh"
download_script="Miniconda2-latest-Linux-ppc64le.sh"

#Default location to downloaded pack
Path_to_packages="/home/tanuja/Downloads"
#Location where the new miniconda script should refer to package addition
Path_to_miniconda_pack="/home/tanuja/min_installer/pkgs/"
#File to Read packages from, that has to be added into the new miniconda script
pack_list_file_path="/home/tanuja/pack_list"

lineno=0
tails1=0
tails2=0
comment_line=0
cp_list[]=0 
tarl=0
lintotar=0
linum_chng2="tail -n"
search="verify the size of the installer"

function untar_script(){
echo "executing untar"
tail -n +$lineno ./$download_script | tar xf - --no-same-owner
}

function get_line_num(){
cunt=0
while read line           
do 
   lineno=`expr $lineno + 1`
   if [[ $line == *$linum_chng2* ]]
      then   
       cunt=`expr $cunt + 1`     
      if [ $cunt -gt 1 ]
       then  
       tails2=$lineno
       echo $line ":" $tails2  
      else
       tails1=$lineno 
       echo $line ":" $tails1 
      fi
    fi
   if [[ $line == *$search* ]]
   then
     comment_line=$lineno
   fi   
   if [[ $line == *END_HEADER* ]]
   then
     echo $lineno
     lineno=`expr $lineno + 1`
    break
   fi   
done <$download_script
}

function checkNadd(){
count=0
while read line           
do
PATTERN=($Path_to_packages/$line*.tar.bz2)
if [ -f ${PATTERN[0]} ]; 
then
echo "adding pack to pkgs"
cp ${PATTERN[0]} $Path_to_miniconda_pack
cp_list[$count]=${PATTERN[0]}
count=`expr $count + 1`
fi 
done <$pack_list_file_path
}

function retar(){
tar -cvf pkgs.tar LICENSE.txt pkgs preconda.tar.bz2
}

function recreate(){
lineno=`expr $lineno - 1`
head -n $lineno $download_script > $new_script
}


function comm_size(){
line_cont=$(sed ''"$comment_line"'q;d' $new_script)
matc="fi"
while ! [[ $line_cont == $matc ]]
do
   comment_line=`expr $comment_line + 1`
   line_cont=$(sed ''"$comment_line"'q;d' $new_script)
   if [[ $line_cont == *\/* ]] || [[ $line_cont == *\"* ]] || [[ $line_cont == *\$* ]] || [[ $line_cont == *\|* ]] || [[ $line_cont == *\-* ]] || [[ $line_cont == *\>* ]]
   then
        echo "line contains either /,$,|,-,>"
        chng1=$(echo "$line_cont" | sed 's!\"!\\\"!g; s!\/!\\\/!g; s!\&!\\\&!g ; s!\:!\\\:!g')
        chng2="# $chng1"
        sed -ie ''"$comment_line"'s/'"$chng1"'/'"$chng2"'/' $new_script     
   else
       sed -ie ''"$comment_line"'s/'"$line_cont"'/'"# $line_cont"'/' $new_script
   fi
done
}

function append_pack(){
for i in "${cp_list[@]}"
do
 cr1=$(echo "$i" | awk -F'/' '{print $NF}')
 cr2=$(echo "$cr1" | awk -F".tar" '{print $1}')
 echo $cr2
 if [[ $cr1 == *.tar.bz2* ]]
 then
 echo "adding package name"
 valu=$(grep extract_dist* $new_script | tail -1)
 sed -i '/'"$valu"'/a \extract_dist '"$cr2"'' $new_script
 fi
done
}

function chng_linenum(){
while read line           
do 
   lintotar=`expr $lintotar + 1`
   if [[ $line == *LICENSE.txt* ]]
   then
      echo $line
     tarl=$lintotar
     break
   fi   
done <$new_script
linecont1=$(sed ''"$tails1"'q;d' $new_script)
linecont2=$(sed ''"$tails2"'q;d' $new_script)
echo $linecont1
echo $linecont2    
exp1=$(head -n$tails1 $f | tail -1 | grep -Eo '[0-9]{2,4}')
exp2=$(head -n$tails2 $f | tail -1 | grep -Eo '[0-9]{2,4}')
sed -ie ''"$tails1"'s/'"$exp1"'/'"$tarl"'/' $new_script
sed -ie ''"$tails2"'s/'"$exp2"'/'"$tarl"'/' $new_script
}

function lic_lineno(){
     echo "tarl:" $tarl
     tail -n +$tarl ./$new_script | tar xf - --no-same-owner
}

get_line_num
untar_script
checkNadd
retar
recreate
comm_size
append_pack
cat pkgs.tar >> $new_script
chng_linenum
lic_lineno
exit

