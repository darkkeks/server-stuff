if [[ -z "$ID" || -z "$COOKIE" ]]; then
  echo "Expecting ID and COOKIE to be set"
  exit 1
fi

DIRECTION=$1
if [[ "$DIRECTION" == "to_office" ]]; then
  ROUTE="
    [37.22668353105232,55.65968930237797],
    [37.58763559720322,55.73335408624526]
  "
elif [[ "$DIRECTION" == "from_office" ]]; then
  ROUTE="
    [37.58763559720322,55.73335408624526],
    [37.22668353105232,55.65968930237797]
  "
else
  echo "Direction '$DIRECTION' is invalid!"
fi

function get_csrf {
  curl -s -X POST \
    -H "Content-Type: application/json" \
    -H "Cookie: $COOKIE" \
    'https://ya-authproxy.taxi.yandex.ru/csrf_token' \
    --data '{}' \
    | jq -r .sk
}

CSRF="$(get_csrf)"

function get_estimate {
  curl -s -X POST \
    -H "Content-Type: application/json" \
    -H "Cookie: $COOKIE" \
    -H "X-Csrf-Token: $CSRF" \
    -H "X-YaTaxi-UserId: $ID" \
    -H 'X-Taxi: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.15; rv:90.0) Gecko/20100101 Firefox/90.0 turboapp_taxi' \
    'https://ya-authproxy.taxi.yandex.ru/integration/turboapp/v1/orders/estimate' \
    --data '{
      "route": ['"$ROUTE"'],
      "user": {
        "user_id":"'"$ID"'"
      },
      "payment": {
        "type":"cash",
        "payment_method_id":"cash"
      },
      "all_classes": true,
      "selected_class": "",
      "format_currency": false,
      "requirements":{"coupon":""}
    }'
}

echo Running taxi with route "$ROUTE"

ESTIMATE="$(get_estimate)"

echo Got estimates

function extract_prices {
    jq -r '.service_levels[] | "taxi_price{route=\"'$DIRECTION'\",class=\"" + .class + "\"} " + (.price_raw | tostring)'
}

function extract_times {
    jq -r '.service_levels[] | "taxi_time{route=\"'$DIRECTION'\",class=\"" + .class + "\"} " + (.time_raw | tostring)'
}

PRICES=$(echo "$ESTIMATE" | extract_prices)
TIMES=$(echo "$ESTIMATE" | extract_times)

echo Metrics:
echo "$PRICES"
echo "$TIMES"

echo Pushing
cat <<EOF | curl --data-binary @- http://pushgateway:9091/metrics/job/taxi/instance/$DIRECTION
$PRICES
$TIMES
EOF

echo Done
