package orm

//go:generate go tool  entgo.io/ent/cmd/ent generate --feature sql/upsert,sql/execquery,privacy,entql ./schema --target ./ent
