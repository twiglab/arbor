package hdp

import (
	"context"
	"database/sql"
	"time"

	"github.com/twiglab/arbor/hdp/ent"
)

type Outline struct {
	StoreCode string
	StoreName string
	Num       int64
	Qry       float64
	Total     float64
	Date      string
}

type HDPStore struct {
	client *ent.Client
}

func NewHDPStore(client *ent.Client) *HDPStore {
	return &HDPStore{client: client}
}

func (x *HDPStore) StoreOutline(ctx context.Context) ([]Outline, error) {
	s, e := yestoday(time.Now())
	a, err := x.client.QueryContext(ctx, xsql, s, e)

	if err != nil {
		return nil, err
	}
	defer a.Close()

	var os []Outline
	for a.Next() {
		outline, err := makeOutline(a)
		if err != nil {
			return nil, err
		}
		os = append(os, outline)
	}

	return os, nil
}

func makeOutline(row *sql.Rows) (Outline, error) {
	var outline Outline
	err := row.Scan(
		&outline.StoreCode, &outline.StoreName,
		&outline.Num, &outline.Qry, &outline.Total,
		&outline.Date,
	)
	return outline, err
}
