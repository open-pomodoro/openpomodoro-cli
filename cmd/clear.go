package cmd

import (
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
	return client.Clear()
}
