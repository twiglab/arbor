package hdp

import (
	"context"
	"encoding/json"
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

func (b *App) Run(ctx context.Context, task *xxl.Task) error {

	var param AppParam
	if err := json.Unmarshal([]byte(task.Param.ExecutorParams), &param); err != nil {
		return err
	}

	yestoday := Yestoday(time.Now())
	a, err := b.Store.StoreOutline4(ctx, yestoday)
	if err != nil {
		return err
	}

	root := map[string]any{
		"outlines": a,
		"yestoday": yestoday,
	}

	var sb strings.Builder
	sb.Grow(1024)
	if err = b.Tpl.Execute(&sb, root); err != nil {
		return err
	}

	err = b.App.SendMarkdownMessage(&workwx.Recipient{TagIDs: param.Tags}, sb.String(), false)

	return err
}

func (a *App) OnIncomingMessage(msg *workwx.RxMessage) error {
	return nil
}
