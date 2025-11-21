SRC        := src/resume.tex
BUILD_DIR  := build
OUT_PDF    := $(BUILD_DIR)/resume.pdf
IMAGE_NAME := resume-latex-builder

.PHONY: all clean docker-image docker

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

# Docker Build - no local LaTeX Distribution needed
docker-image:
	docker build -t $(IMAGE_NAME) .

docker: docker-image
	docker run --rm \
	  -v "$$(pwd)":/work \
	  -w /work \
	  $(IMAGE_NAME) \
	  make