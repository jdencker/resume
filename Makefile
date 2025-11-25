SRC        := src/resume.tex
BUILD_DIR  := build
OUT_PDF    := $(BUILD_DIR)/resume.pdf
# Most Recent Multi-Arch Image -- Using Debian not Alpine for LateX
IMAGE_NAME := ghcr.io/xu-cheng/texlive-historic-debian:2024

.PHONY: all clean docker lint

# Local Build
all: $(OUT_PDF)

$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

$(OUT_PDF): $(SRC) | $(BUILD_DIR)
	latexmk -pdf -interaction=nonstopmode \
		-output-directory=$(BUILD_DIR) \
		$(SRC)

# Clean up Build Artifacts
clean:
	rm -rf $(BUILD_DIR)

# Docker build using TexLive docker image
docker:
	docker run --rm \
	  -v "$$(pwd)":/work \
	  -w /work \
	  $(IMAGE_NAME) \
	  make

lint:
	@if [ ! -f "$(OUT_PDF)" ]; then \
		echo "Error: $(OUT_PDF) not found — build the resume first (e.g. 'make docker')."; \
		exit 1; \
	fi

	@.venv/bin/python scripts/run_lint.py
