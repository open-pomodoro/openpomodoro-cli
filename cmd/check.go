package cmd

import (
	"os"

	"github.com/spf13/cobra"
)

func init() {
	command := &cobra.Command{
		Use:   "check",
		Short: "Exit 0 if a Pomodoro is active, 1 otherwise",
		RunE:  checkCmd,
	}

	command.Flags().BoolP("quiet", "q", false, "No-op flag for scripting idiom compatibility")

	RootCmd.AddCommand(command)
}

func checkCmd(cmd *cobra.Command, args []string) error {
	s, err := client.CurrentState()
	if err != nil {
		return err
	}

	if s.Pomodoro.IsActive() {
		return nil
	}

	os.Exit(1)
	return nil
}
