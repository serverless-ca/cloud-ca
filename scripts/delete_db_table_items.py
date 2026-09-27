from os import environ

from boto3 import client


def get_dynamo_db_table():
    """
    ARN and name of DynamoDB table
    """

    dynamodb_client = client("dynamodb")

    tables = dynamodb_client.list_tables()["TableNames"]
    tables = [t for t in tables if "CA" in t]

    # optional CA_PROJECT filter to target one of the CA deployments in the same account,
    # table names are PascalCase, e.g. project pqc, env dev -> PqcCADev
    project = environ.get("CA_PROJECT")
    if project:
        tables = [t for t in tables if t.startswith(project.title() + "CA")]

    # this script deletes all items from the table, so refuse to guess between candidates
    if len(tables) != 1:
        raise SystemExit(
            f"Expected exactly one CA DynamoDB table, found {tables or 'none'}: "
            "set CA_PROJECT to identify the target deployment"
        )

    return tables[0]


def delete_dynamo_db_table_items(table):
    """
    Delete all items from DynamoDB table
    """

    dynamodb_client = client("dynamodb")

    items = dynamodb_client.scan(TableName=table, Limit=500, Select="ALL_ATTRIBUTES")["Items"]

    for item in items:
        serial_number = item["SerialNumber"]["S"]  # sort key
        common_name = item["CommonName"]["S"]  # partition key
        print(f"Deleting DynamoDB item certificate serial number {serial_number}")
        composite_key_json = {"SerialNumber": {"S": serial_number}, "CommonName": {"S": common_name}}
        dynamodb_client.delete_item(TableName=table, Key=composite_key_json)


if __name__ == "__main__":
    table = get_dynamo_db_table()
    print(f"Deleting items from {table}...")
    delete_dynamo_db_table_items(table)
    print(f"Items from {table} deleted successfully")
