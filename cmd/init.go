package cmd

import (
	"fmt"
	"os"

	"github.com/spf13/cobra"
)

func init() {
	command := &cobra.Command{
		Use:   "init",
		Short: "Initialize a new Open Pomodoro directory",
		RunE:  initCmd,
	}

	RootCmd.AddCommand(command)
}

func initCmd(cmd *cobra.Command, args []string) error {
	directory := client.Directory

	err := os.Mkdir(directory, os.ModeDir)
	if err == nil {
		fmt.Printf("Created %s\n", directory)
	} else {
		if os.IsExist(err) {
			fmt.Printf("%s already exists\n", directory)
		} else {
			return err
		}
	}

	return nil
}
