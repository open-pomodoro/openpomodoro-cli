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
		&durationFlag, "duration", "d", 0,
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
	if durationFlag == 0 {
		p.Duration = settings.DefaultPomodoroDuration
	} else {
		p.Duration = time.Duration(durationFlag) * time.Minute
	}
	p.StartTime = time.Now().Add(-agoFlag)
	p.Tags = tagsFlag

	if err := client.Start(p); err != nil {
		return err
	}

	current, err := client.Pomodoro()
	if err != nil {
		return err
	}

	if err := hook.Run(client, hook.Params{
		Name:       "start",
		PomodoroID: current.StartTime.Format(openpomodoro.TimeFormat),
		Command:    "start",
		Args:       getCommandArgs(cmd),
	}); err != nil {
		return err
	}

	return statusCmd(cmd, args)
}
