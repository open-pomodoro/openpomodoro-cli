package cmd

import (
	"fmt"

	"github.com/open-pomodoro/openpomodoro-cli/format"
	"github.com/spf13/cobra"
)

func init() {
	RootCmd.AddCommand(&cobra.Command{
		Use:   "status",
		Short: "Show the status of the current Pomodoro",
		RunE:  statusCmd,
	})
}

func statusCmd(cmd *cobra.Command, args []string) error {
	p, err := client.Current()
	if err != nil {
		return err
	}

	fmt.Println(format.Format(p, formatFlag))

	return nil
}
