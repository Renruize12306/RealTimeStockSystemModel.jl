using JSON
using AWS.AWSServices: dynamodb
using AWS: @service

# Create a DynamoDB for storing the websocket data
# schemeless, we don't need to care about the other options
attribute_definitions = [
    Dict(
        # this attribute means the certain type of subscription type and certain ticker
        :AttributeName => "ev_pair",
        :AttributeType => "S"
    ),
    Dict(
        :AttributeName => "create_time",
        :AttributeType => "N"
    )]

key_schema = [
    Dict(
        :AttributeName => "ev_pair",
        :KeyType => "HASH"
    ),
    Dict(
        :AttributeName => "create_time",
        :KeyType => "RANGE"
    )]
# attribute_definitions = [
#     Dict(
#         :AttributeName => "ev",
#         :AttributeType => "S"
#     ),
#     Dict(
#         :AttributeName => "sym",
#         :AttributeType => "S"
#     )]

# key_schema = [
#     Dict(
#         :AttributeName => "ev",
#         :KeyType => "HASH"
#     ),
#     Dict(
#         :AttributeName => "sym",
#         :KeyType => "RANGE"
#     )]

table_name = "dynamoAggregatesPerSecondCrypto"

param = Dict("ProvisionedThroughput" => Dict(
      "ReadCapacityUnits"=> 20,
      "WriteCapacityUnits"=> 20
))
@service Dynamodb
Dynamodb.create_table(attribute_definitions, key_schema, table_name, param)

# include("src/createDynamoDbCrypto.jl")