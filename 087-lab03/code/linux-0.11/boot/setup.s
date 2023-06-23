	.code16
# rewrite with AT&T syntax by falcon <wuzhangjin@gmail.com> at 081012
#
# SYS_SIZE is the number of clicks (16 bytes) to be loaded.
# 0x3000 is 0x30000 bytes = 196kB, more than enough for current
# versions of linux
#
	.equ SYSSIZE, 0x3000
#
#	bootsect.s		(C) 1991 Linus Torvalds
#
# bootsect.s is loaded at 0x7c00 by the bios-startup routines, and moves
# iself out of the way to address 0x90000, and jumps there.
#
# It then loads 'setup' directly after itself (0x90200), and the system
# at 0x10000, using BIOS interrupts. 
#
# NOTE! currently system is at most 8*65536 bytes long. This should be no
# problem, even in the future. I want to keep it simple. This 512 kB
# kernel size should be enough, especially as this doesn't contain the
# buffer cache as in minix
#
# The loader has been made as simple as possible, and continuos
# read errors will result in a unbreakable loop. Reboot by hand. It
# loads pretty fast by getting whole sectors at a time whenever possible.

	.global _start, begtext, begdata, begbss, endtext, enddata, endbss
	.text
	begtext:
	.data
	begdata:
	.bss
	begbss:
	.text

	.equ INITSEG, 0x9000
	.equ SETUPSEG, 0x07e0		# setup starts here
	.equ SYSSEG, 0x1000		# system loaded at 0x10000 (65536).
	.equ ENDSEG, SYSSEG + SYSSIZE	# where to stop loading

# ROOT_DEV:	0x000 - same type of floppy as boot.
#		0x301 - first partition on first drive etc
_start:
	mov	$SETUPSEG, %ax
	mov	%ax, %ds	
	mov	%ax, %es
	mov	$0x03, %ah		# read cursor pos
	xor	%bh, %bh
	int	$0x10
	mov	$28, %cx
	mov	$0x0007, %bx		# page 0, attribute 7 (normal)
	#lea	msg1, %bp
	mov     $msg2, %bp
	mov	$0x1301, %ax		# write string, move cursor
	int	$0x10

	jmp load_hd

load_hd:
	mov	$INITSEG, %ax	# this is done in bootsect already, but...
	mov	%ax, %ds
	mov	$0x03, %ah	# read cursor pos
	xor	%bh, %bh
	int	$0x10		# save it in known place, con_init fetches
	mov	%dx, %ds:0	# it from 0x90000.
# Get memory size (extended mem, kB)

	mov	$0x88, %ah 
	int	$0x15
	mov	%ax, %ds:2

# Get hd0 data
	mov	$0x0000, %ax
	mov	%ax, %ds
	lds	%ds:4*0x41, %si
	mov	$INITSEG, %ax
	mov	%ax, %es
	mov	$0x0080, %di
	mov	$0x10, %cx
	rep
	movsb

