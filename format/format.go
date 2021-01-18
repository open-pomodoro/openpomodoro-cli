package format

import (
	"fmt"
	"math"
	"strings"
	"time"

	"github.com/open-pomodoro/go-openpomodoro"
)

const (
	DefaultFormat           = "%!r⏱  %c%!g🍅\n%d\n%t"
	DefaultExclamationPoint = "❗️"
)

type Formatter func(*openpomodoro.State) string

var FormatParts = map[string]Formatter{
	`%r`:  timeRemaining(false),
	`%!r`: timeRemaining(true),
	`%R`:  minutesRemaining(false),
	`%!R`: minutesRemaining(true),
	`%l`:  duration,
	`%L`:  durationMinutes,

	`%d`: description,
	`%t`: tags,

	`%c`:  goalComplete,
	`%g`:  goalTotal(false),
	`%!g`: goalTotal(true),
}

func Format(s *openpomodoro.State, f string) string {
	if s.Pomodoro.IsInactive() {
		return ""
	}

	result := f
	for part, replacement := range FormatParts {
		result = strings.Replace(result, part, replacement(s), -1)
	}
	result = strings.TrimSpace(result)
	return result
}

// DurationAsTime returns a duration string.
func DurationAsTime(d time.Duration) string {
	s := round(d.Seconds())
	return fmt.Sprintf("%d:%02d", s/60, s%60)
}

func timeRemaining(exclaim bool) Formatter {
	return func(s *openpomodoro.State) string {
		d := s.Pomodoro.Remaining()

		if s.Pomodoro.IsDone() {
			if exclaim {
				return DefaultExclamationPoint
			} else {
				return "0:00"
			}
		}

		return DurationAsTime(d)
	}
}

func minutesRemaining(exclaim bool) Formatter {
	return func(s *openpomodoro.State) string {
		if s.Pomodoro.IsDone() {
			if exclaim {
				return DefaultExclamationPoint
			} else {
				return "0"
			}
		}
		return defaultString(s.Pomodoro.RemainingMinutes())
	}
}

func duration(s *openpomodoro.State) string {
	return DurationAsTime(s.Pomodoro.Duration)
}

func durationMinutes(s *openpomodoro.State) string {
	return defaultString(s.Pomodoro.DurationMinutes())
}

func description(s *openpomodoro.State) string {
	return s.Pomodoro.Description
}

func tags(s *openpomodoro.State) string {
	return strings.Join(s.Pomodoro.Tags, ", ")
}

func goalComplete(s *openpomodoro.State) string {
	if s.History == nil {
		return "0"
	}
	return fmt.Sprint(s.History.Date(time.Now()).Count())
}

func goalTotal(slash bool) Formatter {
	return func(s *openpomodoro.State) string {
		if s.Settings == nil || s.Settings.DailyGoal == 0 {
			return ""
		}

		result := fmt.Sprint(s.Settings.DailyGoal)
		if slash {
			result = fmt.Sprintf("/%s", result)
		}
		return result
	}
}

func defaultString(i interface{}) string {
	return fmt.Sprintf("%#v", i)
}

func round(f float64) int {
	return int(math.Floor(f + .5))
}
