for entry in `ls dest`; do
    ../scripts/deploy-lambda.sh $entry
done