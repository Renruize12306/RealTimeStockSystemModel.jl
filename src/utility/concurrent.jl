using HTTP, Dates

# Define the URL
url = "https://main.d342we1efx6fud.amplifyapp.com/"

# Define a function to make a single request
function make_request(x)
    response = HTTP.get(url)
    return response
end

# Use the `pmap` function from the `Distributed` package to make concurrent requests

time_before_processing = Dates.value(now())
# responses = pmap(make_request, 1:1000) # Requests will be made concurrently for 1:10
responses = @sync (make_request(i) for i in 1:1000)
time_after_processing = Dates.value(now())
println("total time for 100 concurrent request with @sync: ", time_after_processing - time_before_processing)
function check_resp(responses)
    count_200 = 0;
    count_other = 0;
    for response in responses
        if response.status == 200
        count_200 +=1
        else
        count_other +=1;
        end
        # println(response.status)
    end
    println("count_200: ", count_200)
    println("count_other: ", count_other)
end

check_resp(responses)