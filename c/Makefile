CC = gcc
CFLAGS = -Wall -Wextra -std=c99 -O2 -D_GNU_SOURCE
INCLUDES = -Iinclude
LIBS = -lcurl

# Targets
LIBRARY = libauthdog.a
TEST_EXECUTABLE = test_authdog
EXAMPLE_EXECUTABLE = example

# Source files
LIB_SOURCES = src/authdog.c
TEST_SOURCES = tests/test_authdog.c
EXAMPLE_SOURCES = examples/main.c

# Object files
LIB_OBJECTS = $(LIB_SOURCES:.c=.o)
TEST_OBJECTS = $(TEST_SOURCES:.c=.o)
EXAMPLE_OBJECTS = $(EXAMPLE_SOURCES:.c=.o)

# Default target
all: $(LIBRARY) $(TEST_EXECUTABLE) $(EXAMPLE_EXECUTABLE)

# Build static library
$(LIBRARY): $(LIB_OBJECTS)
	ar rcs $@ $^

# Build test executable
$(TEST_EXECUTABLE): $(TEST_OBJECTS) $(LIBRARY)
	$(CC) $(CFLAGS) -o $@ $^ $(LIBS)

# Build example executable
$(EXAMPLE_EXECUTABLE): $(EXAMPLE_OBJECTS) $(LIBRARY)
	$(CC) $(CFLAGS) -o $@ $^ $(LIBS)

# Compile source files
%.o: %.c
	$(CC) $(CFLAGS) $(INCLUDES) -c $< -o $@

# Run tests
test: $(TEST_EXECUTABLE)
	./$(TEST_EXECUTABLE)

# Clean build artifacts
clean:
	rm -f $(LIB_OBJECTS) $(TEST_OBJECTS) $(EXAMPLE_OBJECTS) $(LIBRARY) $(TEST_EXECUTABLE) $(EXAMPLE_EXECUTABLE)

# Install (basic)
install: $(LIBRARY)
	mkdir -p /usr/local/lib /usr/local/include
	cp $(LIBRARY) /usr/local/lib/
	cp include/authdog.h /usr/local/include/

# Uninstall
uninstall:
	rm -f /usr/local/lib/$(LIBRARY) /usr/local/include/authdog.h

.PHONY: all test clean install uninstall
