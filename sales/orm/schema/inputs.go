package schema

import (
	"entgo.io/ent"
	"entgo.io/ent/dialect"
	"entgo.io/ent/dialect/entsql"
	"entgo.io/ent/schema"
	"entgo.io/ent/schema/field"
	"entgo.io/ent/schema/index"
	"entgo.io/ent/schema/mixin"
	"github.com/shopspring/decimal"
	"github.com/twiglab/arbor/sales/orm/schema/internal/x"
)

type Inputs struct {
	ent.Schema
}

func (Inputs) Fields() []ent.Field {
	return []ent.Field{

		field.String("id").DefaultFunc(x.Code36).Unique().Immutable().NotEmpty().
			SchemaType(map[string]string{
				dialect.MySQL:    "char(36)",
				dialect.Postgres: "char(36)",
				dialect.SQLite:   "char(36)",
			}),

		field.String("code").DefaultFunc(x.Code36).Unique().Immutable().NotEmpty().
			SchemaType(map[string]string{
				dialect.MySQL:    "varchar(36)",
				dialect.Postgres: "varchar(36)",
				dialect.SQLite:   "varchar(36)",
			}),

		field.String("sp_code").Immutable().NotEmpty().
			SchemaType(map[string]string{
				dialect.MySQL:    "varchar(36)",
				dialect.Postgres: "varchar(36)",
				dialect.SQLite:   "varchar(36)",
			}),

		field.String("op_day").MaxLen(8).Immutable().NotEmpty().
			SchemaType(map[string]string{
				dialect.MySQL:    "char(8)",
				dialect.Postgres: "char(8)",
				dialect.SQLite:   "char(8)",
			}),

		field.Float("amount").GoType(decimal.Zero).DefaultFunc(x.ZeroDecmial).
			SchemaType(map[string]string{
				dialect.MySQL:    "decimal(19,2)",
				dialect.Postgres: "decimal(19,2)",
				dialect.SQLite:   "decimal(19,2)",
			}),

		field.Int32("qty").Default(0).NonNegative(),
		field.Int32("sales_type").Default(0).Immutable().NonNegative().Min(0).Max(100),

		field.String("upload_file").MaxLen(256).
			SchemaType(map[string]string{
				dialect.MySQL:    "varchar(256)",
				dialect.Postgres: "varchar(256)",
				dialect.SQLite:   "varchar(256)",
			}),

		field.Int32("src").Default(0),
		field.Int32("status").Default(0),
	}
}

func (Inputs) Mixin() []ent.Mixin {
	return []ent.Mixin{
		mixin.Time{},
	}
}

func (Inputs) Indexes() []ent.Index {
	return []ent.Index{
		index.Fields("code").Unique(),
		index.Fields("sp_code"),
		index.Fields("op_day"),
		index.Fields("sales_type"),
	}
}

func (Inputs) Annotations() []schema.Annotation {
	return []schema.Annotation{
		entsql.Annotation{Table: "sales_inputs"},
	}
}
