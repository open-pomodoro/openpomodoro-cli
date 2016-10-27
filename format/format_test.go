package format

import (
	"fmt"
	"testing"
	"time"

	"github.com/open-pomodoro/go-openpomodoro"
	"github.com/stretchr/testify/assert"
)

func Test_Format(t *testing.T) {
	pomodoros := map[*openpomodoro.Pomodoro]map[string]string{
		&openpomodoro.Pomodoro{}: map[string]string{
			`%r%!r%R%!R%l%L`: "",
			`%d%t`:           "",
		},

		&openpomodoro.Pomodoro{
			StartTime:   time.Now(),
			Description: "working on stuff",
			Tags:        []string{"work", "personal"},
		}: map[string]string{
			`%d`: "working on stuff",
			`%t`: "work, personal",
		},

		&openpomodoro.Pomodoro{
			StartTime: time.Now(),
			Duration:  25 * time.Minute,
		}: map[string]string{
			`%r 🍅`:  "25:00 🍅",
			`%!r 🍅`: "25:00 🍅",
			`%r`:    "25:00",
			`%!r`:   "25:00",
			`%R`:    "25",
			`%!R`:   "25",
			`%l`:    "25:00",
			`%L`:    "25",
		},

		&openpomodoro.Pomodoro{
			StartTime: time.Now(),
			Duration:  5 * time.Minute,
		}: map[string]string{
			`%l`: "5:00",
			`%L`: "5",
		},

		&openpomodoro.Pomodoro{
			StartTime: time.Now(),
			Duration:  24*time.Minute + 30*time.Second,
		}: map[string]string{
			`%l`: "24:30",
			`%L`: "25",
		},

		&openpomodoro.Pomodoro{
			StartTime: time.Now().Add(-20 * time.Minute),
			Duration:  25 * time.Minute,
		}: map[string]string{
			`%r`:  "5:00",
			`%!r`: "5:00",
			`%R`:  "5",
			`%!R`: "5",
		},

		&openpomodoro.Pomodoro{
			StartTime: time.Now().Add(-24*time.Minute - 59*time.Second),
			Duration:  25 * time.Minute,
		}: map[string]string{
			`%r`:  "0:01",
			`%!r`: "0:01",
			`%R`:  "0",
			`%!R`: "0",
		},

		&openpomodoro.Pomodoro{
			StartTime: time.Now().Add(-25*time.Minute - time.Second),
			Duration:  25 * time.Minute,
		}: map[string]string{
			`%r`:  "0:00",
			`%!r`: ExclamationPoint,
			`%R`:  "0",
			`%!R`: ExclamationPoint,
		},

		&openpomodoro.Pomodoro{
			StartTime: time.Now().Add(-30 * time.Minute),
			Duration:  25 * time.Minute,
		}: map[string]string{
			`%r`:  "0:00",
			`%!r`: ExclamationPoint,
			`%R`:  "0",
			`%!R`: ExclamationPoint,
		},

		&openpomodoro.Pomodoro{
			StartTime: time.Now(),
			Duration:  25 * time.Minute,
		}: map[string]string{
			`%R %R %R`: "25 25 25",
		},
	}

	for pomodoro, cases := range pomodoros {
		for format, expected := range cases {
			assert.Equal(
				t,
				expected,
				Format(pomodoro, format),
				fmt.Sprintf("%s\n%s\n%#v", format, pomodoro, pomodoro),
			)
		}
	}
}
