## Usage
Installazion on Mac

### Prerequisites
* [Installing the AWS SAM CLI](https://docs.aws.amazon.com/serverless-application-model/latest/developerguide/install-sam-cli.html)
* [Installing the Docker](https://www.docker.com/)
* [Installing the Julia-1.6.2](https://julialang.org/downloads/oldreleases/)

For mac computers with Apple silicon, Julia 1.6.2 only provide x86_64 aichitecture, hence rosetta should also be installed to run x86_64 Julia.

### 
Running docker

```bash
sam build
```
Folder .aws-sam will be generated

```bash
sam deploy --guided
```

configure the constant.jl file
```julia
AUTH_PARAM=API_KRY 
# this is acquired from the Polygon.io -> dashboard -> API Keys
```


install CDK
```bash
mkdir cdk-ts
cd cdk-ts
cdk init app --language typescript
cd CDK
npm install
cdk deploy
```
export schema add to client folder

amplify add codegen --apiId o3wpf56iyfaelo25jmaxexh2va


This is with various AWS resources version