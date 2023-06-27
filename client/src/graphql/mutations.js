/* eslint-disable */
// this is an auto generated file. This will be overwritten

export const publish2channel = /* GraphQL */ `
  mutation Publish2channel($name: String!, $data: AWSJSON!) {
    publish2channel(name: $name, data: $data) {
      name
      data
      __typename
    }
  }
`;
export const insertAggregatePerSecondCrypto = /* GraphQL */ `
  mutation InsertAggregatePerSecondCrypto(
    $ev_pair: String!
    $create_time: AWSTimestamp!
    $c: Float!
    $e: AWSTimestamp!
    $h: Float!
    $l: Float!
    $o: Float!
    $s: AWSTimestamp!
    $v: Float!
    $vw: Float!
    $z: Int!
  ) {
    insertAggregatePerSecondCrypto(
      ev_pair: $ev_pair
      create_time: $create_time
      c: $c
      e: $e
      h: $h
      l: $l
      o: $o
      s: $s
      v: $v
      vw: $vw
      z: $z
    ) {
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
  }
`;
