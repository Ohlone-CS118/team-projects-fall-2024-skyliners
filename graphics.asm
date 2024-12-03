.globl drawBar
.globl backgroundColor
.globl draw_pixel
.globl normalize_emission


	
	
 .text



# draws the background color
# precondition: $a0 is set the color
backgroundColor:
	
	la $s1, DISPLAY		# The first pixel on the display
	lw $s1, 0($s1)
		# set s2 = the last memory address of the display
	la $s2, WIDTH
	lw $s2, 0($s2)
	la $s3, HEIGHT
	lw $s3, 0($s3)
	mul $s2, $s2, $s3
	mul $s2, $s2, 4		# word
	add $s2, $s1, $s2

backgroundLoop:
	sw $a0, 0($s1)
	addiu $s1, $s1, 4
	ble $s1, $s2, backgroundLoop
	
	jr $ra



# draws pixels
# preconditions
#	$a0 = x
#	$a1 = y
#	$a2 = color

draw_pixel:
	
	addi $sp, $sp, -8		# make room on the stack for 2 words ($ra, $fp)
	sw $fp, 4($sp)
	addi $fp, $sp, 4	# move the $fp to the boginning of this stack frame
	sw $ra, -4($fp)

	la $s2, DISPLAY
	lw $s2, 0($s2)
	
	la $s1, WIDTH
	lw $s1, 0($s1)

	# $s1 = address = DISPLAY + 4 * (x + (y * WIDTH))
	mul $s1, $a1, $s1	# s1 = (y * WIDTH)
	add $s1, $s1, $a0	# (x + s1)
	mul $s1, $s1, 4		# word (4 bytes)
	sw $a2, 0x10000000($s1)
	

	lw $ra, -4($fp)
	lw $fp, 0($fp)
	addi $sp, $sp, 8		# pop off the stack

	jr $ra
	




# draws vertical bars
# preconditions
#	$a0 = x (starting)
#	$a1 = x (ending)
#	$a2 = height
#	$a3 = color
drawBar:
	addi $sp, $sp, -8		# make room on the stack for 2 words ($ra, $fp)
	sw $fp, 4($sp)		# store frame pointer
	addi $fp, $sp, 4	# move the $fp to the beginning of this stack frame
	sw $ra, -4($fp)		# store return address

	li $s0, 65		# set y offset to bottom
	move $s3, $a0		# The starting x position
	move $s4, $a1		# The ending x position
	sub $s5, $s0, $a2	# set s5 to height of bar
	move $s6, $s3		# set s6 to reset s3 position

	move $a2, $a3		# set color

barLoopHorizontal:
	bgt $s3, $s4, barLoop	# if s3 > s4
	move $a0, $s3		# set x offset from s3
	move $a1, $s0		# set y offset from s4
	jal draw_pixel		# draw pixel
	
	addi $s3, $s3, 1	# move x one unit over
	j barLoopHorizontal

barLoop:
	blt $s0, $s5, barExit	# if s0 < s5
	move $s3, $s6		# The starting x position
	subi $s0, $s0, 1	# move y one position up
	j barLoopHorizontal
barExit:	
	lw $ra, -4($fp)			# restore return address
	lw $fp, 0($fp)			# restore frame pointer
	addi $sp, $sp, 8		# pop off the stack
	
	jr $ra





# Normalize emissions to a height in the range 0-64
# Preconditions:
#   $f0 = emission value (in kg CO₂)
# Postconditions:
#   $v0 = normalized height (integer 0-64)
normalize_emission:
	addi $sp, $sp, -8		# make room on the stack for 2 words ($ra, $fp)
	sw $fp, 4($sp)		# store frame pointer
	addi $fp, $sp, 4	# move the $fp to the beginning of this stack frame
	sw $ra, -4($fp)		# store return address



    li $s0, 300            # Assume max emission is 45 kg CO2
    mtc1 $s0, $f30          # Move 300 into $f30
    cvt.d.w $f30, $f30       # Convert 300 to double

    div.d $f28, $f0, $f30    # emission / 300 (normalize to 0-1)
    la $s1, HEIGHT
    lw $s1, 0($s1)             # Max height (64 pixels) 
    mtc1 $s1, $f30          # Move max height into $f30
    cvt.d.w $f30, $f30       # Convert 64 to double
    mul.d $f28, $f28, $f30    # emission_normalized * 64

    cvt.w.d $f28, $f28       # Convert result to integer
    mfc1 $v0, $f28          # Move result into $v0
    
    
    	lw $ra, -4($fp)			# restore return address
	lw $fp, 0($fp)			# restore frame pointer
	addi $sp, $sp, 8		# pop off the stack
    
    jr $ra
