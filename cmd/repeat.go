package cmd

import (
	"fmt"
	"time"

	"github.com/open-pomodoro/openpomodoro-cli/hook"
	"github.com/spf13/cobra"
)

func init() {
	command := &cobra.Command{
		Use:   "repeat",
		Short: "Repeat the last Pomodoro",
		RunE:  repeatCmd,
	}

	command.Flags().DurationVarP(
		&agoFlag, "ago", "a", 0,
		"time ago this Pomodoro started")

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

	p.StartTime = time.Now().Add(-agoFlag)

	s, err := client.Settings()
	if err != nil {
		return err
	}
	p.Duration = s.DefaultPomodoroDuration

	err = client.Start(p)
	if err != nil {
		return err
	}

	current, err := client.Pomodoro()
	if err != nil {
		return err
	}

	if err := hook.Run(client, "start", current.StartTime.Format(time.RFC3339), "repeat", getCommandArgs(cmd), 0); err != nil {
		return err
	}

	return statusCmd(cmd, args)
}
