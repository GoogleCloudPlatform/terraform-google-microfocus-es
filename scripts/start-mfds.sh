usernameFull=$1

echo "Starting MFDS using user $usernameFull"
service firewalld stop
runuser -l $usernameFull -c '. /opt/microfocus/EnterpriseDeveloper/bin/cobsetenv; export CCITCP2_PORT=1086; mfds64 --listen-all; mfds64 &'
if [ $? -ne 0 ]; then
    echo "Failed to start MFDS."
    exit 1
fi
service firewalld stop