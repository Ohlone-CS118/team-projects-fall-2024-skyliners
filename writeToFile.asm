.globl intToString   
intToString:   
  # $a0: integer to convert   
  # $a1: buffer address   
  addiu $sp, $sp, -8    # Allocate space on the stack   
  sw $ra, 4($sp)      # Save return address to main   
  sw $t0, 0($sp)      # Save temporary register $t0   
   
  move $s0, $a0    # move integer to s0   
  move $s1, $a1    # move buffer address to s1   
   
  # Clear the buffer  
  li $s3, 0      # counter  
  li $t0, 10      # buffer size (assuming it's 10)  
clearBufferLoop:  
  add $s4, $s1, $s3  # memory address of next char in buffer  
  sb $zero, 0($s4)  # set character to zero  
  addi $s3, $s3, 1  # counter++  
  blt $s3, $t0, clearBufferLoop  # repeat until buffer is cleared  
   
  li $s2, 10      # Base 10   
  add $s3, $zero, $s1  # Pointer to current position   
  li $s4, 0      # counter  
   
intToStrLoop:   
  div $s0, $s0, $s2   # Divide $t0 by 10   
  mfhi $s5       # Get remainder   
  addi $s5, $s5, 48   # Convert to ASCII ('0'-'9')   
  add $s6, $s3, $s4  # memory address of next char in buffer  
  sb $s5, 0($s6)    # Store character in buffer   
  addi $s4, $s4, 1    # Move pointer forward   
  mflo $s0       # Update $t0 with quotient   
  bnez $s0, intToStrLoop # Repeat until $t0 is 0   
   
  # Reverse the string in the buffer  
  move $s3, $s1    # start of string  
  li $s5, 0      # counter  
findEndLoop:  
  add $s6, $s3, $s5  # memory address of next char in string  
  lb $s7, 0($s6)    # load byte  
  addi $s5, $s5, 1  # counter++  
  bnez $s7, findEndLoop  # break condition  
  subi $s5, $s5, 2  # back up two chars (bytes)  
  add $s6, $s3, $s5  # memory address of last char in string  
  
reverseLoop:  
  lb $t7, 0($s3)    # load first byte  
lb $t8, 0($s6)    # load last byte  
sb $t8, 0($s3)    # store last byte at start  
sb $t7, 0($s6)    # store first byte at end
  
  sb $s7, 0($s6)    # store first byte at end  
  addi $s3, $s3, 1  # move start pointer forward  
  subi $s6, $s6, 1  # move end pointer backward  
  subi $s5, $s5, 1  # decrement counter  
  bgtz $s5, reverseLoop  # repeat until string is reversed  
  
  sb $zero, 0($s6)    # Null-terminate the string   
   
  la $t0, pastUser   # Set the file path to the pastUser text file   
  move $t1, $s1    # what's going in the file   
  jal writeToFile   
   
  lw $ra, 4($sp)      # Restore return address   
  lw $t0, 0($sp)      # Restore $t0   
  addiu $sp, $sp, 8    # Deallocate stack space   
  jr $ra         # Returning control to main


writeToFile:  
  # $t0: file path  
  # $t1: buffer address  
  addiu $sp, $sp, -8    # Allocate space on the stack  
  sw $ra, 4($sp)      # Save return address to main  
  sw $t2, 0($sp)      # Save temporary register $t2  
  
  move $s0, $t0    # store file path  
  move $s1, $t1    # store buffer  
  
  li $s3, 0    # set counter to 0  
counterLoop:  
  add $s4, $s1, $s3  # memory address of next char in string  
  lb $s5, 0($s4)  # load byte  
  addi $s3, $s3, 1  # counter++  
  bnez $s5, counterLoop  # break condition  
  
  subi $s3, $s3, 1  # back up one char (byte)  
  
  li $v0, 13    # load file  
  move $a0, $s0  
  li $a1, 1    # write  
  li $a2, 0    # dunno  
  syscall  
  
  move $s2, $v0    # stash file handler  
  
  li $v0, 15    # write to file  
  move $a0, $s2    # set the file handler  
  move $a1, $s1    # address if buffer  
  move $a2, $s3    # number of char to write  
  syscall  
  
  li $v0, 16    # close file  
  syscall  
  
  lw $ra, 4($sp)      # Restore return address  
  lw $t2, 0($sp)      # Restore $t2  
  addiu $sp, $sp, 8    # Deallocate stack space  
  jr $ra         # Returning control to intToString
