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
	filename := path.Join(client.Directory, "hooks", name)

	if _, err := os.Stat(filename); os.IsNotExist(err) {
		return nil
	}

	cmd := exec.Command(filename)
	cmd.Env = os.Environ()
	if output, err := cmd.Output(); err != nil {
		fmt.Printf("Hook %q failed:\n%s\n\n", name, output)
		return err
	}

	return nil
}
