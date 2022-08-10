package main

import (
	"fmt"

	"github.com/tslamic/go-starter/version"
)

func main() {
	//nolint:forbidigo
	fmt.Printf("Built by %s at %s on branch %s, version %s (%s)\n",
		version.Builder,
		version.BuiltAt,
		version.Branch,
		version.Version,
		version.Commit,
	)
}
