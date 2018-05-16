package cmd

import (
	"fmt"
	"strconv"
	"time"

	"github.com/justincampbell/go-countdown"
	"github.com/justincampbell/go-countdown/format"
	"github.com/spf13/cobra"
)

func init() {
	command := &cobra.Command{
		Use:   "break [duration]",
		Short: "Take a break",
		RunE:  breakCmd,
	}

	RootCmd.AddCommand(command)
}

func breakCmd(cmd *cobra.Command, args []string) error {
	d := settings.DefaultBreakDuration

	if len(args) > 0 {
		var err error
		d, err = parseDurationMinutes(args[0])
		if err != nil {
			return err
		}
	}

	return wait(d)
}

func wait(d time.Duration) error {
	err := countdown.For(d, time.Second).Do(func(c *countdown.Countdown) error {
		fmt.Printf("\r%s", format.MinSec(c.Remaining()))
		return nil
	})

	fmt.Println()

	return err
}

func parseDurationMinutes(s string) (time.Duration, error) {
	if _, err := strconv.Atoi(s); err == nil {
		s = fmt.Sprintf("%sm", s)
	}
	return time.ParseDuration(s)
}
