import httpx


def traffic_summary():
    pass


params = (
    ("mall_id", "JFCD_nanjing_zygc"),
    ("token", "TEtVNkkBaEYkq7shfRO0ABmVHpexJ12Z"),
    ("entityType", 70),
    ("startTime", "2025-10-28"),
    ("endTime", "2025-10-28"),
    ("interval", "D"),
)
r = httpx.get("https://face-event-api.aibee.cn/traffic_summary", params=params)

list = r.json()["data"]["list"]
xx = (x["trafficIn"] for x in list)
print(sum(xx))
