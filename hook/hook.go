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

// Params holds the parameters for running a hook.
type Params struct {
	Name          string
	PomodoroID    string
	Command       string
	Args          []string
	BreakDuration time.Duration
}

// Run runs a hook with the given name.
func Run(client *openpomodoro.Client, params Params) error {
	filename := path.Join(client.Directory, "hooks", params.Name)

	if _, err := os.Stat(filename); os.IsNotExist(err) {
		return nil
	}

	cmd := exec.Command(filename)
	cmd.Stdout = os.Stdout
	cmd.Stderr = os.Stderr
	cmd.Env = os.Environ()
	cmd.Env = append(cmd.Env,
		fmt.Sprintf("POMODORO_ID=%s", params.PomodoroID),
		fmt.Sprintf("POMODORO_DIRECTORY=%s", client.Directory),
		fmt.Sprintf("POMODORO_COMMAND=%s", params.Command),
		fmt.Sprintf("POMODORO_ARGS=%s", joinArgs(params.Args)),
	)

	if params.BreakDuration > 0 {
		cmd.Env = append(cmd.Env,
			fmt.Sprintf("POMODORO_BREAK_DURATION_MINUTES=%d", int(params.BreakDuration.Minutes())),
			fmt.Sprintf("POMODORO_BREAK_DURATION_SECONDS=%d", int(params.BreakDuration.Seconds())),
		)
	}

	if err := cmd.Run(); err != nil {
		fmt.Fprintf(os.Stderr, "Hook %q failed:\n\n", params.Name)
		return err
	}

	return nil
}

func joinArgs(args []string) string {
	return strings.Join(args, " ")
}
