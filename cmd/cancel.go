package cmd

import (
	"github.com/open-pomodoro/go-openpomodoro"
	"github.com/open-pomodoro/openpomodoro-cli/hook"
	"github.com/spf13/cobra"
)

func init() {
	command := &cobra.Command{
		Use:   "cancel",
		Short: "Cancel the current Pomodoro",
		RunE:  cancelCmd,
	}

	RootCmd.AddCommand(command)
}

func cancelCmd(cmd *cobra.Command, args []string) error {
	p, err := client.Pomodoro()
	if err != nil {
		return err
	}

	if err := hook.Run(client, "stop", p.StartTime.Format(openpomodoro.TimeFormat), "cancel", getCommandArgs(cmd), 0); err != nil {
		return err
	}

	return client.Cancel()
}
