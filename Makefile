CC=g++
OBJDIR=objs
SRCDIR=src
INCDIR=$(SRCDIR)/inc
CFLAGS+=-I$(INCDIR)
platform=$(shell uname -s)

SRCS=$(wildcard $(SRCDIR)/*.c)
OBJS=$(patsubst $(SRCDIR)/%.c,$(OBJDIR)/%.o,$(SRCS))

CFLAGS+=-O2 -Wall -L.
ifeq ($(platform), Linux)
CFLAGS+=-DPA_USE_ALSA
else
CFLAGS+=-DPA_USE_COREAUDIO
endif
CFLAGS+=`pkg-config --cflags opencv`
CFLAGS_DEBUG+=-O0 -g3 -Werror -DDEBUG
LDFLAGS+=-lpthread -lncurses -lportaudio -lm -lzt -ldl
LDFLAGS+=`pkg-config --libs opencv`

all: cathode

.PHONY: all clean debug

debug: CC := $(CC) $(CFLAGS_DEBUG)
debug: clean cathod

cathode: $(OBJS)
	$(CC) $(CFLAGS) $^ -o $@ $(LDFLAGS)

video: CFLAGS := $(CFLAGS) -DVIDEOONLY
video: $(filter-out objs/cathode.o, $(OBJS))
	$(CC) $(CFLAGS) $^ -o $@ $(LDFLAGS)

audio: CFLAGS := $(CFLAGS) -DAUDIOONLY
audio: $(filter-out objs/cathode.o, $(OBJS))
	$(CC) $(CFLAGS) $^ -o $@ $(LDFLAGS)

$(OBJS): | $(OBJDIR)
$(OBJDIR):
	mkdir -p $@

$(OBJDIR)/%.o: $(SRCDIR)/%.c $(wildcard $(INCDIR)/*.h) Makefile
	$(CC) $(CFLAGS) $< -c -o $@

clean:
	rm -rf $(OBJDIR) audio video cathode
