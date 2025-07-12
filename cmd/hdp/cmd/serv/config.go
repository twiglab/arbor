package serv

import (
	"log"
	"net/http"
	"os"

	"github.com/it512/xxl-job-exec"
	"github.com/spf13/cobra"
	"github.com/twiglab/arbor/hdp"
	"github.com/xen0n/go-workwx/v2"
	"gopkg.in/yaml.v3"
)

// configCmd represents the config command
var ConfigCmd = &cobra.Command{
	Use:   "config",
	Short: "A brief description of your command",
	Long: `A longer description that spans multiple lines and likely contains examples
and usage of using your command. For example:

Cobra is a CLI library for Go that empowers applications.
This application is a tool to generate the needed files
to quickly create a Cobra application.`,
	Run: func(cmd *cobra.Command, args []string) {
		c()
	},
}

type XxlJobConf struct {
	ServerAddr  string `yaml:"server-addr" mapstructure:"server-addr"`
	AccessToken string `yaml:"access-token" mapstructure:"access-token"`
	ExecutorURL string `yaml:"executor-url" mapstructure:"executor-url"`
	RegistryKey string `yaml:"registry-key" mapstructure:"registry-key"`
}

type LoggerConf struct {
	Level   string `yaml:"level" mapstructure:"level"`
	LogFile string `yaml:"log-file" mapstructure:"log-file"`
}

type ServerConf struct {
	Addr string `yaml:"addr" mapstructure:"addr"`
}

type AppConf struct {
	ID         string
	LoggerConf LoggerConf `yaml:"log" mapstructure:"log"`
	ServerConf ServerConf `yaml:"server" mapstructure:"server"`
	XxlJobConf XxlJobConf `yaml:"xxl" mapstructure:"xxl"`
	WxAppConf  WxAppConf  `yaml:"wxapp" mapstructure:"wxapp"`
	DBConf     DBConf     `yaml:"db" mapstructure:"db"`
	xx         xxl.Options
}

type WxAppConf struct {
	CorpID           string           `yaml:"corp-id" mapstructure:"corp-id"`
	CorpSecret       string           `yaml:"corp-secret" mapstructure:"corp-secret"`
	AgentID          int64            `yaml:"agent-id" mapstructure:"agent-id"`
	WxAppReceiveConf WxAppReceiveConf `yaml:"receive" mapstructure:"receive"`
}

type WxAppReceiveConf struct {
	Token  string `yaml:"token" mapstructure:"token"`
	AESKey string `yaml:"aes-key" mapstructure:"aes-key"`
}

type DBConf struct {
	Name string `yaml:"name" mapstructure:"name"`
	DSN  string `yaml:"dsn" mapstructure:"dsn"`
}

func buildApp(conf AppConf) *hdp.App {

	wx := workwx.New(conf.WxAppConf.CorpID)
	app := wx.WithApp(conf.WxAppConf.CorpSecret, conf.WxAppConf.AgentID)
	app.SpawnAccessTokenRefresher()

	client, err := hdp.OpenClient(conf.DBConf.Name, conf.DBConf.DSN)
	if err != nil {
		log.Fatal(err)
	}

	s := hdp.NewStore(client)
	return &hdp.App{
		App:   app,
		Store: s,
		Tpl:   hdp.AppTpl(),
	}
}

func buildHandle(conf AppConf, h workwx.RxMessageHandler) http.Handler {
	x, err := workwx.NewHTTPHandler(
		conf.WxAppConf.WxAppReceiveConf.Token,
		conf.WxAppConf.WxAppReceiveConf.AESKey, h,
	)
	if err != nil {
		log.Fatal(err)
	}
	return x
}

func buildLocalExec(conf AppConf) *xxl.Executor {
	exec := xxl.NewExecutor(
		xxl.ServerAddr(conf.XxlJobConf.ServerAddr),
		xxl.AccessToken(conf.XxlJobConf.AccessToken),
		xxl.RegistryKey(conf.XxlJobConf.RegistryKey),
	)
	return exec
}

func c() {
	conf := AppConf{
		ID: "gbot",
		LoggerConf: LoggerConf{
			Level:   "INFO",
			LogFile: "console",
		},
		ServerConf: ServerConf{
			Addr: ":10009",
		},
		XxlJobConf: XxlJobConf{
			ServerAddr:  "http://127.0.0.1:8080/xxl-job-admin",
			ExecutorURL: "http://127.0.0.1:10009/",
			AccessToken: "token",
			RegistryKey: "puppy",
		},
		WxAppConf: WxAppConf{
			CorpID:     "12345",
			CorpSecret: "45679",
			AgentID:    1000013,
			WxAppReceiveConf: WxAppReceiveConf{
				Token:  "abcde",
				AESKey: "xxxxx",
			},
		},
		DBConf: DBConf{
			Name: "mysql",
			DSN:  "root:xxxxx@tcp(127.0.0.1:3306)/yyy",
		},
	}
	enc := yaml.NewEncoder(os.Stdout)
	enc.SetIndent(2)
	enc.Encode(&conf)
}
