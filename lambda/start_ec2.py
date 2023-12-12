import boto3
region = 'us-west-1'
instances = ['i-YOUR_INSTANCEID_HERE']
ec2 = boto3.client('ec2', region_name=region)

def lambda_handler(event, context):
    ec2.start_instances(InstanceIds=instances)
    print('started your instances: ' + str(instances))