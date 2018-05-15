package cmd

import (
	"encoding/json"
	"fmt"
	"io"
	"os"
	"strings"

	"github.com/open-pomodoro/go-openpomodoro"
	"github.com/soh335/ical"
	"github.com/spf13/cobra"
)

var (
	outputFlag string
)

type outputFunc func(*openpomodoro.History, io.Writer) error

func init() {
	command := &cobra.Command{
		Use:   "history",
		Short: "Show Pomodoro history",
		RunE:  historyCmd,
	}

	command.Flags().StringVarP(
		&outputFlag, "output", "o",
		"history",
		"output format (history, ical, or json)",
	)

	RootCmd.AddCommand(command)
}

func historyCmd(cmd *cobra.Command, args []string) error {
	h, err := client.History()
	if err != nil {
		return err
	}

	var f outputFunc
	switch outputFlag {
	case "history":
		f = outputHistory
	case "ical":
		f = outputICal
	case "json":
		f = outputJSON
	default:
		return fmt.Errorf("%q is not a valid output format", outputFlag)
	}

	return f(h, os.Stdout)
}

func outputHistory(h *openpomodoro.History, w io.Writer) error {
	b, err := h.MarshalText()
	if err != nil {
		return err
	}

	_, err = w.Write(b)
	return err
}

func outputICal(h *openpomodoro.History, w io.Writer) error {
	cal := ical.NewBasicVCalendar()
	cal.NAME = "Pomodoros"

	for _, p := range h.Pomodoros {
		tz, _ := p.StartTime.Zone()

		cal.VComponent = append(cal.VComponent, &ical.VEvent{
			UID:         p.StartTime.Format(openpomodoro.TimeFormat),
			DTSTAMP:     p.StartTime,
			DTSTART:     p.StartTime,
			DTEND:       p.EndTime(),
			SUMMARY:     p.Description,
			DESCRIPTION: strings.Join(p.Tags, ", "),
			TZID:        tz,
		})
	}

	return cal.Encode(w)
}

func outputJSON(h *openpomodoro.History, w io.Writer) error {
	enc := json.NewEncoder(w)
	enc.SetIndent("", "  ")
	return enc.Encode(h)
}
