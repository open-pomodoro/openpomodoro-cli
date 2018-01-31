package cmd

import (
	"io/ioutil"
	"log"
	"path/filepath"

	"github.com/crufter/copyrecur"
)

func fixture(f string) string {
	tmpDir, err := ioutil.TempDir("", f)
	if err != nil {
		log.Fatal(err)
	}
	tmpDir = filepath.Join(tmpDir, f)

	if f != "" {
		err := copyrecur.CopyDir(filepath.Join("../fixtures", f), tmpDir)
		if err != nil {
			log.Fatal(err)
		}
	}

	return tmpDir
}
