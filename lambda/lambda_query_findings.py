
import boto3
import json
from datetime import datetime, timedelta

dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table('CSPMFindings')

def lambda_handler(event, context):
    params = event.get('queryStringParameters') or {}

    severity_filter = params.get('severity')
    resource_filter = params.get('resource_id')
    hours_back = int(params.get('hours', 24))

    now = datetime.utcnow()
    past = now - timedelta(hours=hours_back)
    past_iso = past.isoformat()

    scan_kwargs = {
        'FilterExpression': "Timestamp >= :timestamp",
        'ExpressionAttributeValues': {
            ":timestamp": {"S": past_iso}
        }
    }

    if severity_filter:
        scan_kwargs['FilterExpression'] += " AND Severity = :severity"
        scan_kwargs['ExpressionAttributeValues'][":severity"] = {"S": severity_filter}
    if resource_filter:
        scan_kwargs['FilterExpression'] += " AND ResourceId = :resource_id"
        scan_kwargs['ExpressionAttributeValues'][":resource_id"] = {"S": resource_filter}

    response = table.scan(**scan_kwargs)
    findings = response.get('Items', [])

    return {
        "statusCode": 200,
        "headers": {"Content-Type": "application/json"},
        "body": json.dumps(findings)
    }
