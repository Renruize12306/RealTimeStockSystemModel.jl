using JSON, Dates
using AWS.AWSServices: dynamodb
using AWS: @service
include("mutateAppSync.jl")

@service Dynamodb

function process_websocket_data(string_data::AbstractString)
    time_before_data_rec = Dates.value(now())
    data = JSON.parse(string_data)
    if "status" in keys(data[1])
        println("states in the key, storage to DDB has been skipped")
        return 
    end
    # println(data[1])
    subscription_type = data[1]["ev"]
    subscription_ticker = data[1]["pair"]
    if "ev" in keys(data[1])
        delete!(data[1], "ev")
    end
    if "pair" in keys(data[1])
        delete!(data[1], "pair")
    end
    data[1]["ev_pair"] = subscription_type * "_" * subscription_ticker
    data[1]["create_time"] = Dates.value(now())
    if "i" in keys(data[1])
        data[1]["i"] = JSON.parse("{\"S\":\""* data[1]["i"] * "\"}")
    end
    if "ev_pair" in keys(data[1])
        data[1]["ev_pair"] = JSON.parse("{\"S\":\""* data[1]["ev_pair"] * "\"}")
    end
    for (key, value) in data[1]
        if cmp("ev_pair", key) == 0 || cmp("i", key) == 0
            continue
        end
        data[1][key] = JSON.parse("{\"N\":\""* string(value) * "\"}")
    end
    table_name = "dynamoAggregatesPerSecondCrypto"
    # println(data[1])
    time_before_store = Dates.value(now())
    # to minimize the latency for the first put to database, 
    # we could put an dummy data and then delete it
    Dynamodb.put_item(data[1], table_name)
    time_after_store = Dates.value(now())
    notify_user(data[1])
    time_after_notify_frontend = Dates.value(now())
    println("data_convert: ", time_before_store - time_before_data_rec, " store_time: ", time_after_store - time_before_store, " update frontend_time: ", time_after_notify_frontend - time_after_store)
end

# process_websocket_data("[{\"ev\":\"A\",\"sym\":\"AMZN\",\"v\":106,\"av\":128413215,\"op\":92.47,\"vw\":89.2434,\"o\":89.24,\"c\":89.24,\"h\":89.24,\"l\":89.24,\"a\":90.4249,\"z\":53,\"s\":1667515806000,\"e\":1667515807000}]")
# process_websocket_data("[{\"ev\":{\"S\":\"A\"},\"sym\":{\"S\":\"AMZN\"},\"v\":{\"N\":106},\"av\":{\"N\":128413215}}]")
# string_data = "[{\"ev\":{\"S\":\"A\"},\"sym\":{\"S\":\"AMZN\"},\"v\":{\"N\":\"106\"},\"ta\":{\"N\":\"106.2\"}}]"
# json_string_data = JSON.parse(string_data)

# string_data_raw = "[{\"ev\":\"DUMMYENV\",\"pair\":\"DUMMY_PAIR\"}]"
# json_string_data_raw = JSON.parse(string_data_raw)
# process_websocket_data(string_data_raw)

# include("src/updateDynamoDbCrypto.jl")