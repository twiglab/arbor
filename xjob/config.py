from functools import lru_cache

from pydantic import BaseModel
from pydantic_settings import (
    BaseSettings,
    PydanticBaseSettingsSource,
    SettingsConfigDict,
    TomlConfigSettingsSource,
)


class ExecConfig(BaseModel):
    host: str = "0.0.0.0"
    port: int = 10011
    url: str = "http://localhost:10011"
    key: str = "arbor-xjob"


class XXLConfig(BaseModel):
    baseurl: str
    token: str = "default_token"


class DBConfig(BaseModel):
    name: str
    url: str


class AibeeConfig(BaseModel):
    url: str
    db: DBConfig


class AppSettings(BaseSettings):
    aibee: AibeeConfig
    xxl: XXLConfig
    exec: ExecConfig

    model_config = SettingsConfigDict(
        toml_file=("abg.toml", "xjob.toml"),
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


if __name__ == "__main__":
    print(settings)
