usernameFull=$1
regionZip=$2        #BankDemo_PAC.zip
unzipFolder=$3      #/home/demouser
echo "Importing BankDemo region"
yum install unzip -y
echo "Unzipping $regionZip to $unzipFolder"
unzip $regionZip -d $unzipFolder
regionFolderPath=$unzipFolder/BankDemo_PAC
chown -R $usernameFull $regionFolderPath
chmod -R 755 $regionFolderPath
echo "Importing $regionFolderPath/Repo/BNKDM.xml"
runuser -l $usernameFull -c ". /opt/microfocus/EnterpriseDeveloper/bin/cobsetenv; export CCITCP2_PORT=1086; mfds /g 5 `pwd`/$regionFolderPath/Repo/BNKDM.xml D"