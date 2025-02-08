package cmd

import (
	"strings"
	"time"

	"github.com/open-pomodoro/go-openpomodoro"
	"github.com/open-pomodoro/openpomodoro-cli/hook"
	"github.com/spf13/cobra"
)

var (
	agoFlag      time.Duration
	durationFlag int
	tagsFlag     []string
)

func init() {
	command := &cobra.Command{
		Use:   "start [description]",
		Short: "Start a new Pomodoro",
		RunE:  startCmd,
	}

	command.Flags().DurationVarP(
		&agoFlag, "ago", "a", 0,
		"time ago this Pomodoro started")

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
	p.StartTime = time.Now().Add(-agoFlag)
	p.Tags = tagsFlag

	if err := client.Start(p); err != nil {
		return err
	}

	if err := hook.Run(client, "start"); err != nil {
		return err
	}

	if err := statusCmd(cmd, args); err != nil {
		return err
	}

	if waitFlag {
		return hook.Run(client, "stop", "focus")
	}

	return nil
}
