SRCS := $(shell find . -type f -name '*.sv')
DSTS := $(patsubst %.sv,../src/%.v,$(SRCS))

FLAGS := -I. -v

all: $(DSTS)

../src/%.v: %.sv
	@mkdir -p $(@D)
	sv2v $(FLAGS) $< > $@
