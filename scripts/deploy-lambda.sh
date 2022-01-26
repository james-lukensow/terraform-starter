
#!/bin/bash
set -ve

lambda=$1

bucket=$(jq -r .code_bucket_name.value ../infrastructure/.plan/output.json)
region=$(jq -r .region.value ../infrastructure/.plan/output.json)
functionName=$(jq -r ".[ \"${lambda}_lambda_function\" ].value" ../infrastructure/.plan/output.json)

pushd ./dest/$lambda
# hash=$(md5 -q index.js)
hash=code
zipPath=./$lambda.zip
zip -qr $zipPath .
key=$lambda/$hash.zip
aws s3 cp $zipPath s3://$bucket/$key
popd

echo ${bucket}
echo ${key}

json=$(aws lambda update-function-code --function-name $functionName --s3-bucket $bucket --s3-key $key --region $region)