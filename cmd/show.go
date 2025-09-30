package cmd

import (
	"errors"
	"fmt"
	"strings"
	"time"

	"github.com/open-pomodoro/go-openpomodoro"
	"github.com/open-pomodoro/openpomodoro-cli/format"
	"github.com/spf13/cobra"
)

func init() {
	// Parent show command - shows basic info
	showCmd := &cobra.Command{
		Use:   "show <timestamp>",
		Short: "Show basic details about a specific pomodoro",
		Args:  cobra.ExactArgs(1),
		RunE:  showBasicCmd,
	}

	// Add JSON flag to parent command (applies to basic info)
	var jsonFlag, allFlag bool
	showCmd.Flags().BoolVarP(&jsonFlag, "json", "j", false, "output as JSON")
	showCmd.Flags().BoolVarP(&allFlag, "all", "a", false, "show all attributes including empty ones")

	// Duration subcommand
	durationCmd := &cobra.Command{
		Use:   "duration <timestamp>",
		Short: "Show pomodoro duration",
		Args:  cobra.ExactArgs(1),
		RunE:  showDurationCmd,
	}
	var minutesFlag, secondsFlag bool
	durationCmd.Flags().BoolVarP(&minutesFlag, "minutes", "m", false, "output duration as minutes")
	durationCmd.Flags().BoolVarP(&secondsFlag, "seconds", "s", false, "output duration as seconds")

	// Description subcommand
	descriptionCmd := &cobra.Command{
		Use:   "description <timestamp>",
		Short: "Show pomodoro description",
		Args:  cobra.ExactArgs(1),
		RunE:  showDescriptionCmd,
	}

	// Tags subcommand
	tagsCmd := &cobra.Command{
		Use:   "tags <timestamp>",
		Short: "Show pomodoro tags",
		Args:  cobra.ExactArgs(1),
		RunE:  showTagsCmd,
	}
	var rawFlag bool
	tagsCmd.Flags().BoolVar(&rawFlag, "raw", false, "raw format (no spacing)")

	// Start time subcommand
	startTimeCmd := &cobra.Command{
		Use:   "start_time <timestamp>",
		Short: "Show pomodoro start time",
		Args:  cobra.ExactArgs(1),
		RunE:  showStartTimeCmd,
	}
	var unixFlag bool
	startTimeCmd.Flags().BoolVarP(&unixFlag, "unix", "u", false, "output time as unix timestamp")

	// Completed subcommand
	completedCmd := &cobra.Command{
		Use:   "completed <timestamp>",
		Short: "Show pomodoro completion status",
		Args:  cobra.ExactArgs(1),
		RunE:  showCompletedCmd,
	}
	var numericFlag bool
	completedCmd.Flags().BoolVar(&numericFlag, "numeric", false, "output booleans as 1/0")

	// Add subcommands to parent
	showCmd.AddCommand(durationCmd, descriptionCmd, tagsCmd, startTimeCmd, completedCmd)

	// Add to root command
	RootCmd.AddCommand(showCmd)

	// Hide irrelevant global flags after adding to root
	showCmd.InheritedFlags().MarkHidden("format")
	showCmd.InheritedFlags().MarkHidden("wait")
}

func showBasicCmd(cmd *cobra.Command, args []string) error {
	timestamp := args[0]
	jsonFlag, _ := cmd.Flags().GetBool("json")
	allFlag, _ := cmd.Flags().GetBool("all")

	p, err := findPomodoroByTimestamp(timestamp)
	if err != nil {
		return err
	}

	if jsonFlag {
		return outputPomodoroJSON(p)
	}

	fmt.Println("start_time=" + p.StartTime.Format(openpomodoro.TimeFormat))

	if allFlag || p.Description != "" {
		if strings.ContainsAny(p.Description, " \t\n\r\"\\") {
			fmt.Println("description=\"" + p.Description + "\"")
		} else {
			fmt.Println("description=" + p.Description)
		}
	}

	fmt.Printf("duration=%d\n", int(p.Duration.Minutes()))

	if allFlag || len(p.Tags) > 0 {
		if len(p.Tags) > 0 {
			fmt.Println("tags=" + strings.Join(p.Tags, ","))
		} else {
			fmt.Println("tags=")
		}
	}

	return nil
}

