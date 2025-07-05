package hdp

import (
	"context"
	"time"

	"github.com/twiglab/arbor/hdp/ent"
)

type OutlineItem struct {
	StoreCode string
	StoreName string
	FloorCode string
	FloorName string
	Num       int64
	Qry       float64
	Total     float64
	Date      string
}

type Outline struct {
	OutlineItem
	Subs []OutlineItem
}

type Store struct {
	client *ent.Client
}

func NewStore(client *ent.Client) *Store {
	return &Store{client: client}
}

func (x *Store) StoreOutline4(ctx context.Context, t time.Time) ([]*Outline, error) {
	s, e := DayBeginEnd(t)

	r1, err := x.client.QueryContext(ctx, xsql, s, e)
	if err != nil {
		return nil, err
	}
	defer r1.Close()

	var os []*Outline
	for r1.Next() {
		var outline Outline
		err := r1.Scan(
			&outline.StoreCode, &outline.StoreName,
			&outline.Num, &outline.Qry, &outline.Total,
			&outline.Date,
		)

		if err != nil {
			return nil, err
		}
		os = append(os, &outline)
	}

	rows2, err := x.client.QueryContext(ctx, ysql, s, e)
	if err != nil {
		return nil, err
	}
	defer rows2.Close()

	for rows2.Next() {
		var oitem OutlineItem
		err := rows2.Scan(
			&oitem.StoreCode, &oitem.StoreName,
			&oitem.FloorCode, &oitem.FloorName,
			&oitem.Num, &oitem.Qry, &oitem.Total,
			&oitem.Date,
		)

		if err != nil {
			return nil, err
		}

		for _, i := range os {
			if i.StoreCode == oitem.StoreCode {
				i.Subs = append(i.Subs, oitem)
			}
		}
	}

	return os, nil
}
