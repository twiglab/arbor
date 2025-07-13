package serv

import (
	"context"
	"fmt"
	"log"
	"net/http"
	"os"

	"github.com/go-chi/chi/v5"
	"github.com/go-chi/chi/v5/middleware"
	"github.com/it512/xxl-job-exec"
	"github.com/spf13/cobra"
	"github.com/spf13/viper"
	"github.com/twiglab/arbor/hdp"
	"gopkg.in/yaml.v3"
)

var ServCmd = &cobra.Command{
	Use:   "serv",
	Short: "A brief description of your command",
	Long: `A longer description that spans multiple lines and likely contains examples
and usage of using your command. For example:
to quickly create a Cobra application.`,
	Run: func(cmd *cobra.Command, args []string) {
		run()
	},
}
var cfgFile string

func init() {
	cobra.OnInitialize(initConfig)
	ServCmd.PersistentFlags().StringVarP(&cfgFile, "config", "c", "", "config file")
}

func initConfig() {
	if cfgFile != "" {
		viper.SetConfigFile(cfgFile)
	} else {
		viper.SetConfigType("yaml")
	}

	viper.AutomaticEnv()

	if err := viper.ReadInConfig(); err == nil {
		fmt.Fprintln(os.Stderr, "Using config file:", viper.ConfigFileUsed())
	}
}

func task(app *hdp.App) xxl.TaskFunc {
	return func(ctx context.Context, task *xxl.Task) error {
		return app.Run(ctx, task)
	}
}

func printConf(conf AppConf) {
	enc := yaml.NewEncoder(os.Stdout)
	enc.SetIndent(2)
	enc.Encode(conf)
	enc.Close()
}

func run() {
	var conf AppConf
	if err := viper.Unmarshal(&conf); err != nil {
		log.Fatal(err)
	}

	printConf(conf)

	exec := buildLocalExec(conf)

	app := buildApp(conf)
	exec.RegTask(app.Name(), task(app))

	exec.Start()
	defer exec.Stop()

	mux := chi.NewMux()
	mux.Use(middleware.Logger, middleware.Recoverer)
	mux.Mount("/xxl-job", exec.Handle("xxl-job"))

	if err := http.ListenAndServe(conf.ServerConf.Addr, mux); err != nil {
		log.Fatal(err)
	}
}
