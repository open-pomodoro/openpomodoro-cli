package cmd

import (
	"fmt"
	"time"

	"github.com/open-pomodoro/openpomodoro-cli/format"
	"github.com/open-pomodoro/openpomodoro-cli/hook"
	"github.com/spf13/cobra"
)

func init() {
	command := &cobra.Command{
		Use:   "finish",
		Short: "Finish the current Pomodoro",
		RunE:  finishCmd,
	}

	RootCmd.AddCommand(command)
}

func finishCmd(cmd *cobra.Command, args []string) error {
	p, err := client.Pomodoro()
	if err != nil {
		return err
	}

	d := time.Now().Sub(p.StartTime)
	fmt.Println(format.DurationAsTime(d))

	if err := hook.Run(client, "stop"); err != nil {
		return err
	}

	return client.Finish()
}
