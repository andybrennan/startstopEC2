import boto3

def lambda_handler(event, context):
    '''
    event (dict):
        action: 'start' or 'stop'
        region: The region the instance(s) reside in
        instances: List of instance to action
    '''
    try:
        region = event['region']
        ec2 = boto3.client('ec2', region_name=region)
    
        running_instances = ec2.describe_instances(
            Filters=[
                {
                    'Name': 'tag:Name',
                    'Values': event['instances']
                }
            ]
        )

        print(f'Running instances: {running_instances}')
        print(event)

        instance_ids = []
        for reservation in running_instances['Reservations']:
            for instance in reservation['Instances']:
                instance_ids.append(instance['InstanceId'])

        print(f'Running instances: {instance_ids}')

        for id in instance_ids:
            if event['action'] == 'stop':
                ec2.stop_instances(InstanceIds=[id])
                print(f'stopped instance: {id}')
            elif event['action'] == 'start':
                ec2.start_instances(InstanceIds=[id])
                print(f'started instance: {id}')
    except KeyError:
        print("Key error! Event json:")
        print(f'{event}')
