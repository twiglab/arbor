package scalar

import (
	"fmt"

	"github.com/99designs/gqlgen/graphql"
	"github.com/shopspring/decimal"
)

func MarshalDecimal(d decimal.Decimal) graphql.Marshaler {
	return graphql.MarshalString(d.String())
}

func UnmarshalDecimal(v any) (decimal.Decimal, error) {
	switch x := v.(type) {
	case string:
		return decimal.NewFromString(x)
	case int64:
		return decimal.NewFromInt(x), nil
	case float64:
		return decimal.NewFromFloat(x), nil
	default:
		return decimal.Zero, fmt.Errorf("%T is not a decimal", v)
	}
}
