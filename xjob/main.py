import json

from pyxxl import ExecutorConfig, PyxxlRunner
from pyxxl.ctx import g

from xjob import aibee

config = ExecutorConfig(
    xxl_admin_baseurl="http://localhost:8080/xxl-job-admin/api/",
    executor_app_name="xxx",
    dotenv_path=".env",
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
