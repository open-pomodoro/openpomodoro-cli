package cmd

import (
	"fmt"
	"strconv"
	"time"

	"github.com/justincampbell/go-countdown"
	"github.com/justincampbell/go-countdown/format"
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

// parseDurationMinutes parses a duration string, defaulting to minutes if no unit is specified
func parseDurationMinutes(s string) (time.Duration, error) {
	if _, err := strconv.Atoi(s); err == nil {
		s = fmt.Sprintf("%sm", s)
	}
	return time.ParseDuration(s)
}