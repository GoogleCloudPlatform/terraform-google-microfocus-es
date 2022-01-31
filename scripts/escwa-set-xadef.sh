dsn=$1
module=$2
userid=$3
password=$4

#DSN=dsn,USRPASS=$userid.$password
function jsonValue() {
    KEY=$1
    num=$2
    awk -F"[,:}]" '{for(i=1;i<=NF;i++){if($i~/'$KEY'\042/){print $(i+1)}}}' | tr -d '"' | sed -n ${num}p | sed -e 's/^[[:space:]]*//'
}

openString="DSN=$dsn,USRPASS=$userid.$password"
Origin='Origin: http://localhost:10086'
JMessage="{ \
            \"CN\": \"XDBD\", \
            \"mfXRMName\": \"XASQL\", \
            \"mfXRMModule\": \"$module\", \
            \"mfXRMOpenString\": \"$openString\", \
            \"mfXRMCloseString\": \"\", \
            \"mfXRMReconnect\": \"1\", \
            \"mfXRMStatus\": \"Enabled\", \
            \"description\": \"\", \
        }"
        
RequestURL="http://localhost:10086/native/v1/regions/localhost/1086/BNKDM/xaresource"
xauid=`curl -sX GET "$RequestURL" -H 'accept: application/json' -H 'X-Requested-With: AgileDev' -H 'Content-Type: application/json' -H "$Origin" --cookie cookie.txt | jsonValue mfUID 1`      
        
RequestURL="http://localhost:10086/native/v1/regions/localhost/1086/BNKDM/xaresource/$xauid"
curl -sX PUT "$RequestURL" -H 'accept: application/json' -H 'X-Requested-With: AgileDev' -H 'Content-Type: application/json' -H "$Origin" -d "$JMessage" --cookie-jar cookie.txt
