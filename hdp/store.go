package hdp

import (
	"context"
	"database/sql"

	_ "github.com/go-sql-driver/mysql"
)

// ads_fee_agg_per_day
// ads_payment_agg_per_day
// ads_sale_agg_per_day
// g_gm_entry 客流采集

type SaleRecord struct {
	StoreCode string
	StoreName string

	Cnt int
	Qty float64

	Total float64
}

type PaymentRecord struct {
	StoreCode string
	StoreName string

	Qty   int
	Total float64
}

type FeeRecord struct {
	StoreCode string
	StoreName string

	T4 float64
}

type GmEntryRecord struct {
	StoreCode string
	StoreName string

	InTotal int
}

type Store struct {
	db *sql.DB
}

func NewStore(db *sql.DB) *Store {
	return &Store{db: db}
}

func (s *Store) SaleAgg(dt string) ([]SaleRecord, error) {
	rs, err := s.db.QueryContext(context.Background(), ads_sale_agg_per_day_sql, dt)
	if err != nil {
		return nil, err
	}
	defer rs.Close()

	var res []SaleRecord
	for rs.Next() {
		var sr SaleRecord
		err := rs.Scan(
			&sr.StoreCode,
			&sr.StoreName,
			&sr.Cnt,
			&sr.Qty,
			&sr.Total,
		)
		if err != nil {
			return res, err
		}
		res = append(res, sr)
	}
	return res, err
}

func (s *Store) PaymentAgg(dt string) ([]PaymentRecord, error) {
	rs, err := s.db.QueryContext(context.Background(), ads_payment_agg_per_day_sql, dt)
	if err != nil {
		return nil, err
	}
	defer rs.Close()

	var res []PaymentRecord
	for rs.Next() {
		var sr PaymentRecord
		err := rs.Scan(
			&sr.StoreCode,
			&sr.StoreName,
			&sr.Qty,
			&sr.Total,
		)
		if err != nil {
			return res, err
		}
		res = append(res, sr)
	}
	return res, err
}

func (s *Store) FeeAgg(dt string) ([]FeeRecord, error) {
	rs, err := s.db.QueryContext(context.Background(), ads_fee_agg_per_day_sql, dt)
	if err != nil {
		return nil, err
	}
	defer rs.Close()

	var res []FeeRecord
	for rs.Next() {
		var sr FeeRecord
		err := rs.Scan(
			&sr.StoreCode,
			&sr.StoreName,
			&sr.T4,
		)
		if err != nil {
			return res, err
		}
		res = append(res, sr)
	}
	return res, err
}

func (s *Store) GmEntry(dt string) ([]GmEntryRecord, error) {
	rs, err := s.db.QueryContext(context.Background(), g_gm_entry_sql, dt)
	if err != nil {
		return nil, err
	}
	defer rs.Close()

	var res []GmEntryRecord
	for rs.Next() {
		var sr GmEntryRecord
		err := rs.Scan(
			&sr.StoreCode,
			&sr.StoreName,
			&sr.InTotal,
		)
		if err != nil {
			return res, err
		}
		res = append(res, sr)
	}
	return res, err
}
