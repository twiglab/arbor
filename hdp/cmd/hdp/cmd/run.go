/*
Copyright © 2025 NAME HERE <EMAIL ADDRESS>
*/
package cmd

import (
	"context"
	"database/sql"
	"net/http"

	"github.com/it512/xxl-job-exec"
	"github.com/spf13/cobra"
	"github.com/spf13/viper"
	"github.com/twiglab/arbor/hdp"
	"github.com/xen0n/go-workwx/v2"
)

// runCmd represents the run command
var runCmd = &cobra.Command{
	Use:   "run",
	Short: "A brief description of your command",
	Long: `A longer description that spans multiple lines and likely contains examples
and usage of using your command. For example:

Cobra is a CLI library for Go that empowers applications.
This application is a tool to generate the needed files
to quickly create a Cobra application.`,
	RunE: func(cmd *cobra.Command, args []string) error {
		return run()
	},
}

func init() {
	rootCmd.AddCommand(runCmd)
}

func run() error {
	exec := xxl.NewExecutor(
		xxl.ServerAddr(viper.GetString("xxl.url")),
		xxl.AccessToken(viper.GetString("xxl.token")),
		xxl.RegistryKey(viper.GetString("xxl.key")),
		xxl.ExecutorURL(viper.GetString("xxl.local.url")),
	)
	exec.Start()
	defer func() { _ = exec.Stop() }()

	db, err := sql.Open(
		viper.GetString("hdp.db.name"),
		viper.GetString("hdp.db.dsn"),
	)
	if err != nil {
		return err
	}
	defer db.Close()

	q := hdp.NewStore(db)

	wx := workwx.New(viper.GetString("hdp.wxapp.corp"))
	app := wx.WithApp(
		viper.GetString("hdp.wxapp.secret"),
		viper.GetInt64("hdp.wxapp.agent"),
	)
	app.SpawnAccessTokenRefresher()

	j := &hdp.App{
		Store: q,
		App:   app,
		Tpl:   hdp.AppTpl(),
	}

	exec.RegTask(j.Name(), task(j))

	if err := http.ListenAndServe(":10008", exec.Handle("/hdp")); err != nil {
		return err
	}

	return nil

}

func task(app *hdp.App) xxl.TaskFunc {
	return func(ctx context.Context, task *xxl.Task) error {
		return app.Run(ctx, task)
	}
}
