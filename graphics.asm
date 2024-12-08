# Contributors: Paul Raupach (backgroundColor, draw_pixel), Andy. 12/02/2024(wrote the functions) - 12/03/2024(added more functions for weekend and total)
# Purpose: These functions handle the display in the code.

.globl drawBar
.globl backgroundColor
.globl draw_pixel
.globl normalize_emission_weekday
.globl normalize_emission_weekend
.globl normalize_emission_total

	
	
 .text



# draws the background color for the display
# precondition: $a0 is set the color
backgroundColor:
	
	# Load the address of the display to start drawing
	la $s1, DISPLAY		# load address of the first pixel on the display
	lw $s1, 0($s1)		# load actual value of first pixel
	
	# This code sets up the endpoint to stop drawing for the background
	# set s2 = the last memory address of the display
	la $s2, WIDTH		# load address of width label
	lw $s2, 0($s2)		# load value of width
	la $s3, HEIGHT		# load address of height
	lw $s3, 0($s3)		# load value of height
	mul $s2, $s2, $s3	# multiply width by height and store in $s2
	mul $s2, $s2, 4		# multiply by 4 for a word to store color values
	add $s2, $s1, $s2	# add to base address to find ending address

backgroundLoop:
	# draws the color until all the display is filled
	sw $a0, 0($s1)
	addiu $s1, $s1, 4 # move to the next pixel
	ble $s1, $s2, backgroundLoop
	
	jr $ra #return



# draws pixels
# preconditions
#	$a0 = x
#	$a1 = y
#	$a2 = color

draw_pixel:

	# set up stack
	addi $sp, $sp, -8		# make room on the stack for 2 words ($ra, $fp)
	sw $fp, 4($sp)		# store $fp on the stack
	addi $fp, $sp, 4	# move the $fp to the beginning of this stack frame
	sw $ra, -4($fp)		# store return address

	# load display address properties
	la $s2, DISPLAY		# load address of display label
	lw $s2, 0($s2)		# load starting address of display in s2
	
	la $s1, WIDTH		# load address of width label
	lw $s1, 0($s1)		# load width of display in s1

	# set up y-offset
	# $s1 = address = DISPLAY + 4 * (x + (y * WIDTH))
	mul $s1, $a1, $s1	# s1 = (y * WIDTH)
	add $s1, $s1, $a0	# (x + s1)
	mul $s1, $s1, 4		# word (4 bytes)
	
	# draw a pixel
	sw $a2, 0x10000000($s1)	# put a pixel into the display
	
	# restore stack
	lw $ra, -4($fp)			# restore return address
	lw $fp, 0($fp)			# restore frame pointer
	addi $sp, $sp, 8		# pop off the stack

	jr $ra
	



# Purpose: Visualizes the user's emissions as bar graphs on the display.
# draws vertical bars
# preconditions
#	$a0 = x (starting)
#	$a1 = x (ending)
#	$a2 = height
#	$a3 = color
drawBar:
	# set up stack
	addi $sp, $sp, -8		# make room on the stack for 2 words ($ra, $fp)
	sw $fp, 4($sp)		# store frame pointer
	addi $fp, $sp, 4	# move the $fp to the beginning of this stack frame
	sw $ra, -4($fp)		# store return address

	# set up bar properties
	li $s0, 65		# set y offset to bottom
	move $s3, $a0		# The starting x position
	move $s4, $a1		# The ending x position
	sub $s5, $s0, $a2	# set s5 to height of bar
	move $s6, $s3		# set s6 to reset s3 position
	move $a2, $a3		# set color

# draws a row of pixels
barLoopHorizontal:
	# draw one pixel
	bgt $s3, $s4, barLoop	# if s3 > s4
	move $a0, $s3		# set x offset from s3
	move $a1, $s0		# set y offset from s4
	jal draw_pixel		# draw pixel

	addi $s3, $s3, 1	# move x one unit over
	j barLoopHorizontal

# resets x position and moves one y position up to draw next row of pixelx
barLoop:
	blt $s0, $s5, barExit	# if s0 < s5
	move $s3, $s6		# The starting x position
	subi $s0, $s0, 1	# move y one position up
	j barLoopHorizontal

	# when the bar is filled
barExit:
	# restore stack
	lw $ra, -4($fp)			# restore return address
	lw $fp, 0($fp)			# restore frame pointer
	addi $sp, $sp, 8		# pop off the stack
	
	jr $ra





# Purpose: Normalizes weekday emissions to a height in the range 0-64 for the display.
# Preconditions:
#   $f0 = emission value (in kg CO2)
# Postconditions:
#   $v0 = normalized height (integer 0-64)
normalize_emission_weekday:
	# set up stack
	addi $sp, $sp, -8		# make room on the stack for 2 words ($ra, $fp)
	sw $fp, 4($sp)		# store frame pointer
	addi $fp, $sp, 4	# move the $fp to the beginning of this stack frame
	sw $ra, -4($fp)		# store return address

	# load max value for the bar
	la $s2, MAX_NORMALIZED_HEIGHT # load max normalized value for height (1)
	l.d $f26, 0($s2)	# load 1 as max value into $f26

    li $s0, 250            # Assume max emission is 250 kg CO2
    mtc1 $s0, $f30          # Move 250 into $f30
    cvt.d.w $f30, $f30       # Convert 250 to double

	# convert the emission into a normalized height for the bar graph (error checking if normalized value > 1)
    div.d $f28, $f0, $f30    # emission / 250 (normalize to 0-1)
    c.lt.d $f26, $f28	# if normalized value > 1
    bc1t normalize_emission_weekday_overflow # branch if true
    
