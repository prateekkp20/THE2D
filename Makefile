# ===========================================================================
#  Makefile for coulomb.x  (2D-PME and XYZ Ewald)
#
#  Usage:
#    make                          # GSL/FFTW found automatically (system install)
#    make GSL_DIR=$HOME/gsl        # GSL installed in a custom location
#    make FFTW_DIR=$HOME/fftw      # FFTW installed in a custom location
#    make DEBUG=1                  # add debug symbols (gdb / VTune)
#    make ARCH=-mavx2              # portable build (runs on other AVX2 CPUs)
#    make clean                    # removes obj/*.o and obj/*.d only; run/ is never touched
# ===========================================================================

# ---------------------------------------------------------------- compiler --
CXX       ?= g++
ARCH      ?= -march=native
DEFINES    = -DDSFMT_MEXP=19937
WARNINGS   = -Wall -Wno-unused-variable -Wno-unused-but-set-variable

CXXFLAGS  ?= -O3 $(ARCH) -ftree-vectorize -fopenmp -pthread
LDFLAGS   ?= -fopenmp -pthread

ifeq ($(DEBUG),1)
  CXXFLAGS += -g
endif

ifeq ($(VECREPORT),1)
  CXXFLAGS += -fopt-info-vec-optimized
endif

# -------------------------------------------------------------------- GSL --
# Uses GSL_DIR if given, otherwise asks gsl-config (system-wide install).
ifdef GSL_DIR
  GSL_CFLAGS := -I$(GSL_DIR)/include
  GSL_LIBS   := -L$(GSL_DIR)/lib -Wl,-rpath,$(GSL_DIR)/lib -lgsl -lgslcblas -lm
else
  GSL_CFLAGS := $(shell gsl-config --cflags 2>/dev/null)
  GSL_LIBS   := $(shell gsl-config --libs 2>/dev/null)
endif

# ------------------------------------------------------------------- FFTW --
# Uses FFTW_DIR if given, otherwise assumes a system-wide install.
FFTW_LINK := -lfftw3_omp -lfftw3_threads -lfftw3 -lm
ifdef FFTW_DIR
  FFTW_CFLAGS := -I$(FFTW_DIR)/include
  FFTW_LIBS   := -L$(FFTW_DIR)/lib -Wl,-rpath,$(FFTW_DIR)/lib $(FFTW_LINK)
else
  FFTW_CFLAGS :=
  FFTW_LIBS   := $(FFTW_LINK)
endif

ifneq ($(MAKECMDGOALS),clean)
  ifeq ($(strip $(GSL_LIBS)),)
    $(error GSL not found. Install it (openSUSE: gsl-devel, Ubuntu: libgsl-dev) or run: make GSL_DIR=/path/to/gsl)
  endif
endif

# ---------------------------------------------------------------- folders --
SRC_DIR = src
INC_DIR = inc
OBJ_DIR = obj
RUN_DIR = run
TARGET  = $(RUN_DIR)/coulomb.x

INCLUDES = -I$(INC_DIR) $(GSL_CFLAGS) $(FFTW_CFLAGS)

# ---------------------------------------------------------------- sources --
# .c files are compiled as C++ (same as the original build).
SRCS = main.cpp \
       dist.cpp \
       dSFMT.c \
       func.cpp \
       print.cpp \
       real.cpp \
       reciprocal.c \
       self.c \
       reci_integral.cpp \
       reci_fftw2.cpp \
       reci_0.cpp \
       screening_coeff2D.cpp \
       PM2DEwald.cpp

OBJS = $(addprefix $(OBJ_DIR)/,$(addsuffix .o,$(basename $(SRCS))))
DEPS = $(OBJS:.o=.d)

# ------------------------------------------------------------------ rules --
.PHONY: all clean

all: $(TARGET)

$(TARGET): $(OBJS) | $(RUN_DIR)
	$(CXX) $(LDFLAGS) $(OBJS) -o $@ $(FFTW_LIBS) $(GSL_LIBS)

$(OBJ_DIR)/%.o: $(SRC_DIR)/%.cpp | $(OBJ_DIR)
	$(CXX) $(CXXFLAGS) $(WARNINGS) $(DEFINES) $(INCLUDES) -MMD -MP -c $< -o $@

$(OBJ_DIR)/%.o: $(SRC_DIR)/%.c | $(OBJ_DIR)
	$(CXX) -x c++ $(CXXFLAGS) $(WARNINGS) $(DEFINES) $(INCLUDES) -MMD -MP -c $< -o $@

$(OBJ_DIR) $(RUN_DIR):
	mkdir -p $@

clean:
	$(RM) $(OBJS) $(DEPS)

-include $(DEPS)