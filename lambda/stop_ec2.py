import boto3
region = 'eu-west-1'
ec2 = boto3.client('ec2', region_name=region)

def lambda_handler(event, context):
    running_instances = ec2.describe_instances(
        Filters=[
            {
                'Name': 'tag:Name',
                'Values': [
                    'Example*'
                ],
            }
        ]
    )

    instance_ids = []
    for reservation in running_instances['Reservations']:
        for instance in reservation['Instances']:
            instance_ids.append(instance['InstanceId'])

    for id in instance_ids:
        ec2.stop_instances(InstanceIds=[id])
        print('stopped your instances: ' + str(instances))
