import json

from pyxxl import ExecutorConfig, PyxxlRunner
from pyxxl.ctx import g

from xjob import aibee
from xjob.config import settings

config = ExecutorConfig(
    xxl_admin_baseurl=settings.xxl.baseurl,
    access_token=settings.xxl.token,
    executor_app_name=settings.exec.key,
    executor_listen_host=settings.exec.host,
    executor_listen_port=settings.exec.port,
    executor_url=settings.exec.url,
)


app = PyxxlRunner(config)


@app.register(name="abc")
async def abc():
    params_str = g.xxl_run_data.executorParams

    if not params_str:
        return "未提供参数"

    p = json.loads(params_str)

    param = {
        "store_code": p["store_code"],
        "store_name": p["store_name"],
        "token": p["token"],
        "mall_id": p["mall_id"],
    }

    return await aibee.job(**param)


app.run_executor()
