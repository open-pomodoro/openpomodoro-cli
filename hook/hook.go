package hook

import (
	"fmt"
	"os"
	"os/exec"
	"path"

	"github.com/open-pomodoro/go-openpomodoro"
)

// Run runs a hook with the given name.
func Run(client *openpomodoro.Client, name string) error {
	return RunWithEnv(client, name, nil)
}

// RunWithEnv runs a hook with the given name and additional environment variables.
func RunWithEnv(client *openpomodoro.Client, name string, extraEnv map[string]string) error {
	filename := path.Join(client.Directory, "hooks", name)

	if _, err := os.Stat(filename); os.IsNotExist(err) {
		return nil
	}

	cmd := exec.Command(filename)
	cmd.Stdout = os.Stdout
	cmd.Stderr = os.Stderr
	
	env := os.Environ()
	for key, value := range extraEnv {
		env = append(env, fmt.Sprintf("%s=%s", key, value))
	}
	cmd.Env = env
	
	if err := cmd.Run(); err != nil {
		fmt.Fprintf(os.Stderr, "Hook %q failed:\n\n", name)
		return err
	}

	return nil
}
