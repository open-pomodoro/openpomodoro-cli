# Open-Pomodoro CLI

> A command-line Pomodoro tracker which uses the [Open Pomodoro Format](https://github.com/open-pomodoro/open-pomodoro-format/blob/master/README.md)

## Installation

`#TODO`

## Usage

### Start a Pomodoro

```
$ pomodoro start
25:00 🍅

# Start a Pomodoro in the past
$ pomodoro start --ago 10m
15:00 🍅

# Set the Pomodoro duration in minutes
$ pomodoro start 30
30:00 🍅

# Set the Pomodoro duration in seconds
$ pomodoro start 22m30s
22:30 🍅

# Provide a description and tags
$ pomodoro start "Blog post" -t writing,personal
25:00 🍅
Writing a blog post
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
