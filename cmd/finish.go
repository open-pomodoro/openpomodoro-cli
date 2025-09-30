package cmd

import (
	"fmt"
	"strings"
	"time"

	"github.com/open-pomodoro/openpomodoro-cli/format"
	"github.com/open-pomodoro/openpomodoro-cli/hook"
	"github.com/spf13/cobra"
)

var breakFlag string

func init() {
	command := &cobra.Command{
		Use:   "finish",
		Short: "Finish the current Pomodoro",
		RunE:  finishCmd,
	}

	command.Flags().StringVarP(&breakFlag, "break", "b", "", "take a break after finishing (duration in minutes)")
	command.Flags().Lookup("break").NoOptDefVal = " "

	RootCmd.AddCommand(command)
}

func finishCmd(cmd *cobra.Command, args []string) error {
	p, err := client.Pomodoro()
	if err != nil {
		return err
	}

	d := time.Now().Sub(p.StartTime)
	fmt.Println(format.DurationAsTime(d))

	if err := hook.Run(client, "stop", p.StartTime.Format(time.RFC3339), "finish", getCommandArgs(cmd)); err != nil {
		return err
	}

	if err := client.Finish(); err != nil {
		return err
	}

	if cmd.Flags().Changed("break") {
		breakDuration := settings.DefaultBreakDuration

		trimmedFlag := strings.TrimSpace(breakFlag)
		if trimmedFlag != "" {
			var err error
			breakDuration, err = parseDurationMinutes(trimmedFlag)
			if err != nil {
				return err
			}
		}

		if err := hook.Run(client, "break", p.StartTime.Format(time.RFC3339), "finish", getCommandArgs(cmd)); err != nil {
			return err
		}

		if err := wait(breakDuration); err != nil {
			return err
		}

		return hook.Run(client, "stop", p.StartTime.Format(time.RFC3339), "finish", getCommandArgs(cmd))
	}

	return nil
}
