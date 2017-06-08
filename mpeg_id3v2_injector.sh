#!/bin/bash

#################################################################################
#
# AUTHOR            : Lebougui
# DATE              : 2016/06/10     
# DESCRIPTION       : HLS Timed metadata injector
#
#################################################################################
VERSION="1.0"
MAINTAINERS="Lebougui"
TRUE="true"
FALSE="false"
DATE="2016/06/10"  

VERBOSE=$FALSE

#set -x

original_dirname=`dirname $0`

# display this script help
help() {
cat << EOF
Usage : $0 -s <transport stream name> -i <ID3v2 file:time> -p <providerID> -a <assetID> -t <time> -d

MPEG2-TS ID3 timed metadata injector.

OPTIONS :
        -h              displays this help
        -s              transport stream name
        -i              ID3v2 filename and time to insert. Several entry can be given separator is ",".
        -p              provider ID
        -a              asset ID
        -t              time in second
        -d              to enable debug mode

        Examples : 
        #To insert title with an existing ID3 file
        $0 -s test.ts \
           -i test.id3:0 \

        #To insert several titles with an existing ID3 files
        $0 -s test.ts \
           -i test.id3:0,test2.id3:10 \

        #To insert several title without an ID3 file.
        $0 -s test.ts \
           -p test.com \
           -a ad0
           -t 0

EOF

version

}

# display this script version
version() {
    echo -e "Version       : $0 $VERSION ($DATE) " 
    echo -e "Maintainer(s) : $MAINTAINERS \n"
}


validate_params() {
    if [ -z "$2" ] 
    then
        echo -e "Bad $1 (given is $2)."
        help
        exit -1
    fi
}

update_metadata(){
    metadata_file=$1
    tagtime=$2
    tagname=$3
    tagfilename=$4

cat >> $metadata_file <<EOF
$tagtime $tagname $tagfilename
EOF
}

current_dirname=`dirname $0`
DEBUG=$FALSE

while getopts "hds:i:p:a:t:" param; do

   case $param in 
       h) help
          exit 0
       ;;

       s) original_tsname="$OPTARG"
       ;;

       i) id3tags="$OPTARG"
       ;;

       p) providerId="$OPTARG"
       ;;

       a) assetId="$OPTARG"
       ;;

       t) eventTime="$OPTARG"
       ;;

       d) DEBUG=$TRUE
       ;;

       *) help
          exit -1
       ;;

   esac

done

shift $(($OPTIND -1 ))

validate_params "Transport stream name" $original_tsname

php_command=`which php`
if [ -z $php_command ]
then
    echo "php not found. Installing it first"

    if [ -e /etc/redhat-release ]
	then
		echo "Installing on `cat /etc/redhat-release`..."
		sleep 3

		yum install -y php-cli

	elif [ -e "/etc/os-release" ]
	then
		NAME=`cat /etc/os-release | grep "^NAME=" | awk 'BEGIN{FS="="}{gsub("\"", "", $2); print $2}'`
		VERSION=`cat /etc/os-release | grep "^VERSION=" | awk 'BEGIN{FS="="}{gsub("\"", "", $2); print $2}'`

		echo "Installing on $NAME $VERSION..."
		sleep 3

        apt-get install php5-cli
    fi

    if [ $? != 0 ]
    then
        echo "Error during php installation."
        exit 0
    fi
fi

perl_command=`which perl`
if [ -z $perl_command ]
then
    echo "perl not installed."
    exit -1
fi

metadata=$(mktemp)
createdid3tagfile=""

if [ ! -z $id3tags ]
then
	declare -a id3tagarray
	id3tagarray=($(echo $id3tags | awk 'BEGIN{FS=","} { for (i=1; i<= NF; i++) {print $i}}'))

	index=0
	while [ $index -lt ${#id3tagarray[@]} ]
	do

	echo ${id3tagarray[$index]} | awk 'BEGIN{FS=":"}{ print $1 " " $2}' | while read id3tagfile id3tagtime
	do
        if [ "$DEBUG" == "$TRUE" ]
        then
            hexdump -C $id3tagfile 
        fi

        update_metadata $metadata $id3tagtime "id3" $id3tagfile
	done

	index=$((index+1))
	done
elif [ ! -z $providerId ] && [ ! -z $assetId ] && [ ! -z $eventTime ] 
then
    createdid3tagfile=$(mktemp)
    #Create an ID3 file containing TXXX Id3v2 tag data
    $perl_command $current_dirname/lib/id3v2.pl -o $createdid3tagfile -p $providerId -a $assetId -txxx

    #Create an ID3 file containing TIT2 Id3v2 tag data
    #$perl_command $current_dirname/lib/id3v2.pl -o $createdid3tagfile -p $providerId -a $assetId -title

    #Create an ID3 file containing TXXX and TIT2 Id3v2 tags data
    #$perl_command $current_dirname/lib/id3v2.pl -o $createdid3tagfile -p $providerId -a $assetId -title -txxx

    if [ "$DEBUG" == "$TRUE" ]
    then
        hexdump -C $createdid3tagfile    
    fi

    update_metadata $metadata $eventTime "id3" $createdid3tagfile
fi

ts_dirname=`dirname $original_tsname`
ts_basename=`basename $original_tsname`
ts_updated_name="$ts_dirname/.$ts_basename"

$php_command $current_dirname/lib/injector.php -i $original_tsname -m inject -e $metadata -o $ts_updated_name
mv $ts_updated_name $original_tsname

unset id3tagarray
rm -rf $metadata $createdid3tagfile




