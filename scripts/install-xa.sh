yum install -y ksh
. /opt/microfocus/EnterpriseDeveloper/bin/cobsetenv
cur=$PWD
cd /opt/microfocus/EnterpriseDeveloper/src/enterpriseserver/xa
./build pg
cd $cur


#DSN=dsn,USRPASS=userid.password