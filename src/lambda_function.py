import boto3
import os
import json
from botocore.exceptions import ClientError
from datetime import datetime
import urllib3

http = urllib3.PoolManager()

EBS_PRICES = {
    "gp3": 0.08,
    "gp2": 0.10,
    "io1": 0.125,
    "io2": 0.125,
    "st1": 0.045,
    "sc1": 0.025,
}


def estimate_monthly_cost(volume):
    vol_type = volume.get("VolumeType", "gp2")
    size_gb = volume.get("Size", 0)

    price_per_gb = EBS_PRICES.get(vol_type, 0.10)
    return round(size_gb * price_per_gb, 2)


def send_to_discord(message: str):
    webhook_url = os.environ.get("DISCORD_WEBHOOK_URL")
    if not webhook_url:
        return

    chunks = [message[i : i + 1900] for i in range(0, len(message), 1900)]

    for chunk in chunks:
        payload = {"content": chunk, "username": "Cloud Janitor"}
        response = http.request(
            "POST",
            webhook_url,
            body=json.dumps(payload).encode("utf-8"),
            headers={"Content-Type": "application/json"},
        )

        if response.status >= 300:
            raise Exception(f"Discord webhook Error: {response.status}")


def get_regions():
    regions_env = os.environ.get("REGIONS", "us-east-1")

    if regions_env.upper() == "ALL":
        try:
            ec2_client = boto3.client("ec2", region_name="us-east-1")
            response = ec2_client.describe_regions()

            return [r["RegionName"] for r in response["Regions"]]
        except Exception as e:
            print(
                f"The region list could not be retrieved; the default us-east-1 is being used.: {e}"
            )
            return ["us-east-1"]

    return [r.strip() for r in regions_env.split(",") if r.strip()]


def lambda_handler(event, context):
    regions = get_regions()
    all_orphan_volumes = []

    try:
        for region in regions:
            ec2 = boto3.client("ec2", region_name=region)
            paginator = ec2.get_paginator("describe_volumes")

            for page in paginator.paginate(
                Filters=[{"Name": "status", "Values": ["available"]}]
            ):
                for vol in page.get("Volumes", []):
                    vol["Region"] = region
                    all_orphan_volumes.append(vol)

        if not all_orphan_volumes:
            send_to_discord(
                " **Cloud Janitor Report**\n"
                "All Regions are Clear. No available EBS volumes."
            )
            return {"status": "clean"}

        total_monthly_cost = 0.0

        lines = [
            " **Cloud Janitor Report: Unclaimed EBS Volumes detected.!** ",
            f"Number of regions scanned: **{len(regions)}**",
            f"Total number of disks: **{len(all_orphan_volumes)}**\n",
        ]

        for vol in all_orphan_volumes:
            cost = estimate_monthly_cost(vol)
            total_monthly_cost += cost

            lines.append(
                f"- 🌍 **{vol['Region']}** | "
                f"`{vol['VolumeId']}` | "
                f"{vol['Size']}GB | "
                f"{vol['VolumeType']} | "
                f"💰 **${cost}/ay** | "
                f"{vol['CreateTime'].strftime('%Y-%m-%d')}"
            )

        lines.append(
            f"\n💸 **Estimated total monthly cost:** **${round(total_monthly_cost, 2)}**"
        )

        send_to_discord("\n".join(lines))

        return {
            "status": "orphan_volumes_found",
            "count": len(all_orphan_volumes),
            "estimated_monthly_cost": round(total_monthly_cost, 2),
        }

    except ClientError as e:
        raise Exception(f"AWS API ERROR: {str(e)}")
