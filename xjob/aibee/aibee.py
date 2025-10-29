import httpx


def traffic_summary():
    pass


params = {"key1": "value1", "key2": "value2"}
r = httpx.get("", params=params)

print(r.url)
