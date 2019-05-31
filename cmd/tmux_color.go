package cmd

import (
	"fmt"

	"github.com/spf13/cobra"
)

const (
	tmuxRed   = "colour1"
	tmuxGreen = "colour2"
)

func init() {
	RootCmd.AddCommand(&cobra.Command{
		Use:   "tmux-color",
		Short: "Return a tmux color string for the status.",
		RunE:  tmuxColorCmd,
	})
}

func tmuxColorCmd(cmd *cobra.Command, args []string) error {
	s, err := client.CurrentState()
	if err != nil {
		return err
	}

	if s.Pomodoro.IsActive() {
		fmt.Printf(tmuxGreen)
	}

	if s.Pomodoro.IsDone() {
		fmt.Printf(tmuxRed)
	}

	return nil
}
