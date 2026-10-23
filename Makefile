OUT_DIR  := out
SRC_DIR  := .
TARGET   := $(OUT_DIR)/leaf

CC            := clang
TARGET_TRIPLE := powerpc-unknown-eabi
ARCH_FLAGS := -mcpu=750 -mno-altivec

CFLAGS   := --target=$(TARGET_TRIPLE) $(ARCH_FLAGS) -ffreestanding -std=c11 -Wall -Wextra -O2
ASFLAGS  := --target=$(TARGET_TRIPLE) $(ARCH_FLAGS) -ffreestanding -mregnames

LSCRIPT  := link.ld
LDFLAGS   := --target=$(TARGET_TRIPLE) -fuse-ld=lld -ffreestanding -nostdlib -Wl,-no-pie -T $(LSCRIPT)
LDLIBS   :=

# Separate sources by extension
C_SRCS   := $(wildcard $(SRC_DIR)/*.c)
S_SRCS   := $(wildcard $(SRC_DIR)/*.S)

# Map both .c and .S files into corresponding .o files in out/
OBJS     := $(patsubst $(SRC_DIR)/%.c, $(OUT_DIR)/%.o, $(C_SRCS)) \
            $(patsubst $(SRC_DIR)/%.S, $(OUT_DIR)/%.o, $(S_SRCS))

all: $(TARGET)

# Link object files
$(TARGET): $(OBJS)
	$(CC) $(LDFLAGS) $^ -o $@ $(LDLIBS)

# Compile C source files
$(OUT_DIR)/%.o: $(SRC_DIR)/%.c | $(OUT_DIR)
	$(CC) $(CFLAGS) -c $< -o $@

# Assemble Assembly source files
$(OUT_DIR)/%.o: $(SRC_DIR)/%.S | $(OUT_DIR)
	$(CC) $(ASFLAGS) -c $< -o $@

$(OUT_DIR):
	mkdir -p $(OUT_DIR)

.PHONY: all clean run
clean:
	rm -rf $(OUT_DIR)

run: $(TARGET)
	qemu-system-ppc \
	  -M pegasos2 \
	  -cpu g3 \
	  -m 512 \
	  -kernel $(TARGET) \
	  -display none \
	  -serial stdio \
	  -monitor none
