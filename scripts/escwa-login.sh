echo "Logging into ESCWA"
JMessage="{ \"mfUser\": \"\", \"mfPassword\": \"\" }"
RequestURL='http://localhost:10086/logon'
Origin='Origin: http://localhost:10086'

i="0"
while [ ! -f ./cookie.txt ]; do
    sleep 5 # Give ESCWA some time to start up
    curl -sX POST $RequestURL -H 'accept: application/json' -H 'X-Requested-With: AgileDev' -H 'Content-Type: application/json' -H "$Origin" -d "$JMessage" --cookie-jar cookie.txt
    i=$[$i+1]
    if [ $i -ge 5 ]; then
        echo "Failed to login to ESCWA."
        exit 1
    fi
done
