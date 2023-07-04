import React, { useEffect,useState } from "react";
import Amplify, { API, graphqlOperation } from "aws-amplify";
import * as subscriptions from "./graphql/subscriptions"; //codegen generated code
import * as mutations from "./graphql/mutations"; //codegen generated code
import {BrowserRouter, Switch, Route} from 'react-router-dom';
import DashboardComponent from './components/DashboardComponent';

//AppSync endpoint settings
const myAppConfig = {
  aws_appsync_graphqlEndpoint:
    "https://u6bjowlbgzapppjwfzetw5go2u.appsync-api.us-east-1.amazonaws.com/graphql",
  aws_appsync_region: "us-east-1",
  aws_appsync_authenticationType: "API_KEY",
  aws_appsync_apiKey: "da2-7lbuvsokandvnp7rol5kwhibae",
};

Amplify.configure(myAppConfig);

function App() {
  const [send, setSend] = useState("");
  const [received, setReceived] = useState("");

  //Define the channel name here
  let channel = "ruize";
  let data_display = "wo shi ren ruize";
  let ticker_pair = "XA_BTC-USD"

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

  useEffect(() => {
    //Subscribe via WebSockets
    const subscription2Crypto = API.graphql(
      graphqlOperation(subscriptions.subscribe2CryptoAggregates, { ev_pair: ticker_pair })
    ).subscribe({
      next: ({ provider, value }) => {
        setReceived(value.data.subscribe2CryptoAggregates);
      },
      error: (error) => console.warn(error),
    });
    return () => subscription2Crypto.unsubscribe();
  }, [ticker_pair]);

  if (received) {
    data_display = received;
    console.log(data_display);
  }

  // if (received) {
  //   data = JSON.parse(received);
  // }

  //Display pushed data on browser
  return (
    <div className="App">
      <header className="App-header">
        <div>
          <BrowserRouter>
              <Switch>
                <Route exact path="/" component={DashboardComponent} />
              </Switch>
          </BrowserRouter>
        </div>
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
        <pre>{JSON.stringify(data_display, null, 2)}</pre>
      </header>
    </div>
  );
}

export default App;
