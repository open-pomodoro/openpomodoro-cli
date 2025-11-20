package cmd

import (
	"encoding/json"
	"fmt"
	"os"
	"strconv"
	"time"

	"github.com/justincampbell/go-countdown"
	"github.com/justincampbell/go-countdown/format"
	"github.com/open-pomodoro/go-openpomodoro"
	"github.com/spf13/cobra"
)

// wait displays a countdown timer for the specified duration
func wait(d time.Duration) error {
	err := countdown.For(d, time.Second).Do(func(c *countdown.Countdown) error {
		fmt.Printf("\r%s", format.MinSec(c.Remaining()))
		return nil
	})

	fmt.Println()

	return err
}

// shouldWait determines if we should wait based on the wait flag and command context
// For break commands, wait by default unless --no-wait is explicitly set
func shouldWait(cmd *cobra.Command, defaultWait bool) bool {
	if cmd.Flags().Changed("wait") {
		return waitFlag
	}
	return defaultWait
}

// parseDurationMinutes parses a duration string, defaulting to minutes if no unit is specified
func parseDurationMinutes(s string) (time.Duration, error) {
	if _, err := strconv.Atoi(s); err == nil {
		s = fmt.Sprintf("%sm", s)
	}
	return time.ParseDuration(s)
}

// printJSON marshals a value as indented JSON and prints it
func printJSON(v interface{}) error {
	data, err := json.MarshalIndent(v, "", "  ")
	if err != nil {
		return err
	}

	fmt.Println(string(data))
	return nil
}

// isPomodoroCompleted returns true if the given pomodoro is completed (not current)
func isPomodoroCompleted(p *openpomodoro.Pomodoro) bool {
	current, _ := client.Pomodoro()
	return current.IsInactive() || !current.Matches(p)
}

// getCommandArgs extracts the command-specific arguments from os.Args
func getCommandArgs(cmd *cobra.Command) []string {
	for i, arg := range os.Args {
		if arg == cmd.Name() || (i > 0 && os.Args[i-1] == "pomodoro") {
			if arg == cmd.Name() {
				return os.Args[i+1:]
			}
		}
	}
	return cmd.Flags().Args()
}
