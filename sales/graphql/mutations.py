import strawberry

from ..schemas import SalesOrder, SalesOrderInput


@strawberry.type
class Mutation:
    @strawberry.mutation
    async def sales_create(self, input: SalesOrderInput) -> SalesOrder | None:
        return None
