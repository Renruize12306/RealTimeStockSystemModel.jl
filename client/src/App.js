import React, { useEffect,useState } from "react";
import Amplify, { API, graphqlOperation } from "aws-amplify";
import * as subscriptions from "./graphql/subscriptions"; //codegen generated code
import * as mutations from "./graphql/mutations"; //codegen generated code

//AppSync endpoint settings
const myAppConfig = {
  //dy7jj5l4fvgdfhyxw2lwzneimy
  aws_appsync_graphqlEndpoint:
    "https://63sork6mwnau7oykuaipt4nquy.appsync-api.us-east-1.amazonaws.com/graphql",
  aws_appsync_region: "us-east-1",
  aws_appsync_authenticationType: "API_KEY",
  aws_appsync_apiKey: "da2-vxqnpfnpyjgdpag336frvmrkoy",
};

Amplify.configure(myAppConfig);

function App() {
  const [send, setSend] = useState("");
  const [received, setReceived] = useState("");

  //Define the channel name here
  let channel = "ruize";
  let data = "wo shi ren ruize";

  //Publish data to subscribed clients
  async function handleSubmit(evt) {
    evt.preventDefault();
    evt.stopPropagation();
    const publish = await API.graphql(
      graphqlOperation(mutations.publish2channel, { name: channel, data: send })
    );
    setSend("Enter valid JSON here... (use quotes for keys and values)");
  }

  useEffect(() => {
    //Subscribe via WebSockets
    const subscription = API.graphql(
      graphqlOperation(subscriptions.subscribe2channel, { name: channel })
    ).subscribe({
      next: ({ provider, value }) => {
        setReceived(value.data.subscribe2channel.data);
      },
      error: (error) => console.warn(error),
    });
    return () => subscription.unsubscribe();
  }, [channel]);

  if (received) {
    data = JSON.parse(received);
  }

  //Display pushed data on browser
  return (
    <div className="App">
      <header className="App-header">
        <p>Send/Push JSON to channel "{channel}"...</p>
        <form onSubmit={handleSubmit}>
          <textarea
            rows="5"
            cols="60"
            name="description"
            onChange={(e) => setSend(e.target.value)}
          >
            Enter valid JSON here... (use quotes for keys and values)
          </textarea>
          <br />
          <input type="submit" value="Submit" />
        </form>
        <p>Subscribed/Listening to channel "{channel}"...</p>
        <pre>{JSON.stringify(data, null, 2)}</pre>
      </header>
    </div>
  );
}

export default App;
