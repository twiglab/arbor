package hdp

import "time"

const ads_sale_agg_per_day_sql = `
select store_code, store_name, cnt, qty, total from ads_sale_agg_per_day where dt = ? order by store_code
`

const ads_payment_agg_per_day_sql = `
select store_code, store_name, qty, total from ads_payment_agg_per_day where dt = ? order by store_code
`

const ads_fee_agg_per_day_sql = `
select store_code, store_name, t4 from ads_fee_agg_per_day where dt = ? order by store_code
`

const g_gm_entry_sql = `
select store_code, store_name, in_total from g_gm_entry where dt = ? order by store_code
`

func DayBeginEnd(t time.Time) (begin time.Time, end time.Time) {
	today := time.Date(t.Year(), t.Month(), t.Day(), 0, 0, 0, 0, t.Location())
	next := today.Add(24 * time.Hour)
	return today, next
}

func Yestoday(now time.Time) time.Time {
	return now.Add(-1 * 24 * time.Hour)
}

func DT(t time.Time) string {
	return t.Format("20060102")
}
