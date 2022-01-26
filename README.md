# Terraform Starter

# Terraform Setup

Dependencies:

- install AWS CLI (<https://aws.amazon.com/cli/>)
- NodeJS (<https://nodejs.org/en/>)
- Docker
- Terraform
  - tfswitch (brew install tfswitch)
  - jq (brew install jq)

Make sure to update the config file located under the config directory for which env you want to deploy.

Set the local ENV and AWS_PROFILE to be used
  
```
export ENV=dev
export AWS_PROFILE=terraform-starter
```

# Development

Inside the api/cron folders, run ```npm install``` followed by ```npm run dev``` to start up the api server.

# Deploy

Prior to deployment, you need to manually create a S3 bucket, which will be used to store Terraform state files. This is the only interaction needed on AWS. Once you create the S3 bucket, edit the settings.json in the root of the project.

```
{
 "stateBucket": "terraform-api-state-bucket",
 "projectPrefix": "terraform",
 "primaryRegion": "us-east-2"
}
```

## Build Infrascture and Deploy API

```
make deploy
```

## Deploy API

```
make deploy-api
```