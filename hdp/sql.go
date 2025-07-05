package hdp

import "time"

const xsql = `
SELECT
  storecode, storeName,
  count(*), sum(qty), sum(productTotal),
  date_format(beginDate, '%Y-%m-%d')
FROM
  cre.m3salesinput
where
  beginDate > ? and beginDate < ? and
  processStartState = 'submitted'
group by
  storecode
`

// -----------------------------------
const ysql = `
SELECT
  storecode, storeName,
  floorCode,floorName,
  count(*), sum(qty) as sum, sum(productTotal) as total, date_format(beginDate, '%Y-%m-%d') as date
FROM
  cre.m3salesinput
where
  beginDate > ? and beginDate < ?
  and processStartState = 'submitted'
group by
  storecode, floorCode
order by
  floorCode
`

func DayBeginEnd(t time.Time) (begin time.Time, end time.Time) {
	today := time.Date(t.Year(), t.Month(), t.Day(), 0, 0, 0, 0, t.Location())
	next := today.Add(24 * time.Hour)
	return today, next
}

func Yestoday(now time.Time) time.Time {
	return now.Add(-1 * 24 * time.Hour)
}
