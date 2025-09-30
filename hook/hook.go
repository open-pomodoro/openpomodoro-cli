package hook

import (
	"fmt"
	"os"
	"os/exec"
	"path"
	"strings"
	"time"

	"github.com/open-pomodoro/go-openpomodoro"
)

// Run runs a hook with the given name.
func Run(client *openpomodoro.Client, name string, pomodoroID string, command string, args []string, breakDuration time.Duration) error {
	filename := path.Join(client.Directory, "hooks", name)

	if _, err := os.Stat(filename); os.IsNotExist(err) {
		return nil
	}

	cmd := exec.Command(filename)
	cmd.Stdout = os.Stdout
	cmd.Stderr = os.Stderr
	cmd.Env = os.Environ()
	cmd.Env = append(cmd.Env,
		fmt.Sprintf("POMODORO_ID=%s", pomodoroID),
		fmt.Sprintf("POMODORO_DIRECTORY=%s", client.Directory),
		fmt.Sprintf("POMODORO_COMMAND=%s", command),
		fmt.Sprintf("POMODORO_ARGS=%s", joinArgs(args)),
	)

	if breakDuration > 0 {
		cmd.Env = append(cmd.Env,
			fmt.Sprintf("POMODORO_BREAK_DURATION_MINUTES=%d", int(breakDuration.Minutes())),
			fmt.Sprintf("POMODORO_BREAK_DURATION_SECONDS=%d", int(breakDuration.Seconds())),
		)
	}

	if err := cmd.Run(); err != nil {
		fmt.Fprintf(os.Stderr, "Hook %q failed:\n\n", name)
		return err
	}

	return nil
}

func joinArgs(args []string) string {
	return strings.Join(args, " ")
}