func showDurationCmd(cmd *cobra.Command, args []string) error {
	timestamp := args[0]
	minutesFlag, _ := cmd.Flags().GetBool("minutes")
	secondsFlag, _ := cmd.Flags().GetBool("seconds")

	if minutesFlag && secondsFlag {
		return errors.New("cannot use both --minutes and --seconds flags")
	}

	p, err := findPomodoroByTimestamp(timestamp)
	if err != nil {
		return err
	}

	if minutesFlag {
		fmt.Println(int(p.Duration.Minutes()))
	} else if secondsFlag {
		fmt.Println(int(p.Duration.Seconds()))
	} else {
		fmt.Println(format.DurationAsTime(p.Duration))
	}

	return nil
}

func showDescriptionCmd(cmd *cobra.Command, args []string) error {
	timestamp := args[0]

	p, err := findPomodoroByTimestamp(timestamp)
	if err != nil {
		return err
	}

	fmt.Println(p.Description)
	return nil
}

func showTagsCmd(cmd *cobra.Command, args []string) error {
	timestamp := args[0]
	rawFlag, _ := cmd.Flags().GetBool("raw")

	p, err := findPomodoroByTimestamp(timestamp)
	if err != nil {
		return err
	}

	if rawFlag {
		fmt.Println(strings.Join(p.Tags, ","))
	} else {
		fmt.Println(strings.Join(p.Tags, ", "))
	}

	return nil
}

func showStartTimeCmd(cmd *cobra.Command, args []string) error {
	timestamp := args[0]
	unixFlag, _ := cmd.Flags().GetBool("unix")

	p, err := findPomodoroByTimestamp(timestamp)
	if err != nil {
		return err
	}

	if unixFlag {
		fmt.Println(p.StartTime.Unix())
	} else {
		fmt.Println(p.StartTime.Format(openpomodoro.TimeFormat))
	}

	return nil
}

func showCompletedCmd(cmd *cobra.Command, args []string) error {
	timestamp := args[0]
	numericFlag, _ := cmd.Flags().GetBool("numeric")

	p, err := findPomodoroByTimestamp(timestamp)
	if err != nil {
		return err
	}

	completed := isPomodoroCompleted(p)

	if numericFlag {
		if completed {
			fmt.Println("1")
		} else {
			fmt.Println("0")
		}
	} else {
		if completed {
			fmt.Println("true")
		} else {
			fmt.Println("false")
		}
	}

	return nil
}

func findPomodoroByTimestamp(timestampStr string) (*openpomodoro.Pomodoro, error) {
	// Parse the timestamp
	timestamp, err := time.Parse(openpomodoro.TimeFormat, timestampStr)
	if err != nil {
		return nil, fmt.Errorf("invalid timestamp format: %v", err)
	}

	// Check if it's the current pomodoro
	current, err := client.Pomodoro()
	if err == nil && !current.IsInactive() {
		if current.Matches(&openpomodoro.Pomodoro{StartTime: timestamp}) {
			return current, nil
		}
	}

	// Search in history
	history, err := client.History()
	if err != nil {
		return nil, fmt.Errorf("failed to read history: %v", err)
	}

	for _, p := range history.Pomodoros {
		if p.Matches(&openpomodoro.Pomodoro{StartTime: timestamp}) {
			return p, nil
		}
	}

	return nil, fmt.Errorf("pomodoro with timestamp %s not found", timestampStr)
}

type PomodoroJSON struct {
	StartTime   string   `json:"start_time"`
	Description string   `json:"description"`
	Duration    int      `json:"duration"`
	Tags        []string `json:"tags"`
	Completed   bool     `json:"completed"`
	IsCurrent   bool     `json:"is_current"`
}

func outputPomodoroJSON(p *openpomodoro.Pomodoro) error {
	completed := isPomodoroCompleted(p)
	pomodoroData := PomodoroJSON{
		StartTime:   p.StartTime.Format(openpomodoro.TimeFormat),
		Description: p.Description,
		Duration:    int(p.Duration.Minutes()),
		Tags:        p.Tags,
		Completed:   completed,
		IsCurrent:   !completed,
	}

	return printJSON(pomodoroData)
}
