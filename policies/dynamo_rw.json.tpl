{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "dynamodb:Get*",
        "dynamodb:List*",
        "dynamodb:Put*",
        "dynamodb:Delete*",
        "dynamodb:Query",
        "dynamodb:UpdateItem"
      ],
      "Effect": "Allow",
      "Resource": [
        "arn:aws:dynamodb:${region}:${account_id}:table/${dynamo_table}"
       ]
    }
  ]
}