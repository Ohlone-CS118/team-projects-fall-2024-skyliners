# this file is the function that grabs the info from the text files
.text
.globl readFromFile
# preconditions:
# 	$a0=file path
#	$a1=buffer
# postcondition: 
#	the buffer address holds the file .text
# Contributors: Paul Raupach
# Purpose: Reads from a file and puts in buffer
readFromFile:
	addiu $sp, $sp, -8       # Allocate space on the stack
    	sw $ra, 4($sp)           # Save return address to main
    	sw $t0, 0($sp)           # Save temporary register $t0
	
	move $s0, $a0		# store file path
	move $s1, $a1		# store buffer
	
	li $v0, 13		# open the file
	move $a0, $s0		# set the file path
	li $a1, 0		# read?
	li $a2, 0
	syscall
	
	move $s3, $v0		# save file handler
	
	li $v0, 14		# read the file
	move $a0, $s3		# set file handler
	move $a1, $s1		# set the buffer
	li $a2, 1024		# set max length and leave space for null
	syscall
	
	move $s4, $v0		# save the number of char read
	
	add $s5, $s4, $s1
	sb $zero, 0($s5)	# insert the terminating null char (\0)
	
	li $v0, 16		# close file
	move $a0, $s3		# set file handler
	syscall
	
	lw $ra, 4($sp)           # Restore return address
    	lw $t0, 0($sp)           # Restore $t0
    	addiu $sp, $sp, 8        # Deallocate stack space
    	jr $ra                   # Returning control to main