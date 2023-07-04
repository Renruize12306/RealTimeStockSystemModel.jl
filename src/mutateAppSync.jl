using HTTP, JSON, Dates
headers = ["x-api-key" => "da2-7lbuvsokandvnp7rol5kwhibae"]
url = "https://u6bjowlbgzapppjwfzetw5go2u.appsync-api.us-east-1.amazonaws.com/graphql"

function notify_user(data_single)

    # msg_body = {"query":"mutation create {\n  insertAggregatePerSecondCrypto(c: 9999, create_time: 1687230220000, e: 1687706900000, ev_pair: \"XA_BTC-USD\", h: 1.5, l: 1.5, o: 1.5, s: 1687706800000, v: 1.5, vw: 1.5, z: 10) {\n    create_time\n    ev_pair\n    z\n    vw\n    v\n    s\n    o\n    l\n    h\n    e\n    c\n  }\n}\n","variables":null,"operationName":"create"}
    msg_body = "{\"query\":\"mutation create {\\n  "*
    "insertAggregatePerSecondCrypto("*
    "c: $(data_single["c"]), "*
    "create_time: $(data_single["create_time"]), "*
    "e: $(data_single["e"]), "*
    "ev_pair: \\\"$(data_single["ev_pair"])\\\", "*
    "h: $(data_single["h"]), "*
    "l: $(data_single["l"]), "*
    "o: $(data_single["o"]), "*
    "s: $(data_single["s"]), "*
    "v: $(data_single["v"]), "*
    "vw: $(data_single["vw"]), "*
    "z: $(data_single["z"])"*") {\\n    create_time\\n    ev_pair\\n    z\\n    vw\\n    v\\n    s\\n    o\\n    l\\n    h\\n    e\\n    c\\n  }\\n}\\n\",\"variables\":null,\"operationName\":\"create\"}"
   
    resp = HTTP.post(url, headers, msg_body)
end

# notify_user("test_body")