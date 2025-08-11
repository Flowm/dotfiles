# Makefile for managing Homebrew packages with brew bundle
# https://docs.brew.sh/Manpage#bundle-subcommand

.PHONY: help dump install check upgrade upgrade-formula cleanup cleanup-run

export HOMEBREW_BUNDLE_DUMP_NO_VSCODE=false

# Default target
help: ## Show this help message
	@echo "Available targets:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2}'

dump: ## Dump all installed packages to Brewfile
	brew bundle dump --force --describe
	@python3 format-brewfile.py Brewfile
	@echo "Brewfile updated with current package state"

install: ## Install packages from Brewfile
	brew bundle install --no-upgrade
	# uv install python

check: ## Check if all packages in Brewfile are installed
	brew bundle check

upgrade: ## Upgrade all installed packages to latest versions
	brew outdated --formula
	brew cu

upgrade-formula: ## Upgrade all installed packages to latest versions
	brew upgrade --formula

cleanup: ## Remove packages not listed in Brewfile (preview)
	brew bundle cleanup

cleanup-run: ## Remove packages not listed in Brewfile
	brew bundle cleanup --force
