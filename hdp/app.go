package hdp

import (
	"context"
	"encoding/json"
	"fmt"
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
	return "hdpapp"
}

func (b *App) Run(ctx context.Context, req *xxl.RunReq) (fmt.Stringer, error) {

	var param AppParam
	if err := json.Unmarshal([]byte(req.ExecutorParams), &param); err != nil {
		return xxl.JobRtn(err)
	}

	yestoday := Yestoday(time.Now())
	a, err := b.Store.StoreOutline(ctx, yestoday)
	if err != nil {
		return xxl.JobRtn(err)
	}

	root := map[string]any{
		"outlines": a,
		"yestoday": yestoday,
	}

	var sb strings.Builder
	sb.Grow(1024)
	if err = b.Tpl.Execute(&sb, root); err != nil {
		return xxl.JobRtn(err)
	}

	err = b.App.SendMarkdownMessage(&workwx.Recipient{TagIDs: param.Tags}, sb.String(), false)

	return xxl.JobRtn(err)
}

func (a *App) OnIncomingMessage(msg *workwx.RxMessage) error {
	return nil
}
