package cmd

import (
	"time"

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

	if err := hook.Run(client, "stop", p.StartTime.Format(time.RFC3339), "clear", getCommandArgs(cmd)); err != nil {
		return err
	}

	return client.Clear()
}
