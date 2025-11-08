import orjson
import strawberry
from fastapi import FastAPI
from strawberry.fastapi import GraphQLRouter
from strawberry.schema.config import StrawberryConfig

from sales.graphql import Mutation, Query

schema = strawberry.federation.Schema(
    query=Query,
    mutation=Mutation,
    enable_federation_2=True,
    config=StrawberryConfig(
        auto_camel_case=False,
    ),
)


class MyGraphQLRouter(GraphQLRouter):
    def decode_json(self, data: str | bytes) -> object:
        return orjson.loads(data)


graphql_app = MyGraphQLRouter(
    schema,
    graphql_ide="graphiql",
)

app = FastAPI()
app.include_router(graphql_app, prefix="/graphql")
