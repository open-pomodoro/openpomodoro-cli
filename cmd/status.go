package cmd

import (
	"fmt"
	"time"

	"github.com/justincampbell/go-countdown"
	countdownformat "github.com/justincampbell/go-countdown/format"
	"github.com/open-pomodoro/openpomodoro-cli/format"
	"github.com/open-pomodoro/openpomodoro-cli/hook"
	"github.com/spf13/cobra"
)

func init() {
	RootCmd.AddCommand(&cobra.Command{
		Use:   "status",
		Short: "Show the status of the current Pomodoro",
		RunE:  statusCmd,
	})
}

func statusCmd(cmd *cobra.Command, args []string) error {
	s, err := client.CurrentState()
	if err != nil {
		return err
	}

	fmt.Println(format.Format(s, formatFlag))

	if waitFlag {
		if d := s.Pomodoro.Remaining(); d > 0 {
			waitForDuration(d)
			// Call the stop hook when the timer naturally expires
			if err := hook.Run(client, "stop"); err != nil {
				return err
			}
		}
	}

	return nil
}

func waitForDuration(d time.Duration) error {
	err := countdown.For(d, time.Second).Do(func(c *countdown.Countdown) error {
		fmt.Printf("\r%s", countdownformat.MinSec(c.Remaining()))
		return nil
	})

	fmt.Println()

	return err
}
