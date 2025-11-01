import arrow

from .aibee import _traffic_summary


async def job(**kwargs):
    yestoday = arrow.now().shift(days=-1).format("YYYY-MM-DD")

    p = [
        ("startTime", yestoday),
        ("endTime", yestoday),
        ("entityType", 70),
        ("interval", "D"),
        ("token", kwargs["token"]),
        ("mall_id", kwargs["mall_id"]),
    ]

    i = await _traffic_summary(p)

    print(i)
