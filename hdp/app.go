package hdp

import (
	"context"
	"fmt"
	"strings"
	"text/template"
	"time"

	"github.com/it512/xxl-job-exec"
	"github.com/xen0n/go-workwx/v2"
)

type HDPApp struct {
	App *workwx.WorkwxApp

	Store *HDPStore

	Tpl *template.Template
}

func (b *HDPApp) Name() string {
	return "hdpapp"
}

func (b *HDPApp) Run(ctx context.Context, req *xxl.RunReq) (fmt.Stringer, error) {

	/*
		if err := json.Unmarshal([]byte(req.ExecutorParams), &jp); err != nil {
			return nil, err
		}
	*/

	a, err := b.Store.StoreOutline(ctx)
	if err != nil {
		return xxl.JobRtn(err)
	}

	root := map[string]any{
		"outlines": a,
		"Date":     time.Now().Add(-1 * 24 * time.Hour),
	}

	var sb strings.Builder
	sb.Grow(512)
	if err = b.Tpl.Execute(&sb, root); err != nil {
		return nil, err
	}

	err = b.App.SendMarkdownMessage(&workwx.Recipient{TagIDs: []string{"1"}}, sb.String(), false)

	return xxl.JobRtn(err)
}

func (a *HDPApp) OnIncomingMessage(msg *workwx.RxMessage) error {
	return nil
}
