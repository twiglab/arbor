package hdp

import (
	"context"
	"strings"
	"text/template"
	"time"

	"github.com/it512/xxl-job-exec"
	"github.com/xen0n/go-workwx/v2"
)

type AppParam struct {
	Tags []string `json:"tags"`
}

type App struct {
	Store *Store
	App   *workwx.WorkwxApp
	Tpl   *template.Template
}

func (b *App) Name() string {
	return "boss"
}

func (b *App) Run(ctx context.Context, task *xxl.Task) error {
	var param AppParam
	if err := xxl.TaskJsonParam(task, &param); err != nil {
		return err
	}

	yestoday := Yestoday(time.Now())
	dt := DT(yestoday)

	payment, err := b.Store.PaymentAgg(dt)
	if err != nil {
		return err
	}

	fee, err := b.Store.FeeAgg(dt)
	if err != nil {
		return err
	}

	sale, err := b.Store.SaleAgg(dt)
	if err != nil {
		return err
	}

	gm, err := b.Store.GmEntry(dt)
	if err != nil {
		return err
	}

	outline := MakeOutline(Yestoday(time.Now()), fee, payment, sale, gm)
	outline.Others["yyc"] = gm[0]

	var sb strings.Builder
	sb.Grow(1024)
	if err = b.Tpl.Execute(&sb, outline); err != nil {
		return err
	}

	return b.App.SendMarkdownMessage(&workwx.Recipient{TagIDs: param.Tags}, sb.String(), false)
}

func (a *App) OnIncomingMessage(msg *workwx.RxMessage) error {
	return nil
}