message_show:
	mov 	$INITSEG,%ax
	mov		%ax,%ds
	mov 	$SETUPSEG, %ax
	mov		%ax,%es
	mov    	$0x03,%ah
	xor	   	%bh, %bh
	int  	$0x10
	mov  	$11,%cx
	mov		$0x0007, %bx		# page 0, attribute 7 (normal)
	#lea	msg1, %bp
	mov     $cur, %bp
	mov		$0x1301, %ax		# write string, move cursor
	int		$0x10

	mov 	%ds:0,%ax
	call	print_hex
	call	print_nl

	mov 	$INITSEG,%ax
	mov		%ax,%ds
	mov 	$SETUPSEG, %ax
	mov		%ax,%es
	mov    	$0x03,%ah
	xor	   	%bh, %bh
	int  	$0x10
	mov  	$12,%cx
	mov		$0x0007, %bx		# page 0, attribute 7 (normal)
	#lea	msg1, %bp
	mov     $mem, %bp
	mov		$0x1301, %ax		# write string, move cursor
	int		$0x10

	mov 	%ds:2,%ax
	call	print_hex

	mov 	$INITSEG,%ax
	mov		%ax,%ds
	mov 	$SETUPSEG, %ax
	mov		%ax,%es
	mov    	$0x03,%ah
	xor	   	%bh, %bh
	int  	$0x10
	mov  	$2,%cx
	mov		$0x0007, %bx		# page 0, attribute 7 (normal)
	#lea	msg1, %bp
	mov     $kb, %bp
	mov		$0x1301, %ax		# write string, move cursor	
	int		$0x10

	call	print_nl

	mov 	$INITSEG,%ax
	mov		%ax,%ds
	mov 	$SETUPSEG, %ax
	mov		%ax,%es
	mov    	$0x03,%ah
	xor	   	%bh, %bh
	int  	$0x10
	mov  	$21,%cx
	mov		$0x0007, %bx		# page 0, attribute 7 (normal)
	#lea	msg1, %bp
	mov     $hd_info, %bp
	mov		$0x1301, %ax		# write string, move cursor
	int		$0x10

	mov 	%ds:128,%ax
	call	print_hex
	call	print_nl

	mov 	$INITSEG,%ax
	mov		%ax,%ds
	mov 	$SETUPSEG, %ax
	mov		%ax,%es
	mov    	$0x03,%ah
	xor	   	%bh, %bh
	int  	$0x10
	mov  	$8,%cx
	mov		$0x0007, %bx		# page 0, attribute 7 (normal)
	#lea	msg1, %bp
	mov     $hd_info1, %bp
	mov		$0x1301, %ax		# write string, move cursor
	int		$0x10

	mov 	%ds:130,%ax
	call	print_hex
	call	print_nl

	mov 	$INITSEG,%ax
	mov		%ax,%ds
	mov 	$SETUPSEG, %ax
	mov		%ax,%es
	mov    	$0x03,%ah
	xor	   	%bh, %bh
	int  	$0x10
	mov  	$8,%cx
	mov		$0x0007, %bx		# page 0, attribute 7 (normal)
	#lea	msg1, %bp
	mov     $hd_info2, %bp
	mov		$0x1301, %ax		# write string, move cursor
	int		$0x10

	mov 	%ds:142,%ax
	call	print_hex
	call	print_nl

inf_loop:
    jmp    inf_loop

print_hex:
    mov    $4,%cx         # 4个十六进制数字
    mov    %ax,%dx       # 将(bp)所指的值放入dx中，如果bp是指向栈顶的话
print_digit:
    rol    $4,%dx         # 循环以使低4比特用上 !! 取dx的高4比特移到低4比特处。
    mov    $0xe0f, %ax    # ah = 请求的功能值，al = 半字节(4个比特)掩码。
    and    %dl,%al         # 取dl的低4比特值。
    add    $0x30,%al      # 给al数字加上十六进制0x30
    cmp    $0x3a,%al
    jl     outp          #是一个不大于十的数字
    add    $0x07,%al      # 是a～f，要多加7
outp:
    int    $0x10
    loop   print_digit
    ret
print_nl:
    mov    $0xe0d,%ax   # CR
    int    $0x10
    mov    $0xa,%al     # LF
    int    $0x10
    ret


msg2:
	.byte 13,10
	.ascii "Now we are in SETUP..."
	.byte 13,10,13,10
cur:
        .ascii "Cursor POS:"

mem:
        .ascii "Memory Size:"
kb:
        .ascii "KB"
hd_info:
	.byte 13,10
	.ascii "HD Info"
	.byte 13,10
	.ascii "Cylinders:"
hd_info1:
    .ascii "Headers:"
hd_info2:
    .ascii "Secotrs:"
	.text
	endtext:
	.data
	enddata:
	.bss
	endbss:
