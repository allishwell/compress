#!/bin/bash

#imagemagick is required
if ! hash convert 2>/dev/null; then
   echo "imagemagick is required.if debian run 'sudo apt-get install imagemagick'"
   exit 1
fi 

#
## Display help text 
#
usage() {
echo -n "  Usage: $0"
cat <<"EOF" 
 [-R] [-f] [-d <directory-path>] [-n <name>] [-e <extention>] [-q <quality>]
    where:
      -d 
        directory path need to be scaned default value .
      -R
        recursivly scan directories
      -n 
        file name default * 
      -e 
        file extention default jpg
      -q 
        quality of image default 50
      -f 
        forcefully compress all
      --size n[cwbkMG]
        File uses n units of space. The following suffixes can be used:

            `b'    for 512-byte blocks (this is the default if no suffix  is used)
            `c'    for bytes
            `w'    for two-byte words
            `k'    for Kilobytes (units of 1024 bytes)
            `M'    for Megabytes (units of 1048576 bytes)
            `G'    for Gigabytes (units of 1073741824 bytes)
      --resize geometry
        Format of geometry: [WIDTHxHEIGHT | PERCENTAGE]
        Resize image based on width/height or percentage
          WIDTH/HEIGHT - positive integer
          PERCENTAGE - Eg. 50%
          
          1024x - will automatically determine height to keep dimension
          x576 - will automatically determine width to keep dimension
      --log filename
        option log file name 
EOF
  exit 1
}

#
## Display progress bar
#
progressBar() {
  if [ "$#" -eq 2 ]; then
    local total=$1
    local inprogress=$2
    local column=$(($(stty size | cut -d' ' -f2)-7))
    local progressed=$(( ($inprogress*100)/$total )) #formula used (inprogress/total)*100
    local fills=$(( ($column*$progressed)/100 ))

    echo -n "["
    for i in $(seq 1 $fills); do echo -n "="; done; #completed %
    echo -n ">"
    fills=$fills-1
    for i in $( seq 1 $(( $column-$fills )) ); do echo -n " "; done; #uncompleted %
    echo -n "]$progressed%"
    
    #ignore \r at complete
    if [ "$progressed" -ne 100 ]; then
      echo -ne '\r'
    fi
  fi
}

dir="."
name="*"
ext="jpg"
quality=50
recursive=' -maxdepth 1'
log=""
forceful=0
size=""
resize=""
declare -i count

TEMP=`getopt -q -o d:e:q:Rf --long log:,size:,resize: -- "$@"`

if [ $? -ne 0 ]
then
  usage
fi

# Note the quotes around `$TEMP: they are essential!
eval set -- "$TEMP"

while [ $# -gt 0 ]
do
  case "$1" in
    -d) dir=$2; shift;;
    -e) ext=$2; shift;;
    -q) quality=$2; shift;;
    -n) name=$2; shift;;
 --log) log=$2; shift;;
--size) size="-size $2"; shift;;
--resize) resize="-resize \"$2\""; shift;;
    -R) recursive="";;
    -f) forceful=1;;
    --) shift; break;;
    *) usage;;
  esac
  shift;
done
(
IFS=$'\n'
#compress the image
cmd="find $dir $recursive $size ! -path . -type f -name '$name.$ext'"
files=($(eval $cmd))

if [ "" != "$log" ]; then
  echo -e "\n########$(date)#########\n" >> $log
fi
for index in ${!files[@]} 
do
  file=${files[$index]}
  cmd="convert $resize -quality $quality% \"$file\" \"$file\""
  if [ 1 -eq "$forceful" ]; then
    count=$count+1
    $(eval $cmd)
    progressBar ${#files[@]} $(($index+1))
    if [ "" != "$log" ]; then
       echo $cmd >> $log 
    fi
  else
    image=$(basename ${file})
    read -p "Do you want to compress '$image'?[y/n] " -n 1 -r
    echo    # (optional) move to a new line
    if [[ $REPLY =~ ^[Yy]$ ]]
    then
      count=$count+1
      $(eval $cmd)
      if [ "" != "$log" ]; then
        echo $cmd >> $log 
      fi
    fi
  fi
done
echo "$count file(s) compressed out of ${#files[@]}"
)
