package format

import (
	"fmt"
	"math"
	"strings"
	"time"

	"github.com/open-pomodoro/go-openpomodoro"
)

const (
	DefaultFormat    = "%!r 🍅"
	ExclamationPoint = "❗️"
)

type Formatter func(*openpomodoro.Pomodoro) string

var FormatParts = map[string]Formatter{
	`%r`:  timeRemaining(false),
	`%!r`: timeRemaining(true),
	`%R`:  minutesRemaining(false),
	`%!R`: minutesRemaining(true),
	`%l`:  duration,
	`%L`:  durationMinutes,

	`%d`: description,
	`%t`: tags,
}

func Format(p *openpomodoro.Pomodoro, f string) string {
	if p.IsInactive() {
		return ""
	}

	result := f
	for part, replacement := range FormatParts {
		result = strings.Replace(result, part, replacement(p), -1)
	}
	return result
}

func timeRemaining(exclaim bool) Formatter {
	return func(p *openpomodoro.Pomodoro) string {
		d := p.Remaining()

		if p.IsDone() {
			if exclaim {
				return ExclamationPoint
			} else {
				return "0:00"
			}
		}

		return formatDurationAsTime(d)
	}
}

func minutesRemaining(exclaim bool) Formatter {
	return func(p *openpomodoro.Pomodoro) string {
		if p.IsDone() {
			if exclaim {
				return ExclamationPoint
			} else {
				return "0"
			}
		}
		return defaultString(p.RemainingMinutes())
	}
}

func duration(p *openpomodoro.Pomodoro) string {
	return formatDurationAsTime(p.Duration)
}

func durationMinutes(p *openpomodoro.Pomodoro) string {
	return defaultString(p.DurationMinutes())
}

func description(p *openpomodoro.Pomodoro) string {
	return p.Description
}

func tags(p *openpomodoro.Pomodoro) string {
	return strings.Join(p.Tags, ", ")
}

func formatDurationAsTime(d time.Duration) string {
	s := round(d.Seconds())
	return fmt.Sprintf("%d:%02d", s/60, s%60)
}

func defaultString(i interface{}) string {
	return fmt.Sprintf("%#v", i)
}

func round(f float64) int {
	return int(math.Floor(f + .5))
}
