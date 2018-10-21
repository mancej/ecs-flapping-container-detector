{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "OutOfVpcLambdaAccess",
      "Effect": "Allow",
      "Action": [
        "cloudwatch:Describe*",
        "cloudwatch:Get*",
        "cloudwatch:List*",
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "logs:TestMetricFilter"
      ],
      "Resource":"*"
    }
  ]
}