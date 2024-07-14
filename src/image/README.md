
## Make sure the .sh script uses LF and not CRLF line endings (if using windows)

```text
runner@27da153eab9d:~$ ./config.sh --help

Commands:
 ./config.sh         Configures the runner
 ./config.sh remove  Unconfigures the runner
 ./run.sh            Runs the runner interactively. Does not require any options.

Options:
 --help     Prints the help for each command
 --version  Prints the runner version
 --commit   Prints the runner commit

Config Options:
 --unattended     Disable interactive prompts for missing arguments. Defaults will be used for missing options
 --url string     Repository to add the runner to. Required if unattended
 --token string   Registration token. Required if unattended
 --name string    Name of the runner to configure (default 89ba235fdc6c)
 --work string    Relative runner work directory (default _work)
 --replace        Replace any existing runner with the same name (default false)

Examples:
 Configure a runner non-interactively:
  ./config.sh --unattended --url <url> --token <token>
 Configure a runner non-interactively, replacing any existing runner with the same name:
  ./config.sh --unattended --url <url> --token <token> --replace [--name <name>]
```