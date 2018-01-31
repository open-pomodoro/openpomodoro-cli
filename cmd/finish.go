package cmd

import "github.com/spf13/cobra"

func init() {
	command := &cobra.Command{
		Use:   "finish",
		Short: "Finish the current Pomodoro",
		RunE:  finishCmd,
	}

	RootCmd.AddCommand(command)
}

func finishCmd(cmd *cobra.Command, args []string) error {
	return client.Finish()
}
