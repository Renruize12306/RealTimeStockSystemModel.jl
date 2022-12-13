include("../constant.jl")
include("updateDynamoDb.jl")
using WebSockets, JSON

# user will send a json of array datatypes, 
# the first will the used for auth purpose
# the remaining will be used for the subscribtion purpose.

uri = "wss://delayed.polygon.io/stocks"
json_part_1 = "{\"action\":\"auth\",\"params\":\"$AUTH_PARAM\"}"
# json_part_1 = "{\"action\":\"auth\",\"params\":\"" * ENV["AUTH_PARAM"] * "\"}"
json_part_2 = "{\"action\":\"subscribe\", \"params\":\"A.AMZN\"}"
json_part_3 = "{\"action\":\"subscribe\", \"params\":\"A.TSLA\"}"
json_part_4 = "{\"action\":\"subscribe\", \"params\":\"A.AAPL\"}"
json_part_5 = "{\"action\":\"subscribe\", \"params\":\"A.LMT\"}"
arr_json = [json_part_1, json_part_2, json_part_4, json_part_5, json_part_3]

# payload_1 = Dict(
#     :action => "auth",
#     :params => AUTH_PARAM
#     )

function subscribe_data(ws, arr)
    for i in eachindex(arr)
        write(ws, JSON.json(arr[i]))
    end
    while isopen(ws)
        received_data, success = readguarded(ws)
        if success
            # will convert this to the map
            # data = JSON.parse(String(data))
            # println(JSON.parse(String(received_data)))
            data = String(received_data)
            time_before_processing = Dates.value(now())
            process_websocket_data(data)
            time_after_processing = Dates.value(now())
            print("begin: ", time_after_processing, ", after: ",time_after_processing, ", processing_time: ", time_after_processing - time_after_processing,", ")
            print(data, "\n")
            # @info data
        end
    end
end


function open_websocket(arr)
    if length(arr) > 1
        WebSockets.open(uri) do ws
            if isopen(ws)
                # this will convert the dict to the json file, we could also
                # manually create the josn file with the backslash \"
                # write(ws, JSON.json(payload_1))
                write(ws, JSON.json(arr[1]))
            end
            subscribe_data(ws, arr[2:length(arr)])
        end
    end
end

json_data = JSON.parse(String(event_data))
json_data["input_json"]

@async open_websocket(json_data["input_json"])