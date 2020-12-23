
PROG = assembler 

CC = g++
CXXFLAGS = -Wall -Wextra -std=c++17
CPPFLAGS = #-I /usr/include -L /usr/lib
SRC = $(wildcard *.cpp)
OBJ = $(SRC:.cpp=.o)
LDFLAGS = 

all: build run 

run:
	./$(PROG) "fullTest.asm" "128"

build: $(PROG)

$(PROG): $(OBJ)
	$(CC) $(CXXFLAGS) -o $@ $(OBJ) $(CPPFLAGS) $(LDFLAGS)

clean:
	rm -f *stackdump $(PROG) $(OBJ)
