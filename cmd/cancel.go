package cmd

import (
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
	if err := hook.Run(client, "stop"); err != nil {
		return err
	}

	return client.Cancel()
}
