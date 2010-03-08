# Linux makefile
# Use with make 
#

.SUFFIXES:
.SUFFIXES: .o .asm .cpp .c

AS=nasm
ASFLAGS= -g -f elf
CFLAGS= -g
CC=gcc
CXX=g++
CXXFLAGS=

.asm.o:
	$(AS) $(ASFLAGS) $*.asm

.cpp.o:
	$(CXX) -c $(CXXFLAGS) $*.cpp

.c.o:
	$(CC) -c $(CFLAGS) $*.c

all: SJT SJT_for_benchmark perm_cpp_stl

SJT : driver.o SJT.o asm_io.o
	$(CC) $(CFLAGS) -oSJT driver.o SJT.o asm_io.o

SJT_for_benchmark: driver.o SJT_for_benchmark.o asm_io.o
	$(CC) $(CFLAGS) -oSJT_for_benchmark driver.o SJT_for_benchmark.o asm_io.o

perm_cpp_stl: perm_cpp_stl.o
		$(CXX) -o perm_cpp_stl perm_cpp_stl.cpp

asm_io.o : asm_io.asm
	$(AS) $(ASFLAGS) -d ELF_TYPE asm_io.asm

SJT.o : asm_io.inc

SJT_for_benchmark.o: asm_io.inc

driver.o : driver.c

clean :
	rm *.o SJT
