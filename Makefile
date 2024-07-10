SDIR=src
BDIR=build
TARGET=$(BDIR)/main
DEBUG=$(BDIR)/debug
SHADERDIR=shaders
SPVDIR=build/spv

OBJECTS = $(shell find $(SDIR) -name *.odin)
SHADERS = $(patsubst $(SHADERDIR)/%, $(SPVDIR)/%.spv, $(wildcard $(SHADERDIR)/*))

.PHONY: default all run debug clean

.PRECIOUS: $(TARGET)

default: $(TARGET)
all: default

$(SPVDIR)/%.spv: $(SHADERDIR)/%
	glslc $< -o $@

$(TARGET): $(OBJECTS) $(SHADERS)
	odin build $(SDIR) -out:$@

$(DEBUG): $(OBJECTS)
	odin build $(SDIR) -out:$@ -debug

run: $(TARGET)
	./$<

debug: $(DEBUG)
	gdb $<

clean:
	-rm -f $(TARGET) $(DEBUG) $(SPVDIR)/*

