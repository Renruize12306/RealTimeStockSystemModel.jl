module stockBackend

using JSON

# Define a handler function that is called by the Lambda runtime
function handle_event(event_data, headers)
    @info "Handling request" event_data headers
    @info "create DynamoDB"
    # include("src/createDynamoDB.jl")
    @info "DynamoDb created"
    @info "Data subscribe start"
    json_data = JSON.parse(String(event_data))
    json_data["input_json"]
    include("src/streamWSData.jl")
    @info json_data["input_json"]
    @async open_websocket(json_data["input_json"])
    @info "Data subscribe initiated"
    return "Hello World! Lambda function has been called"
end

end
