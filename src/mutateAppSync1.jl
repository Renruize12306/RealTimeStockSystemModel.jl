using HTTP, JSON, Dates
headers = [
        "x-api-key" => "da2-7lbuvsokandvnp7rol5kwhibae"
    ]
data = "{\"a1\":\"aiyaaiya\",\"b2\":\"balabala\"}"
test_body = "{\"query\":\"mutation Publish2channel(\$data: AWSJSON!, \$name: String!) {\\n  publish2channel(data: \$data, name: \$name) {\\n    data\\n    name\\n  }\\n}\\n\",\"variables\":{\"name\":\"ruize\",\"data\":\"{\\\"la\\\":\\\"ha\\\"}\"}}"
url = "https://u6bjowlbgzapppjwfzetw5go2u.appsync-api.us-east-1.amazonaws.com/graphql"

msg = "[{\"ev\":\"A\",\"sym\":\"AMZN\",\"v\":106,\"av\":128413215,\"op\":92.47,\"vw\":89.2434,\"o\":89.24,\"c\":89.24,\"h\":89.24,\"l\":89.24,\"a\":90.4249,\"z\":53,\"s\":1667515806000,\"e\":1667515807000}]"


function notify_user(msg)

## test begin


    # data = JSON.parse(msg)
    # if "status" in keys(data[1])
    #     return 
    # end
    # subscription_type = data[1]["ev"]
    # subscription_ticker = data[1]["sym"]
    # if "ev" in keys(data[1])
    #     delete!(data[1], "ev")
    # end
    # if "sym" in keys(data[1])
    #     delete!(data[1], "sym")
    # end
    # data[1]["ev_sym"] = subscription_type * "_" * subscription_ticker
    # data[1]["create_time"] = Dates.value(now())
    # if "i" in keys(data[1])
    #     data[1]["i"] = JSON.parse("{\"S\":\""* data[1]["i"] * "\"}")
    # end
    # if "ev_sym" in keys(data[1])
    #     data[1]["ev_sym"] = JSON.parse("{\"S\":\""* data[1]["ev_sym"] * "\"}")
    # end
    # for (key, value) in data[1]
    #     if cmp("ev_sym", key) == 0 || cmp("i", key) == 0
    #         continue
    #     end
    #     data[1][key] = JSON.parse("{\"N\":\""* string(value) * "\"}")
    # end
    # data[1]

## test end 
    body_front = "{\"query\":\"mutation "*
    "Publish2channel(\$data: AWSJSON!, \$name: String!) {\\n  "*
    "publish2channel(data: \$data, name: \$name) {\\n    "*
    "data\\n    name\\n  }\\n}\\n\"," *
    "\"variables\":{\"name\":\"ruize\",\"data\":\""

    body_end = "\"}}"

    string_body_mid = JSON.json(msg);
    string_body_mid_replaced = replace(string_body_mid, "\"" => "\\\"")
    msg_body =  body_front * string_body_mid_replaced * body_end
    resp = HTTP.post(url, headers, msg_body)
end

# notify_user(test_body)
