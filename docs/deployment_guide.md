Deploying the Flapping Container Detector should be easy!

You will need Terraform installed (`brew install terraform`) - All testing was done with Terraform 0.11.7

You will need your AWS CLI configured with a profile. (`brew install aws-cli` | `aws configure --profile YOUR_PROFILE_NAME`)

### Step 1
Go through your `config.tfvars` file and configure your Flapping container detector as you'd like. Most of the default
values are reasonable.


### Step 2

Run Terraform apply with your config file: `terraform apply -var-file config.tfvars`

When prompted for your `default_profile` input the profile associated with the account that has the ECS clusters running
that you want to monitor.

Decision, Choose A or B then continue:

A) Create a new bucket to deploy the lambda to:
- Run this command: `terraform apply -var-file config.tfvars -target=aws_s3_bucket.lambda_bucket`
- Type `yes` when prompted
 
B) Use an existing bucket.
- Comment out the contents of buckets.tf and update your config.tfvars / `lambda_bucket_id` property to the bucket you want to deploy lambdas to.
    
### Step 3 

Build & Deploy Your lambda: `./build_and_deploy.sh your_aws_profile_name`

This will build your lambda, zip it, take a hash of it, and push it to your selected bucket.

### Step 4 

Use terraform to deploy everything else: `terraform apply -var-file config.tfvars`
- Input the `profile_name` of the AWS account that has the ECS clusters running that you want to monitor
- Type `yes` when prompted

After Terrafrom has done provisioning resources, you should see something like this at the bottom of your output:

`api_gateway_url = https://somepath.execute-api.us-east-1.amazonaws.com/dev`

Keep this URL, you'll need it.

Head back over to the [Slack Setup Guide](slack_app_setup.md#step-4-configure-your-api-callback-endpoint "Slack App Setup") with this URL and continue on Step 4!