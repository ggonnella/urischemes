help:
	@echo "# Generate and install handlers"
	@echo
	@echo "# Available commands:"
	@echo
	@echo "make github"
	@echo "make wikipedia"

.PHONY: github wikipedia

github:
	generate-uri-handler.sh github https://github.com/%s/%s ggonnella > handlers/github-opener.desktop
	install-uri-handler.sh github --opener handlers/github-opener.desktop --force

wikipedia:
	generate-uri-handler.sh wikipedia https://%s.wikipedia.org/wiki/%s en > handlers/wikipedia-opener.desktop
	install-uri-handler.sh wikipedia --opener handlers/wikipedia-opener.desktop --force
