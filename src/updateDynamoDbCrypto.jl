using JSON, Dates
# using AWS.AWSServices: dynamodb
# using AWS: @service
include("mutateAppSync.jl")

# @service Dynamodb

function process_websocket_data(string_data::AbstractString, data_to_save::Vector{Int64})
    time_before_data_rec = Dates.value(now())
    data = JSON.parse(string_data)
    data_single = data[1]
    if "status" in keys(data_single)
        println("states in the key, storage to DDB has been skipped")
        return 
    end
    # println(data_single)
    subscription_type = data_single["ev"]
    subscription_ticker = data_single["pair"]
    if "ev" in keys(data_single)
        delete!(data_single, "ev")
    end
    if "pair" in keys(data_single)
        delete!(data_single, "pair")
    end
    data_single["ev_pair"] = subscription_type * "_" * subscription_ticker
    data_single["create_time"] = Dates.value(now())
    # if "i" in keys(data_single)
    #     data_single["i"] = JSON.parse("{\"S\":\""* data_single["i"] * "\"}")
    # end
    # if "ev_pair" in keys(data_single)
    #     data_single["ev_pair"] = JSON.parse("{\"S\":\""* data_single["ev_pair"] * "\"}")
    # end
    # for (key, value) in data_single
    #     if cmp("ev_pair", key) == 0 || cmp("i", key) == 0
    #         continue
    #     end
    #     data_single[key] = JSON.parse("{\"N\":\""* string(value) * "\"}")
    # end
    # table_name = "dynamoAggregatesPerSecondCrypto"
    # # println(data_single)
    # time_before_store = Dates.value(now())
    # # to minimize the latency for the first put to database, 
    # # we could put an dummy data and then delete it
    # Dynamodb.put_item(data_single, table_name)
    time_after_store = Dates.value(now())
    notify_user(data_single)
    time_after_notify_frontend = Dates.value(now())
    time_consumption = time_after_notify_frontend - time_after_store
    println("Update database and frontend time: ", time_consumption)
    append!(data_to_save, time_consumption)
end

# process_websocket_data("[{\"ev\":\"A\",\"sym\":\"AMZN\",\"v\":106,\"av\":128413215,\"op\":92.47,\"vw\":89.2434,\"o\":89.24,\"c\":89.24,\"h\":89.24,\"l\":89.24,\"a\":90.4249,\"z\":53,\"s\":1667515806000,\"e\":1667515807000}]")
# process_websocket_data("[{\"ev\":{\"S\":\"A\"},\"sym\":{\"S\":\"AMZN\"},\"v\":{\"N\":106},\"av\":{\"N\":128413215}}]")
# string_data = "[{\"ev\":{\"S\":\"A\"},\"sym\":{\"S\":\"AMZN\"},\"v\":{\"N\":\"106\"},\"ta\":{\"N\":\"106.2\"}}]"
# json_string_data = JSON.parse(string_data)

# string_data_raw = "[{\"ev\":\"DUMMYENV\",\"pair\":\"DUMMY_PAIR\"}]"
# json_string_data_raw = JSON.parse(string_data_raw)
# process_websocket_data(string_data_raw)

# include("src/updateDynamoDbCrypto.jl")