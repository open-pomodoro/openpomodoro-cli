# Open-Pomodoro CLI

> A command-line Pomodoro tracker which uses the [Open Pomodoro Format](https://github.com/open-pomodoro/open-pomodoro-format/blob/master/README.md)

## Table of Contents

* [Installation](#installation)
* [Usage](#usage)
  * [Start a Pomodoro](#start-a-pomodoro)
  * [Amend the current Pomodoro](#amend-the-current-pomodoro)
  * [Check the status of the current Pomodoro](#check-the-status-of-the-current-pomodoro)
  * [Clear a finished Pomodoro](#clear-a-finished-pomodoro)
  * [Cancel an active Pomodoro](#cancel-an-active-pomodoro)
  * [Finish a Pomodoro early (or late)](#finish-a-pomodoro-early-or-late)
  * [Take a break](#take-a-break)
  * [Repeat the last Pomodoro](#repeat-the-last-pomodoro)
  * [Show Pomodoro history](#show-pomodoro-history)
* [Status Format](#status-format)
  * [Available Parts](#available-parts)
* [Hooks](#hooks)

## Installation

1. Download the latest package for your platform from the [Releases page](https://github.com/open-pomodoro/openpomodoro-cli/releases/latest).
2. Untar the package with `tar -zxvf openpomodoro-cli*.tar.gz`.
3. Move the extracted `openpomodoro-cli` file to a directory in your `$PATH` (for most systems, this will be `/usr/local/bin/`).

Or, if you have a [Go development environment](https://golang.org/doc/install):

```
go get -u github.com/open-pomodoro/openpomodoro-cli/cmd/pomodoro
```

> If you already have another command named `pomodoro`, use `go get github.com/open-pomodoro/openpomodoro-cli` to install the `openpomodoro-cli` command.

## Usage

### Start a Pomodoro

```
$ pomodoro start
25:00 🍅

# Start a Pomodoro in the past
$ pomodoro start --ago 10m
15:00 🍅

# Set the Pomodoro duration in minutes
$ pomodoro start --duration 30
30:00 🍅

# Set the Pomodoro duration in seconds
$ pomodoro start --duration 22m30s
22:30 🍅

# Provide a description and tags
$ pomodoro start "Blog post" -t writing,personal
25:00 🍅
Blog post
writing,personal

# Block until the Pomodoro finishes
$ pomodoro start --wait
25:00 🍅
24:99
```

### Amend the current Pomodoro

```
$ pomodoro start "Blog postt" --tags writing,personal
25:00 🍅
Blog postt
writing,personal

# Pass any options accepted by start. Only passed options will be changed.
$ pomodoro amend "Blog post"
24:30 🍅
Blog post
writing,personal
```

### Check the status of the current Pomodoro

```
$ pomodoro status
12:34 🍅

# When the Pomodoro has finished
$ pomodoro status
❗🍅

# Customize the status format
$ pomodoro status -f "%mr %c/%g 🍅"
12 🍅 2/8

# Block until the Pomodoro finishes
$ pomodoro status --wait
12:34 🍅
12:33
```

See [](#status-format) below for documentation on the status format string.

### Clear a finished Pomodoro

```
$ pomodoro status
❗🍅
$ pomodoro clear
$ pomodoro status
```

### Cancel an active Pomodoro

```
$ pomodoro status
12:34 🍅
$ pomodoro cancel
$ pomodoro status
```


### Finish a Pomodoro early (or late)

```
$ pomodoro status
12:34 🍅
$ pomodoro finish
$ pomodoro status
❗️🍅
```

### Take a break

```
$ pomodoro break
4:59

$ pomodoro break 15
14:59
```

### Repeat the last Pomodoro

```
$ pomodoro repeat
25:00 🍅
Writing a blog post
writing,personal

# Block until the Pomodoro finishes
$ pomodoro repeat --wait
25:00 🍅
Writing a blog post
writing,personal
24:59
```

### Show Pomodoro history

```
$ pomodoro history
2015-06-14T12:34:00-04:00 description="Blog post" duration=25 tags=writing,personal

# Output in JSON format
$ pomodoro history --output json
{
  "pomodoros": [
    {
      "start_time": "2015-06-14T12:34:56-04:00",
      "description": "Blog Post",
      "duration": 25,
      "tags": [
        "writing",
        "personal"
      ]
    }
  ]
}

# Output in iCal format
$ pomodoro history --output ical > ~/Pomodoros.ics
```

## Status Format

All commands which display the status of a single Pomodoro can take an additional `--format` / `-f` argument.
This argument controls how to display the Pomodoro.

By default, it displays the time remaining (or an Emoji exclamation point if zero), an Emoji tomato, the description, and tags.
Consecutive spaces and newlines are de-duplicated.

```
$ pomodoro status
12:34 🍅 
Writing a blog post
writing,personal

$ pomodoro status --format "%R ⏱ %c/%g 🍅\n%d"
13 ⏱ 2/8 🍅
Writing a blog post
```

### Available Parts

```
# Time
%r  - Time remaining in mm:ss
%R  - Time remaining in minutes, rounded
%!r - Same as %r, but with an exclamation point if the Pomodoro is done
%!R - Same as %R, but with an exclamation point if the Pomodoro is done
%l  - Length of the Pomodoro in mm:ss
%L  - Length of the Pomodoro in minutes

# Metadata
%d  - Pomodoro description
%t  - Pomodoro tags, joined by a comma

# Goals
%g  - Daily Pomodoro goal
%!g  - Daily Pomodoro goal, with a preceding slash
%c  - Completed Pomodoros today
%l  - Pomodoros remaining (left) to reach goal
```
## Hooks

Hooks can be run when Pomodoros change state. There are 3 possible hooks:

* `break`
* `start`
* `stop`

Commands which run hooks:

* `break`: `break` immediately, `stop` when break is over
* `cancel`: `stop`
* `clear`: `stop`
* `finish`: `stop`
* `repeat`: `start`
* `start`: `start`

To enable a hook, create an executable file in the `hooks` subdirectory within your configuration directory. For example:

```sh
#!/usr/bin/env bash
set -exo pipefail

say "Pomodoro started"
```

```shellsession
$ chmod +x ~/.pomodoro/hooks/start
```
