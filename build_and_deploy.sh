#!/usr/bin/env bash
# Builds the flapping container lambda and deploys it to the s3 bucket configured in config.tfvars
# Todo: Clean this the heck up...don't judge me.

. scripts/utils.sh

if [ "$#" != 1 ]; then
    e_error "Invalid parameters, requires: <aws profile>"
    e_notify " For example: ./build_and_deploy.sh default"
    exit 1
fi

profile=$1

S3_BUCKET=$(cat config.tfvars | grep "lambda_bucket_id" | sed -e 's/.*=.*"\(.*\)"/\1/g')
zip_name="flapping_container_detector"

originalDir=$PWD
mkdir -p lambda/build
cp lambda/*.py lambda/build/
cd lambda/
pip install -r requirements.txt -t build/
cd build/
zip -r ${zip_name}.zip *
mv ${zip_name}.zip ${originalDir}/${zip_name}.zip
cd ${originalDir}

# Get SHA256 of function, so we can track changes, write to file.
openssl dgst -sha256 -binary ${zip_name}.zip | openssl enc -base64 > flapping_container_detector.zip.sha256
aws s3 cp ${zip_name}.zip s3://${S3_BUCKET}/lambdas/${zip_name}.zip --profile ${profile}
aws s3 cp ${zip_name}.zip.sha256 s3://${S3_BUCKET}/lambdas/${zip_name}.zip.sha256 --content-type text/plain --profile ${profile}
e_notify "${zip_name}.zip copied to S3 successfully"

rm -rf lambda/build
rm ${zip_name}.zip
rm ${zip_name}.zip.sha256