
.text
.globl msgs
# Preconditions: assumes that $a0 and $a1 have already been saved
# Contributors: Emma. 12/03/2024
# Purpose: Calculates a comparison of user carbom emission vs the U.S. average and displays the appropriate message
msgs:
	addiu $sp, $sp, -8      # Allocate space on the stack
    	sw $ra, 4($sp)          # Save return address to main
    	sw $t0, 0($sp)          # Save temporary register $t0
    	
	l.d $f16, US_average	# Load the U.S. average emission
	l.d $f14, half_average	# Load half the U.S. average emission


# Check if the projection is less than half of the average 
	c.lt.d $f18, $f14  
	bc1t less_than_half
  
 # Check if the projection is more than average 
	c.lt.d $f16, $f18  
	bc1t more_than  
  
# If none of the conditions are true, then the projections is less than or equal to average or greater than or equal to half of the average  
	j between_half_and_equal  
  
less_than_half:  
# If projection is less than half of average
   	li $v0, 11		# Newline to seperate the msg from the rest of the results
	la $a0, 10
	syscall
	
   	li $v0, 4
        la $a0, less_half_msg	# load less_half_msg string
        syscall
         
        jal celebratory		# Go to celebratory subroutine for sound
         
   	j exit  
  
between_half_and_equal:  
# Check if projection is equal to average  
   	c.eq.d $f18, $f16  
   	bc1t equal  
  	
# Check if the projection is exactly half of the average
  	c.eq.d $f18, $f14  
   	bc1t equal_half
  
# Code to handle the case where $f18 is less than $f16 but greater than half of $f16  
   	li $v0, 11		# Newline to seperate the msg from the rest of the results
	la $a0, 10
	syscall
   	
   	li $v0, 4
        la $a0, half_and_equal_msg	# load half_and_equal_msg string
        syscall
        
        jal less_celebratory 		# Go to less_celebratory subroutine for sound
        
   	j exit  
   	
equal_half:
	li $v0, 11		# Newline to seperate the msg from the rest of the results
	la $a0, 10
	syscall

  	li $v0, 4
        la $a0, equal_half_msg	# load equal_half_msg string
        syscall
        
        jal less_celebratory 		# Go to less_celebratory subroutine for sound
        
   	j exit  
  
equal:  
# If $f18 is equal to $f16
   	li $v0, 11		# Newline to seperate the msg from the rest of the results
	la $a0, 10
	syscall
	
   	li $v0, 4
        la $a0, equal_msg	# load equal_msg string
        syscall
        
	jal bad			# Go to bad subroutine for sound
        
   	j exit  
  
more_than:  
# If $f18 is more than $f16
   	li $v0, 11		# Newline to seperate the msg from the rest of the results
	la $a0, 10
	syscall
	
   	li $v0, 4
        la $a0, more_than_msg	# load more_than_msg string
        syscall  
        
	jal bad			# Go to bad subroutine for sound
exit:
 	lw $ra, 4($sp)           # Restore return address
    	lw $t0, 0($sp)           # Restore $t0
    	addiu $sp, $sp, 8        # Deallocate stack space
   	jr $ra          	 # Return to main

