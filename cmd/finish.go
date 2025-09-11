package cmd

import (
	"fmt"
	"strconv"
	"time"

	"github.com/justincampbell/go-countdown"
	countdownFormat "github.com/justincampbell/go-countdown/format"
	"github.com/open-pomodoro/openpomodoro-cli/format"
	"github.com/open-pomodoro/openpomodoro-cli/hook"
	"github.com/spf13/cobra"
)

var breakFlag string

func init() {
	command := &cobra.Command{
		Use:   "finish",
		Short: "Finish the current Pomodoro",
		RunE:  finishCmd,
	}

	command.Flags().StringVar(&breakFlag, "break", "", "take a break after finishing (duration in minutes)")

	RootCmd.AddCommand(command)
}

func finishCmd(cmd *cobra.Command, args []string) error {
	p, err := client.Pomodoro()
	if err != nil {
		return err
	}

	d := time.Now().Sub(p.StartTime)
	fmt.Println(format.DurationAsTime(d))

	if err := hook.Run(client, "stop"); err != nil {
		return err
	}

	if err := client.Finish(); err != nil {
		return err
	}

	if breakFlag != "" {
		breakDuration := settings.DefaultBreakDuration

		if breakFlag != "" {
			var err error
			breakDuration, err = finishParseDurationMinutes(breakFlag)
			if err != nil {
				return err
			}
		}

		if err := hook.Run(client, "break"); err != nil {
			return err
		}

		if err := finishWait(breakDuration); err != nil {
			return err
		}

		return hook.Run(client, "stop")
	}

	return nil
}

func finishWait(d time.Duration) error {
	err := countdown.For(d, time.Second).Do(func(c *countdown.Countdown) error {
		fmt.Printf("\r%s", countdownFormat.MinSec(c.Remaining()))
		return nil
	})

	fmt.Println()

	return err
}

func finishParseDurationMinutes(s string) (time.Duration, error) {
	if _, err := strconv.Atoi(s); err == nil {
		s = fmt.Sprintf("%sm", s)
	}
	return time.ParseDuration(s)
}
