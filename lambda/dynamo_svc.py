from boto3.dynamodb.conditions import Key
from decimal import *
from config import *

event_lifetime_seconds = 60 * 60 * 24 * 7


class DynamoDao:
    def __init__(self, dynamo_resource, ssm_svc):
        self._dynamo_resource = dynamo_resource
        self._ssm = ssm_svc
        self._service_metrics = self._ssm.get_from_ps(SERVICE_METRICS_TABLE_NAME)
        self._service_metrics_pk = self._ssm.get_from_ps(SERVICE_METRICS_HASH_KEY_NAME)

    def get_service_metrics(self, service_name, run_env):
        table = self._dynamo_resource.Table(self._service_metrics)
        filter_exp = Key(f'{self._service_metrics_pk}').eq(f'{service_name}-{run_env}')
        result = table.query(KeyConditionExpression=filter_exp)
        items = {}

        if "Items" in result and len(result["Items"]) > 0:
            items = result["Items"][0]

        return items

    def put_service_metrics(self, service_name, run_env, props):
        table = self._dynamo_resource.Table(self._service_metrics)

        item = {
            f'{self._service_metrics_pk}': f'{service_name}-{run_env}',
        }

        for key in props:
            if key != f'{self._service_metrics_pk}' and not isinstance(props[key], float):
                item[key] = props[key]
            elif isinstance(props[key], float):
                item[key] = Decimal(f'{props[key]}')

        table.put_item(
            Item=item
        )
