# ==============================================================================
# CLOS.org Build System
# ==============================================================================
# This Makefile provides containerized Nix-based build targets using Docker.
# It ensures reproducible builds by running Nix commands inside a Docker
# container, eliminating the need for local Nix installation.
#
# Available targets:
#   make build  - Build the project using Nix flakes (default)
#   make serve  - Start a local development server (runs on port 8080)
#   make check  - Run flake checks to validate the configuration
#   make clean  - Remove build artifacts (result/ and public/ directories)
#   make help   - Display this help message
#
# Configuration variables:
#   DOCKER       - Docker command to use (default: docker)
#   NIX_VERSION  - Version of the nixos/nix Docker image (default: 2.32.2)
# ==============================================================================

# Use a single shell for all commands in a recipe
.ONESHELL:

# Delete target files if a recipe fails
.DELETE_ON_ERROR:

# Disable built-in implicit rules
.SUFFIXES:

# Mark phony targets (targets that don't represent files)
.PHONY: all build serve check clean help

# Docker command (can be overridden with podman, etc.)
DOCKER ?= docker

# Nix Docker image version
NIX_VERSION ?= 2.32.2

# Nix Docker image
NIX_IMAGE := nixos/nix:$(NIX_VERSION)

# Nix CLI arguments for enabling flakes support
NIX_CLI_ARGS := --extra-experimental-features nix-command --extra-experimental-features flakes

# Docker run command template (reduces duplication)
DOCKER_RUN = $(DOCKER) run -it --rm \
	-v $(CURDIR):/workspace \
	-p 8080:8080 \
	--workdir /workspace \
	$(NIX_IMAGE)

# Default target
all: build

# Display help information
help:
	@echo "CLOS.org Build System"
	@echo ""
	@echo "Available targets:"
	@echo "  make build   - Build the project using Nix flakes (default)"
	@echo "  make serve   - Start a local development server (runs on port 8080)"
	@echo "  make check   - Run flake checks to validate the configuration"
	@echo "  make clean   - Remove build artifacts"
	@echo "  make help    - Display this help message"
	@echo ""
	@echo "Configuration variables:"
	@echo "  DOCKER=$(DOCKER)"
	@echo "  NIX_VERSION=$(NIX_VERSION)"

# Build the project using Nix flakes inside Docker container
build:
	$(DOCKER_RUN) nix $(NIX_CLI_ARGS) build

# Start local development server (accessible at http://localhost:8080)
serve:
	$(DOCKER_RUN) nix $(NIX_CLI_ARGS) develop -c serve-site

# Run Nix flake checks to validate the configuration
check:
	$(DOCKER_RUN) nix $(NIX_CLI_ARGS) flake check

# Clean build artifacts
clean:
	rm -rf result/ public/
