package cmd

import (
	"fmt"
	"time"

	"github.com/spf13/cobra"
)

func init() {
	command := &cobra.Command{
		Use:   "repeat",
		Short: "Repeat the last Pomodoro",
		RunE:  repeatCmd,
	}

	RootCmd.AddCommand(command)
}

func repeatCmd(cmd *cobra.Command, args []string) error {
	h, err := client.History()
	if err != nil {
		return err
	}

	p := h.Latest()
	if p.IsActive() {
		return fmt.Errorf("Cannot repeat an active Pomodoro")
	}

	// Clear the start time
	p.StartTime = time.Time{}

	err = client.Start(p)
	if err != nil {
		return err
	}

	return statusCmd(cmd, args)
}
