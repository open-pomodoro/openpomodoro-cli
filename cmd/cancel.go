package cmd

import (
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
	return client.Cancel()
}
