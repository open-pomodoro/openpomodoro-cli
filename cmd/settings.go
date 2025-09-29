package cmd

import (
	"encoding/json"
	"fmt"
	"time"

	"github.com/spf13/cobra"
)

func init() {
	settingsCmd := &cobra.Command{
		Use:   "settings",
		Short: "Show current settings",
		Long:  "Display current application settings including defaults and configuration",
		RunE:  settingsShowCmd,
	}

	var jsonFlag bool
	settingsCmd.Flags().BoolVarP(&jsonFlag, "json", "j", false, "output as JSON")

	RootCmd.AddCommand(settingsCmd)

	// Hide irrelevant global flags
	settingsCmd.InheritedFlags().MarkHidden("format")
	settingsCmd.InheritedFlags().MarkHidden("wait")
}

func settingsShowCmd(cmd *cobra.Command, args []string) error {
	jsonFlag, _ := cmd.Flags().GetBool("json")

	if jsonFlag {
		return outputSettingsJSON()
	}

	fmt.Printf("Data Directory: %s\n", client.Directory)
	fmt.Printf("Daily Goal: %d pomodoros\n", settings.DailyGoal)
	fmt.Printf("Default Pomodoro Duration: %s\n", formatDuration(settings.DefaultPomodoroDuration))
	fmt.Printf("Default Break Duration: %s\n", formatDuration(settings.DefaultBreakDuration))

	if len(settings.DefaultTags) > 0 {
		fmt.Printf("Default Tags: %v\n", settings.DefaultTags)
	} else {
		fmt.Printf("Default Tags: none\n")
	}

	return nil
}

type SettingsJSON struct {
	DataDirectory             string   `json:"data_directory"`
	DailyGoal                 int      `json:"daily_goal"`
	DefaultPomodoroDuration   int      `json:"default_pomodoro_duration"` // in minutes
	DefaultBreakDuration      int      `json:"default_break_duration"`    // in minutes
	DefaultTags               []string `json:"default_tags"`
}

func outputSettingsJSON() error {
	sj := SettingsJSON{
		DataDirectory:           client.Directory,
		DailyGoal:               settings.DailyGoal,
		DefaultPomodoroDuration: int(settings.DefaultPomodoroDuration.Minutes()),
		DefaultBreakDuration:    int(settings.DefaultBreakDuration.Minutes()),
		DefaultTags:             settings.DefaultTags,
	}

	data, err := json.MarshalIndent(sj, "", "  ")
	if err != nil {
		return err
	}

	fmt.Println(string(data))
	return nil
}

func formatDuration(d time.Duration) string {
	minutes := int(d.Minutes())
	return fmt.Sprintf("%d minutes", minutes)
}