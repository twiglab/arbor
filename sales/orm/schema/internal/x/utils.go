package x

import (
	"github.com/google/uuid"
	"github.com/shopspring/decimal"
)

func Code36() string {
	return uuid.Must(uuid.NewV7()).String()
}

func ZeroDecmial() decimal.Decimal {
	return decimal.Zero
}
