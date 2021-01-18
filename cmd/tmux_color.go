package cmd

import (
	"fmt"

	"github.com/spf13/cobra"
)

var (
	activeFlag string
	doneFlag   string
)

func init() {
	command := &cobra.Command{
		Use:   "tmux-color",
		Short: "Return a tmux color string for the status.",
		RunE:  tmuxColorCmd,
	}

	command.Flags().StringVarP(
		&activeFlag, "active", "a", "colour2",
		"color when a Pomodoro is active")

	command.Flags().StringVarP(
		&doneFlag, "done", "d", "colour1",
		"color when a Pomodoro is done")

	RootCmd.AddCommand(command)
}

func tmuxColorCmd(cmd *cobra.Command, args []string) error {
	s, err := client.CurrentState()
	if err != nil {
		return err
	}

	if s.Pomodoro.IsActive() {
		fmt.Printf(activeFlag)
	}

	if s.Pomodoro.IsDone() {
		fmt.Printf(doneFlag)
	}

	return nil
}
