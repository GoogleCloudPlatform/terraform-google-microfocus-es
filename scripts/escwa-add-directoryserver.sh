hostname=$1
port=$2
name=$3

function addDS () {
    if [ "$#" -ne 3 ]
    then
        echo "Not Enough Arguments supplied."
        echo "Usage addDS Hostname Port Name"
        exit 1
    fi
    HostName=$1
    Port=$2
    Name=$3
    JMessage="{ \
        \"MfdsHost\": \"$HostName\", \
        \"MfdsIdentifier\": \"$Name\", \
        \"MfdsPort\": \"$Port\" \
    }"

    RequestURL='http://localhost:10086/server/v1/config/mfds'
    Origin='Origin: http://localhost:10086'

    curl -sX POST $RequestURL -H 'accept: application/json' -H 'X-Requested-With: AgileDev' -H 'Content-Type: application/json' -H "$Origin" -d "$JMessage" --cookie cookie.txt
}

echo "Adding directory server $name ($hostname:$port)"
addDS $hostname $port $name
