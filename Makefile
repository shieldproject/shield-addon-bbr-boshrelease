SHELL := /bin/bash

# BBR upstream release URL
BBR_VERSION := 1.9.77
BBR_MIRROR  := https://github.com/cloudfoundry/bosh-backup-and-restore/releases/download

.DEFAULT_GOAL := help

.PHONY: help
help: ## Show available targets
	@printf "\n\033[1mSHIELD BBR Addon - Blob Management\033[0m\n\n"
	@printf "\033[36m%-24s\033[0m %s\n" "Target" "Description"
	@printf "\033[36m%-24s\033[0m %s\n" "------" "-----------"
	@grep -E '^[a-zA-Z0-9._-]+:.*##' $(MAKEFILE_LIST) \
		| sed 's/:.*## /\t/' \
		| awk -F'\t' '{ printf "\033[33m%-24s\033[0m %s\n", $$1, $$2 }'
	@echo

.PHONY: blobs
blobs: blobs/bbr/bbr ## Download BBR binary blob

blobs/bbr/bbr:
	@mkdir -p blobs/bbr
	@printf "\033[36m>>>\033[0m Downloading \033[33mBBR $(BBR_VERSION)\033[0m ...\n"
	@curl -fSL "$(BBR_MIRROR)/v$(BBR_VERSION)/bbr-$(BBR_VERSION).tar" \
		| tar -xf - -C blobs/bbr releases/bbr --strip-components=1 \
		|| { rm -f "$@"; printf "\033[31m!!! Download failed\033[0m\n"; exit 1; }
	@chmod 0755 "$@"
	@printf "\033[32m    ok\033[0m %s\n" "$@"

.PHONY: verify
verify: ## Verify blob checksum against config/blobs.yml
	@printf "\n\033[1mVerifying blob checksums\033[0m\n\n"
	@if [ ! -f blobs/bbr/bbr ]; then \
		printf "\033[33m  SKIP\033[0m bbr/bbr (not downloaded)\n\n"; \
		exit 0; \
	fi; \
	expected=$$(awk '/^bbr\/bbr:/,/sha:/' config/blobs.yml \
		| grep 'sha:' | head -1 | sed 's/.*sha256://'); \
	if [ -z "$$expected" ]; then \
		printf "\033[33m  SKIP\033[0m bbr/bbr (no sha256 in blobs.yml)\n\n"; \
		exit 0; \
	fi; \
	actual=$$(shasum -a 256 blobs/bbr/bbr | awk '{print $$1}'); \
	if [ "$$actual" = "$$expected" ]; then \
		printf "\033[32m    ok\033[0m bbr/bbr\n\n"; \
	else \
		printf "\033[31m  FAIL\033[0m bbr/bbr\n"; \
		printf "       expected: %s\n" "$$expected"; \
		printf "         actual: %s\n\n" "$$actual"; \
		exit 1; \
	fi

.PHONY: clean
clean: ## Remove all downloaded blobs
	rm -rf blobs/bbr
	@printf "\033[32mCleaned\033[0m blobs/bbr\n"

.PHONY: list
list: ## List blob and download status
	@printf "\n\033[1mBBR Blob\033[0m\n\n"
	@printf "\033[36m%-16s %-32s %s\033[0m\n" "Version" "Blob" "Status"
	@printf "\033[36m%-16s %-32s %s\033[0m\n" "-------" "----" "------"
	@if [ -f blobs/bbr/bbr ]; then \
		printf "\033[33m%-16s\033[0m %-32s \033[32m%s\033[0m\n" "$(BBR_VERSION)" "blobs/bbr/bbr" "downloaded"; \
	else \
		printf "\033[33m%-16s\033[0m %-32s \033[31m%s\033[0m\n" "$(BBR_VERSION)" "blobs/bbr/bbr" "missing"; \
	fi
	@echo
