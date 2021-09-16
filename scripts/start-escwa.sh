usernameFull=$1

echo "Starting ESCWA"
sed -i "s/localhost:10086/*:10086/" /opt/microfocus/EnterpriseDeveloper/etc/commonwebadmin.json
chown $usernameFull /opt/microfocus/EnterpriseDeveloper/etc/commonwebadmin.json
find /opt/microfocus/EnterpriseDeveloper/etc -type d -exec chmod 777 {} \; # So escwa can write to the logfile
runuser -l $usernameFull -c '. /opt/microfocus/EnterpriseDeveloper/bin/cobsetenv; escwa &'
