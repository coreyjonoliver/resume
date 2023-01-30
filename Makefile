USE_DOCKER ?= yes
DOCKER_IMAGE := ghcr.io/xu-cheng/texlive-full:20230101

BUILD_DIR := build
SOURCE := resume.tex
TARGET := $(BUILD_DIR)/resume.pdf

DOCKER = docker
DOCKER_OPTS = run --rm -v $(CURDIR):/workdir --workdir /workdir $(DOCKER_IMAGE)
XELATEX := xelatex
LATEXINDENT_OPTS := -y='defaultIndent: "  "'

ifeq "$(USE_DOCKER)" "yes"
	LATEXMK := $(DOCKER) $(DOCKER_OPTS) latexmk
	CHKTEX := $(DOCKER) $(DOCKER_OPTS) chktex
	LATEXINDENT := $(DOCKER) $(DOCKER_OPTS) latexindent
else
	LATEXMK := latexmk
	CHKTEX := chktex
	LATEXINDENT := latexindent
endif

.PHONY: all
all: check lint $(TARGET)

$(BUILD_DIR)/%.pdf: %.tex | $(BUILD_DIR)
	$(LATEXMK) \
		-pdf \
		-xelatex="$(XELATEX)" \
		-jobname=$(patsubst %.pdf,%,$@) \
		$<

$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

.PHONY: check
check: $(SOURCE)
	$(CHKTEX) $<

.PHONY: lint
lint: $(SOURCE)
	$(LATEXINDENT) $(LATEXINDENT_OPTS) -k $<

.PHONY: format
format: $(SOURCE)
	$(LATEXINDENT) $(LATEXINDENT_OPTS) -s -w $<

.PHONY: clean
clean:
	rm -rf $(BUILD_DIR)
	$(LATEXMK) -c $(SOURCE)
