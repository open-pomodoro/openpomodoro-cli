package cmd

import (
	"fmt"

	"github.com/spf13/cobra"
)

var versionCmd = &cobra.Command{
	Use:   "version",
	Short: "Print version information",
	Run: func(cmd *cobra.Command, args []string) {
		fmt.Printf("pomodoro version %s\n", RootCmd.Version)
	},
}

func init() {
	RootCmd.AddCommand(versionCmd)
}
