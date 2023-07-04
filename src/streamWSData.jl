include("updateDynamoDbCrypto.jl")
using WebSockets, JSON

# user will send a json of array datatypes, 
# the first will the used for auth purpose
# the remaining will be used for the subscribtion purpose.

# uri = "wss://socket.polygon.io/stocks"
uri = "wss://socket.polygon.io/crypto"

# payload_1 = Dict(
#     :action => "auth",
#     :params => AUTH_PARAM
#     )

function subscribe_data(ws, arr)
    for i in eachindex(arr)
        print(arr[i],"\n")
        write(ws, JSON.json(arr[i]))
    end
    # count the data processing time
    counter = 0
    data_to_save = Vector{Int64}()
    
    while isopen(ws) && counter < 33
        received_data, success = readguarded(ws)
        if success
            # will convert this to the map
            # data = JSON.parse(String(data))
            # println(JSON.parse(String(received_data)))
            data = String(received_data)
            # time_before_processing = Dates.value(now())
            process_websocket_data(data, data_to_save)
            # time_after_processing = Dates.value(now())
            # print("begin: ", time_before_processing, ", after: ",time_after_processing, ", processing_time: ", time_after_processing - time_before_processing,", \n")
            @info "streamed data" data
            # keep track of processing times
            counter+=1
            # append!(data_to_save, time_after_processing - time_before_processing)
        end
    end
    print(data_to_save)
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

include("constant.jl")
json_data = JSON.parse(String(event_data))
println(json_data["input_json"])

task = @async open_websocket(json_data["input_json"]);

# open_websocket(json_data["input_json"])
# # schedule(task, InterruptException(), error=true)
# # include("src/streamWSData.jl")