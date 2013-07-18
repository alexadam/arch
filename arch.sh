#/bin/sh

appendTimeStamp=1	#append time stamp to file
removeArch=0	#remove the .tar file after it has been encrypted
inputPath=${1%/} #removing trailing "/"

function eff {
	archName=$1
	local archFileName=${1##*/} # get the file name from path
	
	if [ -d $1 ]; then
		if [ $appendTimeStamp == 1 ]; then
			archName="$archFileName$now.tar"
		else
			archName="$archFileName.tar"
		fi
		
		# change tar's dir to input directorys's parent path - do not add the parents to the archive 
		# -p for preserving file permissions
		tar -C $(dirname "$1") -cpf $archName $archFileName
		removeArch=1
	fi
	
	echo $2 | gpg --batch -q --passphrase-fd 0 --cipher-algo AES256 -c $archName
	
	if [ $removeArch == 1 ]; then	
		rm $archName
	fi
}

function dff {
	echo $2 | gpg --batch -q -o $3 --passphrase-fd 0 --decrypt $1
}

if [ $# != 1 ]; then
	echo "Invalid number of parameters!"
	exit
fi

echo "Insert password:"
read -s tmpPass1
echo "Reinsert password:"
read -s tmpPass2

if [ $tmpPass1 != $tmpPass2 ]; then
	echo "Invalid passwords!"
	exit
fi

echo "Select mode: [e|d]f = [en|de]crypt file OR [e|d]m = [en|de]crypt each file in folder"
read mode

now=$(date +"-%Y-%m-%d-%H-%M")

if [ $mode == "ef" ]; then
	eff $inputPath $tmpPass1
elif [ $mode == "df" ]; then
	dff $inputPath $tmpPass1 ${inputPath%.*}
elif [ $mode == "em" ] && [ -d $inputPath ]; then
	appendTimeStamp=0
	tmpFolderName="enc_tmp_folder$now"
	mkdir $tmpFolderName
	
	for file in $inputPath/*
	do
		eff $file $tmpPass1
		mv "$archName.gpg" $tmpFolderName
	done
elif [ $mode == "dm" ] && [ -d $inputPath ]; then
	tmpFolderName="dec_tmp_folder$now"
	mkdir $tmpFolderName
	
	for file in $inputPath/*
	do
		fileName=${file##*/}
		outputFileName=${fileName%.*}
		
		dff $file $tmpPass1 "$tmpFolderName/$outputFileName"
	done
else
	echo "Invalid parameters!"
	exit
fi


#archName=$1$now".tar"
#echo $archName
#tar -cf $archName $1
#gpg --cipher-algo AES256 -c $archName
#rm $archName
