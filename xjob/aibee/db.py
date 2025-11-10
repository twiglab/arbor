from datetime import datetime

from sqlalchemy import DateTime, String
from sqlalchemy.ext.asyncio import (
    AsyncAttrs,
    AsyncEngine,
    AsyncSession,
    async_sessionmaker,
    create_async_engine,
)
from sqlalchemy.orm import DeclarativeBase, Mapped, mapped_column

from ..config import settings


def make_engine() -> AsyncEngine:
    return create_async_engine(
        url=settings.aibee.db.url,
        pool_size=10,
        max_overflow=30,
        pool_recycle=60 * 30,
        echo=True,
        future=True,
    )


engine = make_engine()

Session = async_sessionmaker[AsyncSession](
    bind=engine,
    class_=AsyncSession,
    autoflush=False,
    expire_on_commit=False,
)


class Base(AsyncAttrs, DeclarativeBase):
    created_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.now)


class GmEntry(Base):
    __tablename__ = "g_gm_entry"

    pk: Mapped[str] = mapped_column(String(64), primary_key=True)
    store_code: Mapped[str] = mapped_column(String(64))
    dt: Mapped[str] = mapped_column(String(64), unique=True)
    in_total: Mapped[int] = mapped_column(default=0)
    store_name: Mapped[str] = mapped_column(String(64))


def make_pk(store_code: str, dt: str) -> str:
    return f"{store_code}-{dt}-in"


async def merge_entry(store_code: str, dt: str, in_total: int, store_name: str) -> None:
    async with Session() as session:
        async with session.begin():
            await session.merge(
                GmEntry(
                    pk=make_pk(store_code, dt),
                    store_code=store_code,
                    dt=dt,
                    in_total=in_total,
                    store_name=store_name,
                )
            )
