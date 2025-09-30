package cmd

import (
	"github.com/open-pomodoro/openpomodoro-cli/hook"
	"github.com/spf13/cobra"
)

func init() {
	command := &cobra.Command{
		Use:   "break [duration]",
		Short: "Take a break",
		RunE:  breakCmd,
	}

	RootCmd.AddCommand(command)
}

func breakCmd(cmd *cobra.Command, args []string) error {
	d := settings.DefaultBreakDuration

	if len(args) > 0 {
		var err error
		d, err = parseDurationMinutes(args[0])
		if err != nil {
			return err
		}
	}

	if err := hook.Run(client, hook.Params{
		Name:          "break",
		Command:       "break",
		Args:          getCommandArgs(cmd),
		BreakDuration: d,
	}); err != nil {
		return err
	}

	if shouldWait(cmd, true) {
		if err := wait(d); err != nil {
			return err
		}
	}

	return hook.Run(client, hook.Params{
		Name:    "stop",
		Command: "break",
		Args:    getCommandArgs(cmd),
	})
}
