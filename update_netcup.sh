#!/bin/bash
set -e

# .env laden
if [ -f /app/.env ]; then
    export $(grep -v '^#' /app/.env | xargs)
else
    echo "Keine .env-Datei gefunden!"
    exit 1
fi

# IP ermitteln
IP=$(dig +short "$DYNDNS_HOST" | grep -E '^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$')
if [ -z "$IP" ]; then
    echo "Konnte IP von $DYNDNS_HOST nicht ermitteln – Abbruch."
    exit 1
fi
echo "Aktuelle IP: $IP"

# API-Login
SESSION=$(curl -s -X POST https://ccp.netcup.net/run/webservice/servers/endpoint.php \
    -H "Content-Type: application/json" \
    -d "{\"action\":\"login\",\"param\":{\"apikey\":\"$API_KEY\",\"apipassword\":\"$API_PASSWORD\",\"customernumber\":\"$CUSTOMER_NUMBER\"}}" \
    | jq -r '.responsedata.apisessionid')

if [ -z "$SESSION" ] || [ "$SESSION" == "null" ]; then
    echo "Login fehlgeschlagen."
    exit 1
fi

# Domains aktualisieren
for DOMAIN in $DOMAINS; do
    echo "Bearbeite Domain: $DOMAIN"

    # Records abrufen
    RECORDS=$(curl -s -X POST https://ccp.netcup.net/run/webservice/servers/endpoint.php \
        -H "Content-Type: application/json" \
        -d "{\"action\":\"infoDnsRecords\",\"param\":{\"domainname\":\"$DOMAIN\"},\"apisessionid\":\"$SESSION\"}")

    RECORD_ID=$(echo "$RECORDS" | jq -r ".responsedata.dnsrecords[] | select(.hostname==\"$DOMAIN\" and .type==\"A\") | .id")

    if [ -z "$RECORD_ID" ]; then
        echo "❌ Kein A-Record für $DOMAIN gefunden."
        continue
    fi

    # Update durchführen
    curl -s -X POST https://ccp.netcup.net/run/webservice/servers/endpoint.php \
        -H "Content-Type: application/json" \
        -d "{
            \"action\":\"updateDnsRecords\",
            \"param\":{
                \"domainname\":\"$DOMAIN\",
                \"dnsrecordset\":{
                    \"dnsrecords\":[{
                        \"id\":\"$RECORD_ID\",
                        \"hostname\":\"$DOMAIN\",
                        \"type\":\"A\",
                        \"destination\":\"$IP\",
                        \"priority\":\"0\",
                        \"deleterecord\":\"false\",
                        \"state\":\"yes\"
                    }]
                }
            },
            \"apisessionid\":\"$SESSION\"
        }" > /dev/null

    echo "✅ $DOMAIN aktualisiert auf $IP"
done

# Logout
curl -s -X POST https://ccp.netcup.net/run/webservice/servers/endpoint.php \
    -H "Content-Type: application/json" \
    -d "{\"action\":\"logout\",\"apisessionid\":\"$SESSION\"}" > /dev/null

echo "Fertig!"
