using JSON, Dates
using AWS.AWSServices: dynamodb
using AWS: @service
include("mutateAppSync.jl")

@service Dynamodb

function process_websocket_data(string_data::AbstractString)
    time_before_store = Dates.value(now())
    data = JSON.parse(string_data)
    if "status" in keys(data[1])
        println("states in the key, storage to DDB has been skipped")
        return 
    end
    subscription_type = data[1]["ev"]
    subscription_ticker = data[1]["sym"]
    if "ev" in keys(data[1])
        delete!(data[1], "ev")
    end
    if "sym" in keys(data[1])
        delete!(data[1], "sym")
    end
    data[1]["ev_sym"] = subscription_type * "_" * subscription_ticker
    data[1]["create_time"] = Dates.value(now())
    if "i" in keys(data[1])
        data[1]["i"] = JSON.parse("{\"S\":\""* data[1]["i"] * "\"}")
    end
    if "ev_sym" in keys(data[1])
        data[1]["ev_sym"] = JSON.parse("{\"S\":\""* data[1]["ev_sym"] * "\"}")
    end
    for (key, value) in data[1]
        if cmp("ev_sym", key) == 0 || cmp("i", key) == 0
            continue
        end
        data[1][key] = JSON.parse("{\"N\":\""* string(value) * "\"}")
    end
    table_name = "dynamoAggregatesPerSecondStock"
    data[1]
    Dynamodb.put_item(data[1], table_name)
    time_after_store = Dates.value(now())
    notify_user(data[1])
    time_after_notify_frontend = Dates.value(now())
    println("store_time: ", time_after_store - time_before_store, " update frontend_time: ", time_after_notify_frontend - time_after_store)
end

# process_websocket_data("[{\"ev\":\"A\",\"sym\":\"AMZN\",\"v\":106,\"av\":128413215,\"op\":92.47,\"vw\":89.2434,\"o\":89.24,\"c\":89.24,\"h\":89.24,\"l\":89.24,\"a\":90.4249,\"z\":53,\"s\":1667515806000,\"e\":1667515807000}]")
# process_websocket_data("[{\"ev\":{\"S\":\"A\"},\"sym\":{\"S\":\"AMZN\"},\"v\":{\"N\":106},\"av\":{\"N\":128413215}}]")
# string_data = "[{\"ev\":{\"S\":\"A\"},\"sym\":{\"S\":\"AMZN\"},\"v\":{\"N\":\"106\"},\"ta\":{\"N\":\"106.2\"}}]"
# string_data_raw = "[{\"ev\":\"A\",\"sym\":\"TSLA\",\"v\":200,\"av\":79948020,\"op\":197.08,\"vw\":194.75,\"o\":194.75,\"c\":194.75,\"h\":194.75,\"l\":194.75,\"a\":195.1287,\"z\":200,\"s\":1669936659000,\"e\":1669936660000}]"
# json_string_data = JSON.parse(string_data)
# json_string_data_raw = JSON.parse(string_data_raw)
# process_websocket_data(string_data_raw)