# Celebratory sound
# $a0 and $v0 should be available   
# Contributors: Emma(wrote code but used wrong registers) and Andy(fixed the registers). 12/04/2024
# 12/08/2024 - Changed sound by Andy.
# Purpose: To output a sound based on the calculated comparison from the msgs subroutine.
celebratory:  
	addiu $sp, $sp, -8       # Allocate space on the stack
    	sw $ra, 4($sp)           # Save return address to main
    	sw $t0, 0($sp)           # Save temporary register $t0
    	
	li $a2, 0     # Load piano  
      	li $v0, 33  
      	 
	
      	li $a0, 72    # C5  
	li $a1, 125    # 125 milliseconds  
      	syscall  

      	li $a0, 72    # C5    
      	li $a1, 125    # 125 milliseconds  
      	syscall  
  
      	li $a0, 72    # C5  
      	li $a1, 125    # 125 milliseconds  
      	syscall  

      	li $a0, 72    # C5  
      	li $a1, 250    # 250 milliseconds  
      	syscall  

	li $v0, 32	
	li $a0, 250	# rest for 250 milliseconds
	syscall


	li $v0, 33
      	li $a0, 68    # G♯4  
      	li $a1, 250    # 250 milliseconds  
      	syscall  

	li $v0, 32	
	li $a0, 250	# rest for 250 milliseconds
	syscall
	
	li $v0, 33
      	li $a0, 70    # A♯4  
      	li $a1, 250    # 250 milliseconds  
      	syscall  

	li $v0, 32	
	li $a0, 250	# rest for 250 milliseconds
	syscall

	li $v0, 33
      	li $a0, 72    # C5  
      	li $a1, 250    # 250 milliseconds  
      	syscall  
      	
      	li $v0, 32	
	li $a0, 50	# rest for 50 milliseconds
	syscall


	li $v0, 33
      	li $a0, 70    # A♯4  
      	li $a1, 125    # 125 milliseconds  
      	syscall  


      	li $a0, 72    # C5  
      	li $a1, 1000    # 1 second  
      	syscall  




       	lw $ra, 4($sp)           # Restore return address
    	lw $t0, 0($sp)           # Restore $t0
    	addiu $sp, $sp, 8        # Deallocate stack space
    	jr $ra                   # Return to msgs
  
# Less celebratory sound  
# $a0 and $v0 should be available
# Contributors: Emma(wrote code but used wrong registers) and Andy(fixed the registers). 12/04/2024
# 12/08/2024 - Changed sound by Andy.
# Purpose: To output a sound based on the calculated comparison from the msgs subroutine.
less_celebratory: 
	addiu $sp, $sp, -8       # Allocate space on the stack
    	sw $ra, 4($sp)           # Save return address to main
    	sw $t0, 0($sp)           # Save temporary register $t0
	
	

      	
      	li $a2, 0     # Load piano  
      	li $v0, 33  
      	 
	
      	li $a0, 72    # C5  
	li $a1, 250    # 250 milliseconds  
      	syscall  

      	li $a0, 72    # C5    
      	li $a1, 1000    # 1 second  
      	syscall  
      	 
      	lw $ra, 4($sp)           # Restore return address
    	lw $t0, 0($sp)           # Restore $t0
    	addiu $sp, $sp, 8        # Deallocate stack space
    	jr $ra                   # Return to msgs
  
# Bad sound 
# $a0 and $v0 should be available 
# Contributors: Emma(wrote code but used wrong registers) and Andy(fixed the registers). 12/04/2024
# 12/08/2024 - Changed sound by Andy.
# Purpose: To output a sound based on the calculated comparison from the msgs subroutine.
bad:  
	addiu $sp, $sp, -8       # Allocate space on the stack
    	sw $ra, 4($sp)           # Save return address to main
    	sw $t0, 0($sp)           # Save temporary register $t0
     
	li $a2, 0     # Load piano  
      	li $v0, 33  
      	 
	
      	li $a0, 72    # C5  
	li $a1, 500    # 500 milliseconds  
      	syscall  

      	li $a0, 69    # A4    
      	li $a1, 500    # 500 milliseconds  
      	syscall  
      	
      	      	
      	li $a0, 72    # C5  
	li $a1, 500    # 500 milliseconds  
      	syscall  

      	li $a0, 69    # A4    
      	li $a1, 500    # 500 milliseconds  
      	syscall  
      	 
      	li $a0, 72    # C5  
	li $a1, 500    # 500 milliseconds  
      	syscall  

      	li $a0, 69    # A4    
      	li $a1, 500    # 500 milliseconds  
      	syscall  
      	
      	      	
      	li $a0, 72    # C5  
	li $a1, 500    # 500 milliseconds  
      	syscall  

      	li $a0, 69    # A4    
      	li $a1, 500    # 500 milliseconds  
      	syscall  
      	 
      	 
      	lw $ra, 4($sp)           # Restore return address
    	lw $t0, 0($sp)           # Restore $t0
    	addiu $sp, $sp, 8        # Deallocate stack space
    	jr $ra                   # Return to msgs
  
