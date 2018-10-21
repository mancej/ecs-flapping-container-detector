{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "InVpcLambdaAccess",
      "Effect": "Allow",
      "Action": [
        "ssm:GetParameter"
      ],
      "Resource":"arn:aws:ssm:${region}:${account_id}:parameter/devops/*"
    }
  ]
}