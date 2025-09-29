package cmd

import (
	"fmt"
	"strings"

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

	fmt.Printf("data_directory=%s\n", client.Directory)
	fmt.Printf("daily_goal=%d\n", settings.DailyGoal)
	fmt.Printf("default_pomodoro_duration=%d\n", int(settings.DefaultPomodoroDuration.Minutes()))
	fmt.Printf("default_break_duration=%d\n", int(settings.DefaultBreakDuration.Minutes()))

	if len(settings.DefaultTags) > 0 {
		// Format as comma-separated string like in history files
		fmt.Printf("default_tags=%s\n", strings.Join(settings.DefaultTags, ","))
	} else {
		fmt.Printf("default_tags=\n")
	}

	return nil
}

type SettingsJSON struct {
	DataDirectory           string   `json:"data_directory"`
	DailyGoal               int      `json:"daily_goal"`
	DefaultPomodoroDuration int      `json:"default_pomodoro_duration"` // in minutes
	DefaultBreakDuration    int      `json:"default_break_duration"`    // in minutes
	DefaultTags             []string `json:"default_tags"`
}

func outputSettingsJSON() error {
	settingsData := SettingsJSON{
		DataDirectory:           client.Directory,
		DailyGoal:               settings.DailyGoal,
		DefaultPomodoroDuration: int(settings.DefaultPomodoroDuration.Minutes()),
		DefaultBreakDuration:    int(settings.DefaultBreakDuration.Minutes()),
		DefaultTags:             settings.DefaultTags,
	}

	return printJSON(settingsData)
}
