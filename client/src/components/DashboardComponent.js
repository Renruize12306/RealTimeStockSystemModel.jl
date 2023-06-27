import React, {Component} from 'react';
import { async } from 'q';
import * as queries from '../graphql/queries';
import * as subscriptions from '../graphql/subscriptions';
import {API, graphqlOperation} from 'aws-amplify';
import Chart from './CandleStickChartForDiscontinuousIntraDay';

const PRICE_LIMIT = 50;

class DashboardComponent extends Component {
    

    constructor() {
        super();
        this.state = {  
            symbols: []
        };

        this.mountedSubscriptions = {};
        this.buffer = {};
    }

    componentDidMount = async() => {
        var symbolKeys = await this.loadDashboard();

        if (symbolKeys.length > 0) {
            for (var i in symbolKeys) {
                var symbolKey = symbolKeys[i];

                this.mountedSubscriptions[symbolKey] = API.graphql(graphqlOperation(subscriptions.subscribe2CryptoAggregates, {ev_pair: symbolKey})).subscribe({
                    next: this.handleSubscription.bind(this)
                });
            }
        }
    }

    handleSubscription(data) {
        var row = data.value.data.subscribe2CryptoAggregates;

        var symbol = row.ev_pair;

        var point = {
            date: new Date(+((row.s+row.s)/2)),
            open: +row.o,
            high: +row.h,
            low: +row.l,
            close: +row.c,
            volume: +row.v
        };

        var isAddedToBuffer = false;
        var dataPoints = this.state.dataPoints;
        
        if (dataPoints[symbol].points.length == 0 && this.buffer[symbol].length == 0) {
            this.buffer[symbol].push(point);
            isAddedToBuffer = true;
        } else if (this.buffer[symbol] != null && this.buffer[symbol].length > 0) {
            dataPoints[symbol].points = dataPoints[symbol].points.concat(this.buffer[symbol]);
            this.buffer[symbol] = [];
        }

        if (!isAddedToBuffer) {
            dataPoints[symbol].points.push(point);
            this.setState({dataPoints: dataPoints});
        }
    }

    componentWillUnmount = async() => {
        for (var symbolKey in this.mountedSubscriptions) {
            console.log("Unsubscribing "+symbolKey);
            this.mountedSubscriptions[symbolKey].unsubscribe();
            this.mountedSubscriptions[symbolKey] = null;
        }
    }

    loadDashboard = async() => {
        // var symbols = await API.graphql(graphqlOperation(queries.listStockSymbols));
        // symbols = symbols.data.listStockSymbols.items;
        var symbols = ["XA_BTC-USD"]
        var dataPointsBySymbol = {};
        for (var i in symbols) {
            var symbol = symbols[i];

            dataPointsBySymbol[symbol] = await this.retrieveLatestPricesBySymbol(symbol);
        }

        var symbolKeys = Object.keys(dataPointsBySymbol);

        this.setState({
            dataPoints: dataPointsBySymbol,
            symbols: symbolKeys
        });

        return symbolKeys;
    }

    retrieveLatestPricesBySymbol = async(symbol) => {
        var dataPoints = [];

        {
            var results = await API.graphql(graphqlOperation(queries.getAggregatesPerSecondCrypto, {
                ev_pair: symbol,
            }));   
            
            results = results.data.getAggregatesPerSecondCrypto;
            var items = results.items;

            if (items.length > 0) {
                for (var i = 0;i < items.length;i++) {
                    var item = items[i];
                    var point = {
                        date: new Date(+((item.s+item.s)/2)),
                        open: +item.o,
                        high: +item.h,
                        low: +item.l,
                        close: +item.c,
                        volume: +item.v
                    };
                    dataPoints.push(point);
                }
            }
        } 

        return {
            //points: dataPoints.reverse()
            points: dataPoints
        };
    }

    render() {
        return (
            <div>
                <h3>Dashboard</h3>
                {/* <a href="/manage-stock-symbols">Manage Stock Symbols</a> */}
                <div>
                    {this.state.symbols.map(symbol => {
                        var hasDataPoints = this.state.dataPoints[symbol].points.length > 0;
                        return (
                            <div className="m-2">
                                <h3>{symbol}</h3>
                                <div className="border">
                                    {hasDataPoints ? (
                                        <Chart symbol={symbol} data={this.state.dataPoints[symbol].points} />
                                    ) : (
                                        <div className="p-2"><h5 className="text-danger">No data points</h5></div>
                                    )}
                                    
                                </div>
                            </div>
                        )
                    })}
                </div>
            </div>
        ); 
    }
}

export default DashboardComponent;