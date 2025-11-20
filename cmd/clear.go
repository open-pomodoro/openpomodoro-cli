package cmd

import (
	"github.com/open-pomodoro/go-openpomodoro"
	"github.com/open-pomodoro/openpomodoro-cli/hook"
	"github.com/spf13/cobra"
)

func init() {
	command := &cobra.Command{
		Use:   "clear",
		Short: "Clear the current Pomodoro",
		RunE:  clearCmd,
	}

	RootCmd.AddCommand(command)
}

func clearCmd(cmd *cobra.Command, args []string) error {
	p, err := client.Pomodoro()
	if err != nil {
		return err
	}

	if err := hook.Run(client, hook.Params{
		Name:       "stop",
		PomodoroID: p.StartTime.Format(openpomodoro.TimeFormat),
		Command:    "clear",
		Args:       getCommandArgs(cmd),
	}); err != nil {
		return err
	}

	return client.Clear()
}
