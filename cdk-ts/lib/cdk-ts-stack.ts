import * as cdk from '@aws-cdk/core';
import * as cognito from '@aws-cdk/aws-cognito';
import * as dynamodb from '@aws-cdk/aws-dynamodb';
import { GraphqlApi, AuthorizationType, Directive, ObjectType, GraphqlType, ResolvableField, Field, MappingTemplate, FieldLogLevel } from '@aws-cdk/aws-appsync';

export class CdkTsStack extends cdk.Stack {
  constructor(scope: cdk.Construct, id: string, props?: cdk.StackProps) {
    super(scope, id, props);
    const userPool = new cognito.UserPool(this, 'cdk-products-user-pool', {
      selfSignUpEnabled: true,
      accountRecovery: cognito.AccountRecovery.PHONE_AND_EMAIL,
      userVerification: {
        emailStyle: cognito.VerificationEmailStyle.CODE
      },
      autoVerify: {
        email: true
      },
      standardAttributes: {
        email: {
          required: true,
          mutable: true
        }
      }
    })
    const api = new GraphqlApi(this, 'Api', {
      name: 'TS-API',
      authorizationConfig: {
        defaultAuthorization: {
          authorizationType: AuthorizationType.API_KEY
        },
        additionalAuthorizationModes: [{
          authorizationType: AuthorizationType.USER_POOL,
          userPoolConfig: {
            userPool,
          }
        }]
      },
      logConfig: {
        fieldLogLevel: FieldLogLevel.ALL
      },
    });

    const channel = new ObjectType('Channel', {
      definition: {
        name: GraphqlType.string({ isRequired: true }),
        data: GraphqlType.awsJson({ isRequired: true }),
      },
    });

    const tableAttached = dynamodb.Table.fromTableArn(
      this, 
      'tableAttached-dynamoAggregatesPerSecondCrypto', 
      'arn:aws:dynamodb:us-east-1:995952994537:table/dynamoAggregatesPerSecondCrypto');

    const tableDatasource = api.addDynamoDbDataSource('ddb-datasource', 
      tableAttached,       
      {
        description: "DynamoDB Resolver Datasource",
    })

    api.addType(channel);

    api.addQuery('getChannel', new Field({
      returnType: channel.attribute()
    }));

    api.addMutation('publish2channel', new ResolvableField({
      returnType: channel.attribute(),
      args: { name: GraphqlType.string({ isRequired: true }), data: GraphqlType.awsJson({ isRequired: true }) },
      dataSource: api.addNoneDataSource('pubsub'),
      requestMappingTemplate: MappingTemplate.fromString(`
        {
          "version": "2017-02-28",
          "payload": {
              "name": "$context.arguments.name",
              "data": $util.toJson($context.arguments.data)
          }
        }`
      ),
      responseMappingTemplate: MappingTemplate.fromString(`$util.toJson($context.result)`)
    }))

    api.addSubscription('subscribe2channel', new Field({
      returnType: channel.attribute(),
      args: { name: GraphqlType.string({ isRequired: true }) },
      directives: [Directive.subscribe('publish2channel')],
    }));


    const aggregate = new ObjectType('Aggregate', {
      definition: {
        ev_pair: GraphqlType.string({ isRequired: false }),
        create_time: GraphqlType.awsTimestamp({ isRequired: false }),
        c: GraphqlType.float({ isRequired: false }),
        e: GraphqlType.awsTimestamp({ isRequired: false }),
        h: GraphqlType.float({ isRequired: false }),
        l: GraphqlType.float({ isRequired: false }),
        o: GraphqlType.float({ isRequired: false }),
        s: GraphqlType.awsTimestamp({ isRequired: false }),
        v: GraphqlType.float({ isRequired: false }),
        vw: GraphqlType.float({ isRequired: false }),
        z: GraphqlType.int({ isRequired: false }),
      },
    });
    api.addType(aggregate);

    const aggregateList = new ObjectType('AggregateList', {
      definition: {
        items: GraphqlType.intermediate({ 
          intermediateType: aggregate,
          isList: true,
        }),
      },
    });
    
    api.addType(aggregateList);

    api.addQuery('getAggregatesPerSecondCrypto', new Field({
      args: { ev_pair: GraphqlType.string({ isRequired: true }),
              limit: GraphqlType.int({ isRequired: false }) },
      returnType: aggregateList.attribute(),
    }));

    tableDatasource.createResolver({
      typeName: 'Query',
      fieldName: 'getAggregatesPerSecondCrypto',
      requestMappingTemplate: MappingTemplate.fromFile('lib/mapping-templates/Query.getCryptoAggregates.request.vtl'),
      responseMappingTemplate: MappingTemplate.fromFile('lib/mapping-templates/Query.getCryptoAggregates.response.vtl'),
    })

    api.addMutation('insertAggregatePerSecondCrypto', new Field({
      args: { 
        ev_pair: GraphqlType.string({ isRequired: true }),
        create_time: GraphqlType.awsTimestamp({ isRequired: true }),
        c: GraphqlType.float({ isRequired: true }),
        e: GraphqlType.awsTimestamp({ isRequired: true }),
        h: GraphqlType.float({ isRequired: true }),
        l: GraphqlType.float({ isRequired: true }),
        o: GraphqlType.float({ isRequired: true }),
        s: GraphqlType.awsTimestamp({ isRequired: true }),
        v: GraphqlType.float({ isRequired: true }),
        vw: GraphqlType.float({ isRequired: true }),
        z: GraphqlType.int({ isRequired: true }),
      },
      returnType: aggregate.attribute(),
    }));

    tableDatasource.createResolver({
      typeName: 'Mutation',
      fieldName: 'insertAggregatePerSecondCrypto',
      requestMappingTemplate: MappingTemplate.fromFile('lib/mapping-templates/Mutation.insertCryptoAggregate.request.vtl'),
      responseMappingTemplate: MappingTemplate.fromFile('lib/mapping-templates/Mutation.insertCryptoAggregate.response.vtl'),
    })

    api.addSubscription('subscribe2CryptoAggregates', new Field({
      returnType: aggregate.attribute(),
      args: { ev_pair: GraphqlType.string({ isRequired: true }) },
      directives: [Directive.subscribe('insertAggregatePerSecondCrypto')],
    }));

    new cdk.CfnOutput(this, 'graphqlUrl', { value: api.graphqlUrl })
    new cdk.CfnOutput(this, 'apiKey', { value: api.apiKey! })
    new cdk.CfnOutput(this, 'apiId', { value: api.apiId })
    new cdk.CfnOutput(this, 'region', { value: this.region })

  }
}
