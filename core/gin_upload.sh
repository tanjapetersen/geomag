#!/bin/sh
#
# Upload a file to a GIN web server. For information use the -h option.
#
# S. Flower, Sep 2007

################################################################################
# print a message to stderr
################################################################################
echo_stderr ()
{
	msg="$1"
	shift
	while [ $# -gt 0 ] ; do
		msg="$msg $1"
		shift
	done
	echo "$msg" 1>&2
}


################################################################################
# print a usage message and exit
################################################################################
usage ()
{
	echo_stderr "usage: $prog_name [-d] [-h] [-p host[:port]] [-u username:password]"
        echo_stderr "                  <data-file> <url>"
	echo_stderr " "
	echo_stderr "notes: use -d to turn on debugging"
	echo_stderr "       use -h to print this information and exit"
        echo_stderr "       use -p to specify a proxy web-server"
	echo_stderr "       use -u if a username/password is needed (default = none)"
	echo_stderr "       the url is the absolute address of the cache"
	echo_stderr "       application, without any query string information, e.g."
	echo_stderr "           http://www.geomag.bgs.ac.uk/GINFileUpload/Cache"
	

	exit 1
}


################################################################################
# start of main script body
################################################################################
# configuration
CURL=curl
prog_name=gin_upload.sh

# process command line
debug=0
while getopts dhp:u: opt ; do
	case $opt in
		d) debug=1 ;;
		h) usage ;;
                p) phostport="$OPTARG" ;;
		u) userpass="$OPTARG" ;;
		/?) usage ;;
	esac
done
i=`expr $OPTIND - 1`
shift $i
if [ $# -ne 2 ] ; then
	echo_stderr "$prog_name: error in command line"
	usage
fi
datafile="$1"
address="$2"

# check any proxy information
if [ -n "$phostport" ] ; then
	phost=`echo "$phostport" | awk -F: '{print $1}'`
	pport=`echo "$phostport" | awk -F: '{if (NF < 2) print "" ; else print $2}'`
fi

# check any username/password information
if [ -n "$userpass" ] ; then
	username=`echo "$userpass" | awk -F: '{if (NF != 2) print "" ; else print $1}'`
	if [ -z "$username" ] ; then
		echo_stderr "$prog_name: error in username/password (missing password)"
		exit 1
	fi
	password=`echo "$userpass" | awk -F: '{print $2}'`
fi

# check the datafile is accessible
if [ ! -r "$datafile" ] ; then
	echo_stderr "$prog_name: file $datafile does not exist or is not readable"
	exit 1
fi

# get two temporary files
curl_out="/tmp/curl_$$_out"
curl_err="/tmp/curl_$$_err"

# tell the user what's going to happen
if [ $debug -ne 0 ] ; then
	echo_stderr "$prog_name: using GIN server at $address"
	if [ -n "$username" ] ; then
		echo_stderr "$prog_name: username=$username, password=$password"
	fi
fi

# build the curl command
curl_cmd="-FFile=@$datafile;type=text/plain -FFormat=plain -FRequest=Upload"
if [ -n "$phost" ] ; then
        if [ -n "$pport" ] ; then
            curl_cmd="$curl_cmd -x $phost:$pport"
        else
            curl_cmd="$curl_cmd -x $phost"
        fi
fi
if [ -n "$username" ] ; then
	curl_cmd="$curl_cmd -u $username:$password --digest"
fi
curl_cmd="$curl_cmd ${address}"
if [ $debug -ne 0 ] ; then
	echo_stderr "$prog_name: command = $CURL $curl_cmd"
fi
	
# run the curl command - remove Windows CR characters from the output (which
# may have come from a web server) - this isn't needed for stderr
$CURL $curl_cmd 2>$curl_err | tr -d '\r' >$curl_out 
curl_status=$?
if [ -r $curl_err ] ; then
	n_lines_err=`cat $curl_err | wc -l | awk '{print $1}'`
else
	n_lines_err=0
fi
if [ -r $curl_out ] ; then
	n_lines_out=`cat $curl_out | wc -l | awk '{print $1}'`
else
	n_lines_out=0
fi

# in debug mode show the output from CURL	
if [ $debug -eq 1 ] ; then
	echo "$prog_name: curl exit status = $curl_status"
	echo "------------------------------ stderr from CURL ------------------------------"
	cat $curl_err
	echo "--------------------------- end of stderr from CURL --------------------------"
	echo "------------------------------ stdout from CURL ------------------------------"
	cat $curl_out
	echo "--------------------------- end of stdout from CURL --------------------------"
fi

# work out what happened and tell the user
exit_val=0
if [ $curl_status -ne 0 ] ; then
	case $n_lines_err in
	0)  
		echo_stderr "$prog_name: error uploading file" 
		exit_val=1
		;;
	1)  
		msg=`head -1 $curl_err`
		echo_stderr "$prog_name: curl error: $msg" 
		exit_val=1
		;;
	*) 
		msg=`tail -1 $curl_err`
		echo_stderr "$prog_name: curl error: $msg ..." 
		exit_val=1
		;;
	esac
elif [ $n_lines_out -le 0 ] ; then
	echo_stderr "$prog_name: no response from GIN"
	exit_val=1
else
	orig_status=`head -1 $curl_out`
	lwr_status=`echo "$orig_status" | tr [A-Z] [a-z]`
	case $n_lines_out in
	1) 
		msg="No further information" 
		;;
	2) 
		msg=`head -2 $curl_out | tail -1` 
		;;
	*) 
		msg2=`head -2 $curl_out | tail -1` 
		msg3=`head -3 $curl_out | tail -1` 
		msg="$msg2 - $msg3"
		;;
	esac
	case "$lwr_status" in
	information*|success*)
		if [ $debug -ne 0 ] ; then
			echo_stderr "$prog_name: $orig_status - $msg"
		fi
		;;
	warning*)
		echo_stderr "$prog_name: $orig_status - $msg"
		;;
	error*|exception*|fatal*)
		echo_stderr "$prog_name: $orig_status - $msg"
		exit_val=1
		;;
	*)
		echo_stderr "$prog_name: unrecognised data received from GIN -"
		cat $curl_out 1>&2
		exit_val=1
		;;
	esac
fi

# if you get here, the upload was successful
rm -f $curl_out $curl_err
exit $exit_val

