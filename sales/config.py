from functools import lru_cache

from pydantic import BaseModel
from pydantic_settings import (
    BaseSettings,
    PydanticBaseSettingsSource,
    SettingsConfigDict,
    TomlConfigSettingsSource,
)


class DBConfig(BaseModel):
    url: str


class SalesConfig(BaseModel):
    db: DBConfig


class AppSettings(BaseSettings):
    sales: SalesConfig

    model_config = SettingsConfigDict(
        toml_file=("sales.toml", "arbor.toml"),
        extra="ignore",
    )

    @classmethod
    def settings_customise_sources(
        cls,
        settings_cls: type[BaseSettings],
        init_settings: PydanticBaseSettingsSource,
        env_settings: PydanticBaseSettingsSource,
        dotenv_settings: PydanticBaseSettingsSource,
        file_secret_settings: PydanticBaseSettingsSource,
    ) -> tuple[PydanticBaseSettingsSource, ...]:
        return (
            env_settings,
            dotenv_settings,
            TomlConfigSettingsSource(settings_cls),
            file_secret_settings,
            init_settings,
        )


@lru_cache
def get_settings():
    return AppSettings()


settings = get_settings()
