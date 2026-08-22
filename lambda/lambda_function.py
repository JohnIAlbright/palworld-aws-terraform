import boto3
import time

ec2 = boto3.client("ec2")
ssm = boto3.client("ssm")

INSTANCE_ID = os.environ["INSTANCE_ID"]

def lambda_handler(event, context):

    # Check the current EC2 state
    response = ec2.describe_instances(
        InstanceIds=[INSTANCE_ID]
    )

    state = response["Reservations"][0]["Instances"][0]["State"]["Name"]

    # Nothing to do if the instance isn't running
    if state != "running":
        return {
            "statusCode": 200,
            "message": f"{INSTANCE_ID} is currently {state}. No shutdown required."
        }

    # Gracefully stop Palworld through Systems Manager
    command = ssm.send_command(
        InstanceIds=[INSTANCE_ID],
        DocumentName="AWS-RunShellScript",
        Parameters={
            "commands": [
                "sudo systemctl stop palworld"
            ]
        }
    )

    command_id = command["Command"]["CommandId"]

    # Allow Palworld time to finish shutting down
    time.sleep(15)

    result = ssm.get_command_invocation(
        CommandId=command_id,
        InstanceId=INSTANCE_ID
    )

    if result["Status"] != "Success":
        raise Exception(
            f"Palworld shutdown command failed: {result['Status']}"
        )

    # Stop the EC2 instance
    ec2.stop_instances(
        InstanceIds=[INSTANCE_ID]
    )

    return {
        "statusCode": 200,
        "message": f"Palworld stopped gracefully and EC2 stop requested for {INSTANCE_ID}"
    }
