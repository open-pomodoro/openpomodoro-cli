package main

import "github.com/open-pomodoro/openpomodoro-cli/cmd"

// Version is the version of this tool. It is set from LDFLAGS in the
// Makefile/build process.
var Version = "dev"

func init() {
	cmd.RootCmd.Version = Version
}

func main() {
	cmd.Execute()
}
