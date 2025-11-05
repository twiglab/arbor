import arrow

from .aibee import _traffic_summary
from .db import merge_entry


async def job(**kwargs) -> str:
    yestoday = arrow.now().shift(days=-1)
    t = yestoday.format("YYYY-MM-DD")
    dt = yestoday.format("YYYYMMDD")

    p = [
        ("startTime", t),
        ("endTime", t),
        ("entityType", 70),
        ("interval", "D"),
        ("token", kwargs["token"]),
        ("mall_id", kwargs["mall_id"]),
    ]

    in_total = await _traffic_summary(p)

    await merge_entry(
        store_code=kwargs["store_code"],
        dt=dt,
        in_total=in_total,
        store_name=kwargs["store_name"],
    )

    return "OK"