normalize_emission_weekday_resume: 
	# Multiply normalized height by 64 for the display. 
    la $s1, HEIGHT
    lw $s1, 0($s1)             # Max height (64 pixels) 
    mtc1 $s1, $f30          # Move max height into $f30
    cvt.d.w $f30, $f30       # Convert 64 to double
    mul.d $f28, $f28, $f30    # emission_normalized * 64

	# Since the display is an integer type, we convert the normalized value back into an integer
    cvt.w.d $f28, $f28       # Convert result to integer
    mfc1 $v0, $f28          # Move result into $v0

    
    # restore stack
    	lw $ra, -4($fp)			# restore return address
	lw $fp, 0($fp)			# restore frame pointer
	addi $sp, $sp, 8		# pop off the stack
    
    jr $ra

        # Checks if the bar overflows.
normalize_emission_weekday_overflow:
	mov.d $f28, $f26 # set the value 1 in f28
	j normalize_emission_weekday_resume
	
	



# Purpose: Normalizes weekend emissions to a height in the range 0-64 for the display.
# Preconditions:
#   $f0 = emission value (in kg CO2)
# Postconditions:
#   $v0 = normalized height (integer 0-64)
normalize_emission_weekend:
	# set up stack
	addi $sp, $sp, -8		# make room on the stack for 2 words ($ra, $fp)
	sw $fp, 4($sp)		# store frame pointer
	addi $fp, $sp, 4	# move the $fp to the beginning of this stack frame
	sw $ra, -4($fp)		# store return address

	# load max value for the bar
	la $s2, MAX_NORMALIZED_HEIGHT # load max normalized value for height (1)
	l.d $f26, 0($s2)	# load 1 as max value into $f26

    li $s0, 100            # Assume max emission is 100 kg CO2
    mtc1 $s0, $f30          # Move 100 into $f30
    cvt.d.w $f30, $f30       # Convert 100 to double

	# convert the emission into a normalized height for the bar graph (error checking if normalized value > 1)
    div.d $f28, $f0, $f30    # emission / 100 (normalize to 0-1)
    c.lt.d $f26, $f28	# if normalized value > 1
    bc1t normalize_emission_weekend_overflow # branch if true
    
normalize_emission_weekend_resume:    
	# Multiply normalized height by 64 for the display.     
    la $s1, HEIGHT
    lw $s1, 0($s1)             # Max height (64 pixels) 
    mtc1 $s1, $f30          # Move max height into $f30
    cvt.d.w $f30, $f30       # Convert 64 to double
    mul.d $f28, $f28, $f30    # emission_normalized * 64

	# Since the display is an integer type, we convert the normalized value back into an integer
    cvt.w.d $f28, $f28       # Convert result to integer
    mfc1 $v0, $f28          # Move result into $v0

    
    	# Restore stack
    	lw $ra, -4($fp)			# restore return address
	lw $fp, 0($fp)			# restore frame pointer
	addi $sp, $sp, 8		# pop off the stack
    
    jr $ra

    # Checks if the bar overflows.
normalize_emission_weekend_overflow:
	mov.d $f28, $f26 # set the value 1 in f28
	j normalize_emission_weekend_resume







# Purpose: Normalize total emissions to a height in the range 0-64 for the display.
# Preconditions:
#   $f0 = emission value (in kg CO2)
# Postconditions:
#   $v0 = normalized height (integer 0-64)
normalize_emission_total:
	# set up stack
	addi $sp, $sp, -8		# make room on the stack for 2 words ($ra, $fp)
	sw $fp, 4($sp)		# store frame pointer
	addi $fp, $sp, 4	# move the $fp to the beginning of this stack frame
	sw $ra, -4($fp)		# store return address

	# load max value for the bar
	la $s2, MAX_NORMALIZED_HEIGHT # load max normalized value for height (1)
	l.d $f26, 0($s2)	# load 1 as max value into $f26

    li $s0, 32000            # Assume max emission is 32000 kg CO2
    mtc1 $s0, $f30          # Move 32000 into $f30
    cvt.d.w $f30, $f30       # Convert 32000 to double

	# convert the emission into a normalized height for the bar graph (error checking if normalized value > 1)
    div.d $f28, $f0, $f30    # emission / 32000 (normalize to 0-1)
    c.lt.d $f26, $f28	# if normalized value > 1
    bc1t normalize_emission_total_overflow # branch if true
    
normalize_emission_total_resume:
	# Multiply normalized height by 64 for the display. 
    la $s1, HEIGHT
    lw $s1, 0($s1)             # Max height (64 pixels) 
    mtc1 $s1, $f30          # Move max height into $f30
    cvt.d.w $f30, $f30       # Convert 64 to double
    mul.d $f28, $f28, $f30    # emission_normalized * 64

	# Since the display is an integer type, we convert the normalized value back into an integer
    cvt.w.d $f28, $f28       # Convert result to integer
    mfc1 $v0, $f28          # Move result into $v0

    
    	# restore stack
    	lw $ra, -4($fp)			# restore return address
	lw $fp, 0($fp)			# restore frame pointer
	addi $sp, $sp, 8		# pop off the stack
    
    jr $ra

        # Checks if the bar overflows.
normalize_emission_total_overflow:
	mov.d $f28, $f26 # set the value 1 in f28
	j normalize_emission_total_resume

