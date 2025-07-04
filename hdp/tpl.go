package hdp

import (
	"text/template"
	"time"
)

const msgTpl = `
{{ .R.ProjName }} {{ .R.Date.Format "2006.01.02" }} {{ .R.Date | weekday}}
{{.W.DayWeather}} - {{ .W.NightWeather }} {{.W.NightTemp}}~{{.W.DayTemp}}度
>总客流为：<font color="warning"> {{ .R.Total }} </font>，晚间（20~22点）：<font color="warning"> {{ .R.Night }} </font>
>上周：<font color="warning"> {{ .R.BeforWeekDay }} </font>
`

const msgTpl2 = `
{{ .yestoday.Format "2006.01.02" }} {{ .yestoday | weekday}}
{{ range .outlines }}
>{{ .StoreName }} 上报商户{{ .Num }}个，总单量 {{ .Qry }} 单， 总销售额 {{ .Total }} 元
{{ end }}
`

func weekday(t time.Time) string {
	w := t.Weekday()
	switch w {
	case time.Monday:
		return "周一"
	case time.Tuesday:
		return "周二"
	case time.Wednesday:
		return "周三"
	case time.Thursday:
		return "周四"
	case time.Friday:
		return "周五"
	case time.Saturday:
		return "周六"
	case time.Sunday:
		return "周日"
	}
	return ""
}

func AppTpl() *template.Template {
	tpl, _ := template.New("tpl").
		Funcs(template.FuncMap{"weekday": weekday}).
		Parse(msgTpl2)
	return tpl
}
