USE_DOCKER ?= yes
DOCKER_IMAGE := ghcr.io/xu-cheng/texlive-full:20230101

BUILD_DIR := build
SOURCE := resume.tex
TARGET := $(BUILD_DIR)/resume.pdf

DOCKER = docker
DOCKER_OPTS = run --rm -v $(CURDIR):/workdir --workdir /workdir $(DOCKER_IMAGE)
XELATEX := xelatex

ifeq "$(USE_DOCKER)" "yes"
	LATEXMK := $(DOCKER) $(DOCKER_OPTS) latexmk
	CHKTEX := $(DOCKER) $(DOCKER_OPTS) chktex
else
	LATEXMK := latexmk
	CHKTEX := chktex
endif

.PHONY: all
all: check $(TARGET)

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

.PHONY: clean
clean:
	rm -rf $(BUILD_DIR)
	$(LATEXMK) -c $(SOURCE)
