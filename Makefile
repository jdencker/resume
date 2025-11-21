SRC        := src/resume.tex
BUILD_DIR  := build
OUT_PDF    := $(BUILD_DIR)/resume.pdf

.PHONY: all clean

all: 
	@if $(MAKE) --question $(OUT_PDF); then \
		echo "No changes in '$(SRC)' detected since last build."; \
	else \
		$(MAKE) $(OUT_PDF); \
	fi

$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

$(OUT_PDF): $(SRC) | $(BUILD_DIR)
	latexmk -pdf -interaction=nonstopmode \
		-output-directory=$(BUILD_DIR) \
		$(SRC)

clean:
	rm -rf $(BUILD_DIR)