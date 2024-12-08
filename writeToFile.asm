.text
.globl writeToFile
# precondition: 
#	$a0=file path
# 	$a1=buffer
# postcondition:
#	string in buffer written to path
writeToFile:

	move $s0, $a0		# store file path
	move $s1, $a1		# store buffer
	
	li $s3, 0		# set counter to 0
counterLoop:
	add $s4, $s1, $s3	# memory address of next char in string
	lb $s5, 0($s4)		# load byte
	addi $s3, $s3, 1	# counter++
	bnez $s5, counterLoop	# break condition
	
	subi $s3, $s3, 1	# back up one char (byte)
	
	li $v0, 13		# load file
	move $a0, $s0
	li $a1, 1		# write
	li $a2, 0		# dunno
	syscall
	
	move $s2, $v0		# stash file handler
	
	li $v0, 15		# write to file
	move $a0, $s2		# set the file handler
	move $a1, $s1		# address if buffer
	move $a2, $s3		# number of char to write
	syscall
	
	li $v0, 16		# close file
	syscall
	
	jr $ra
	
