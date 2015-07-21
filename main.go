package main

import (
    // "bytes"
    // "code.google.com/p/go.crypto/ssh"
    "fmt"
    // "io"
    // "io/ioutil"
    "os"
    "syscall"
    "github.com/jessevdk/go-flags"
    "github.com/tillberg/ansi-log"
)

var OptsCommon struct {
    Verbose bool `short:"v" long:"verbose" description:"Show verbose debug information"`
    Version bool `long:"version"`
    NoColor bool `long:"no-color"`
    InstallDeps bool `long:"install-deps"`
}

var OptsSync struct {
    IdentityFile string `short:"i" long:"identity"`
    Dev bool `long:"dev"`
    Positional struct {
        LocalPath  string
        RemotePath string
    } `positional-args:"yes" required:"yes"`
}

func main() {
    var args []string = os.Args[1:]
    if len(args) == 0 {
        log.Fatalln("You must specify a gut-command, e.g. `gut sync ...`")
    }
    var cmd = args[0]
    args = args[1:]
    if IsGitCommand(cmd) {
        var gutExe = PathInUserHome(GutExePath)
        syscall.Exec(gutExe, append([]string { gutExe }, args...), os.Environ())
        log.Fatalf("Failed to exec %s", gutExe)
    }
    var argsRemaining, err = flags.ParseArgs(&OptsCommon, args)
    if err != nil { log.Fatal(err) }
    // fmt.Printf("color: %s\n", OptsCommon.NoColor)
    if OptsCommon.Version {
        log.Print("gut-sync version XXXXX")
        os.Exit(0)
    }
    if cmd == "build" {
        // var local = SyncContext(nil, nil)
        // if !EnsureBuild(local) {
        //     log.Printf("(@dim)gut " + GitVersion + "(@dim) has already been built.\n")
        // }
    } else if cmd == "sync" {
        var _, err = flags.ParseArgs(&OptsSync, argsRemaining)
        if err != nil { log.Fatal(err) }

        fmt.Printf("local path: %s\n", OptsSync.Positional.LocalPath)
        fmt.Printf("remote path: %s\n", OptsSync.Positional.RemotePath)
    }
}
