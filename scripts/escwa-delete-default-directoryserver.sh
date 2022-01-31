function jsonValue() {
    KEY=$1
    num=$2
    awk -F"[,:}]" '{for(i=1;i<=NF;i++){if($i~/'$KEY'\042/){print $(i+1)}}}' | tr -d '"' | sed -n ${num}p | sed -e 's/^[[:space:]]*//'
}

Origin='Origin: http://localhost:10086'
echo "Deleting default directory server"
RequestURL='http://localhost:10086/server/v1/config/mfds'
Uid=`curl -sX GET "$RequestURL" -H 'accept: application/json' -H 'X-Requested-With: AgileDev' -H 'Content-Type: application/json' -H "$Origin" --cookie cookie.txt | jsonValue Uid 1`
RequestURL="http://localhost:10086/server/v1/config/mfds/$Uid"
curl -sX DELETE "$RequestURL" -H 'accept: application/json' -H 'X-Requested-With: AgileDev' -H 'Content-Type: application/json' -H "$Origin" --cookie cookie.txt
