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

func yestoday(now time.Time) (begin time.Time, end time.Time) {
	yestoday := now.Add(-1 * 24 * time.Hour)

	return time.Date(yestoday.Year(), yestoday.Month(), yestoday.Day(), 0, 0, 0, 0, now.Location()),
		time.Date(now.Year(), now.Month(), now.Day(), 0, 0, 0, 0, now.Location())
}
