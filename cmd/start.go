package cmd

import (
	"strings"
	"time"

	"github.com/open-pomodoro/go-openpomodoro"
	"github.com/spf13/cobra"
)

var durationFlag int
var tagsFlag []string

func init() {
	command := &cobra.Command{
		Use:   "start [description]",
		Short: "Start a new Pomodoro",
		RunE:  startCmd,
	}

	command.Flags().IntVarP(
		&durationFlag, "duration", "d",
		int(settings.DefaultPomodoroDuration.Minutes()),
		"duration for this Pomodoro")

	command.Flags().StringArrayVarP(
		&tagsFlag, "tags", "t", []string{},
		"tags for this Pomodoro")

	RootCmd.AddCommand(command)
}

func startCmd(cmd *cobra.Command, args []string) error {
	description := strings.Join(args, " ")

	p := openpomodoro.NewPomodoro()
	p.Description = description
	p.Duration = time.Duration(durationFlag) * time.Minute
	p.Tags = tagsFlag

	err := client.Start(p)
	if err != nil {
		return err
	}

	return statusCmd(cmd, args)
}
