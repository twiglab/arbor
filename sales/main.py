import strawberry
from fastapi import FastAPI
from strawberry.fastapi import GraphQLRouter
from strawberry.schema.config import StrawberryConfig

from sales.graphql import queries

schema = strawberry.Schema(
    queries.Query,
    config=StrawberryConfig(
        auto_camel_case=False,
    ),
)

graphql_app = GraphQLRouter(
    schema,
    graphql_ide="graphiql",
)

app = FastAPI()
app.include_router(graphql_app, prefix="/graphql")
