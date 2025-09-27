package hdp

import (
	"cmp"
	"fmt"
	"slices"
	"text/template"
	"time"
)

const Tpl = `
{{ .Yestoday.Format "2006.01.02" }} {{ .Yestoday | weekday }}
{{ range .Records }}
>{{ .Sale.StoreName }} {{ .Sale.Cnt }} 个商户，上报 {{ .Sale.Qty }} 单，销售额 <font color="warning"> {{ .Sale.Total | wan }} </font>万元
>>截至当日欠款总计 <font color="warning"> {{.Fee.T4 | wan}} </font> 万元
>>当日核销 {{.Pay.Qty}} 笔，共<font color="warning"> {{.Pay.Total | wan}} </font> 万元
{{ end }}
>宜悦城客流 {{.Others.yyc.InTotal}} 人次
`

/*
<font color="warning">
</font>
*/

type Record struct {
	Fee  FeeRecord
	Pay  PaymentRecord
	Sale SaleRecord
	Gm   GmEntryRecord
}

type Outline struct {
	Yestoday time.Time

	fee  []FeeRecord
	pay  []PaymentRecord
	sale []SaleRecord
	gm   []GmEntryRecord

	Others map[string]any
}

func (o Outline) Records() (rs []Record) {

	for _, x := range o.sale {
		var r Record
		r.Sale = x

		if i, ok := slices.BinarySearchFunc(o.fee, x.StoreCode, func(fr FeeRecord, k string) int { return cmp.Compare(fr.StoreCode, k) }); ok {
			r.Fee = o.fee[i]
		}

		if i, ok := slices.BinarySearchFunc(o.pay, x.StoreCode, func(pr PaymentRecord, k string) int { return cmp.Compare(pr.StoreCode, k) }); ok {
			r.Pay = o.pay[i]
		}

		rs = append(rs, r)
	}

	return
}

func MakeOutline(t time.Time, fee []FeeRecord, pay []PaymentRecord, sale []SaleRecord, gm []GmEntryRecord) Outline {
	return Outline{Yestoday: t, fee: fee, pay: pay, sale: sale, gm: gm, Others: make(map[string]any)}
}

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

func wan(total float64) string {
	return fmt.Sprintf("%.2f", total/10000)
}

func AppTpl() *template.Template {
	tpl, _ := template.New("tpl").
		Funcs(template.FuncMap{
			"weekday": weekday,
			"wan":     wan,
		}).Parse(Tpl)
	return tpl
}
