import httpx


async def _traffic_summary(params: list) -> int:
    async with httpx.AsyncClient() as client:
        r = await client.get("https://face-event-api.aibee.cn/traffic_summary", params=params)

    list = r.json()["data"]["list"]
    xx = (x["trafficIn"] for x in list)

    return sum(xx)
