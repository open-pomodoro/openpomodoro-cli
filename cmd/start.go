package cmd

import (
	"fmt"

	"github.com/open-pomodoro/go-openpomodoro"
	"github.com/open-pomodoro/openpomodoro-cli/format"
	"github.com/spf13/cobra"
)

func init() {
	RootCmd.AddCommand(&cobra.Command{
		Use:   "start",
		Short: "Start a new Pomodoro",
		RunE:  startCmd,
	})
}

func startCmd(cmd *cobra.Command, args []string) error {
	p := openpomodoro.NewPomodoro()
	err := client.Start(p)
	if err != nil {
		return err
	}

	fmt.Println(format.Format(p, formatFlag))

	return nil
}
