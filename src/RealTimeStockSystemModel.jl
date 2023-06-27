module RealTimeStockSystemModel

using JSON
include("streamWSData.jl")
# Define a handler function that is called by the Lambda runtime
function handle_event(event_data, headers)
    # Pkg.instantiate();
    @info "Handling request: event data" event_data 
    @info "Handling request: headers" headers
    @info "create DynamoDB"
    # include("src/createDynamoDB.jl")
    @info "DynamoDb created"
    @info "Data subscription start"
    json_data = JSON.parse(String(event_data))
    json_data["input_json"]    
    @async open_websocket(json_data["input_json"])
    # open_websocket(json_data["input_json"])
    @info "Data subscription initiated"
    return "This lambda function has been called"
end

end
