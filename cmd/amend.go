package cmd

import (
	"fmt"
	"strings"
	"time"

	"github.com/spf13/cobra"
)

func init() {
	command := &cobra.Command{
		Use:   "amend",
		Short: "Amend the last Pomodoro",
		RunE:  amendCmd,
	}

	command.Flags().DurationVarP(
		&agoFlag, "ago", "a", 0,
		"time ago this Pomodoro started")

	command.Flags().IntVarP(
		&durationFlag, "duration", "d",
		0,
		"duration for this Pomodoro")

	command.Flags().StringArrayVarP(
		&tagsFlag, "tags", "t", []string{},
		"tags for this Pomodoro")

	RootCmd.AddCommand(command)
}

func amendCmd(cmd *cobra.Command, args []string) error {
	h, err := client.History()
	if err != nil {
		return err
	}
	p := h.Latest()
	if p == nil {
		return fmt.Errorf("No Pomodoros found")
	}

	description := strings.Join(args, " ")
	if description != "" {
		p.Description = description
	}
	if durationFlag != 0 {
		p.Duration = time.Duration(durationFlag) * time.Minute
	}
	if agoFlag != 0 {
		p.StartTime = time.Now().Add(-agoFlag)
	}
	if len(tagsFlag) != 0 {
		p.Tags = tagsFlag
	}

	err = client.Start(p)
	if err != nil {
		return err
	}

	return statusCmd(cmd, args)
}
