package cmd

import (
	"os"

	"github.com/spf13/cobra"
	"github.com/twiglab/arbor/cmd/hdp/cmd/serv"
)

// rootCmd represents the base command when called without any subcommands
var rootCmd = &cobra.Command{
	Use:   "puppy",
	Short: "A brief description of your application",
	Long: `A longer description that spans multiple lines and likely contains
to quickly create a Cobra application.`,
}

func Execute() {
	if err := rootCmd.Execute(); err != nil {
		os.Exit(1)
	}
}

func init() {
	rootCmd.AddCommand(serv.ServCmd, serv.ConfigCmd)
}
