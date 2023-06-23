#!/bin/bash
as --32 -o bootsect.o bootsect.s
ld -m elf_i386 -Ttext 0 -o bootsect bootsect.o
