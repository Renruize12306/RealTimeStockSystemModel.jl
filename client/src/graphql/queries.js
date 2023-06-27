/* eslint-disable */
// this is an auto generated file. This will be overwritten

export const getChannel = /* GraphQL */ `
  query GetChannel {
    getChannel {
      name
      data
      __typename
    }
  }
`;
export const getAggregatesPerSecondCrypto = /* GraphQL */ `
  query GetAggregatesPerSecondCrypto($ev_pair: String!, $limit: Int) {
    getAggregatesPerSecondCrypto(ev_pair: $ev_pair, limit: $limit) {
      items {
        ev_pair
        create_time
        c
        e
        h
        l
        o
        s
        v
        vw
        z
        __typename
      }
      __typename
    }
  }
`;
