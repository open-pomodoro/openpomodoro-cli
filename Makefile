DEMO_COMMANDS := start status end status start clear status
DEMO_COMMANDS := start status
TMPDIR := $(shell mktemp -d)

demo: bin/pomodoro
	@for s in $(DEMO_COMMANDS); do \
	  echo; \
	  echo $$ pomodoro $$s; \
	  pomodoro --directory $(TMPDIR) $$s; \
	done

bin/pomodoro: *.go
	go build -o $@

.PHONY: demo
