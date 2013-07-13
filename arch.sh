#/bin/sh
#echo password | gpg --batch -q --passphrase-fd 0 --cipher-algo AES256 -c $inputFileName
#echo password | gpg --batch -q -o $outputFileName --passphrase-fd 0 --decrypt $encryptedFileName

now=$(date +"-%Y-%m-%d-%H-%M")
archName=$1$now".tar"
echo $archName
tar -cf $archName $1
gpg --cipher-algo AES256 -c $archName
rm $archName
