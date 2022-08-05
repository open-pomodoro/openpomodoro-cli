package cmd

import (
	"fmt"
	"log"
	"os"
	"runtime/debug"

	"github.com/open-pomodoro/go-openpomodoro"
	"github.com/open-pomodoro/openpomodoro-cli/format"
	"github.com/spf13/cobra"
	"github.com/spf13/viper"
)

// RootCmd represents the base command when called without any subcommands
var RootCmd = &cobra.Command{
	Use:   "pomodoro",
	Short: "Pomodoro CLI",
	Long:  "A simple Pomodoro command-line client for the Open Pomodoro format",
}

var (
	client   *openpomodoro.Client
	settings *openpomodoro.Settings

	directoryFlag string
	formatFlag    string
	waitFlag      bool

	// Tag is the git tag of the current build. It is set by LDFLAGS during the
	// build process.
	Tag string
)

func init() {
	RootCmd.Version = version()

	cobra.OnInitialize(initConfig)

	RootCmd.PersistentFlags().StringVarP(
		&directoryFlag, "directory", "", ``,
		"directory to read/write Open Pomodoro data (default is ~/.pomodoro/)")

	RootCmd.PersistentFlags().StringVarP(
		&formatFlag, "format", "f", format.DefaultFormat,
		"format to display Pomodoros in")

	RootCmd.PersistentFlags().BoolVarP(
		&waitFlag, "wait", "w", false,
		"wait for the Pomodoro to end before exiting")

	viper.AutomaticEnv()

	var err error

	client, err = openpomodoro.NewClient(directoryFlag)
	if err != nil {
		log.Fatalf("Could not create client: %v", err)
	}

	settings, err = client.Settings()
	if err != nil {
		log.Fatalf("Could not retrieve settings: %v", err)
	}
}

func initConfig() {
	viper.AutomaticEnv()
}

func version() string {
	if Tag == "" {
		Tag = "development"
	}

	build, ok := debug.ReadBuildInfo()
	if !ok {
		return fmt.Sprintf("%s (unknown)", Tag)
	}

	var gitSha string
	var dirty bool

	for _, v := range build.Settings {
		if v.Key == "vcs.revision" {
			gitSha = v.Value
			if len(gitSha) > 7 {
				gitSha = gitSha[:7]
			}
		}

		if v.Key == "vcs.modified" {
			dirty = v.Value == "true"
		}
	}

	if gitSha == "" {
		gitSha = "unknown"
	}

	if dirty {
		gitSha += "+"
	}

	return fmt.Sprintf("%s (%s)", Tag, gitSha)
}

// Execute adds all child commands to the root command sets flags appropriately.
// This is called by main.main(). It only needs to happen once to the rootCmd.
func Execute() {
	if err := RootCmd.Execute(); err != nil {
		fmt.Println(err)
		os.Exit(-1)
	}
}
