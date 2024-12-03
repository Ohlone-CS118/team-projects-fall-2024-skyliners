.text
.globl handle_weekend_energy
# preconditions: assumes that the $a, $t, $f registers have already been saved
# postcondition: the total energy emission for the weekday is stored in $f0
# Handle weekend energy input and calculations
handle_weekend_energy:
    	addiu $sp, $sp, -8       # Allocate stack space
    	sw $ra, 4($sp)           # Save return address
   	sw $t0, 0($sp)           # Save temporary register $t0
   	
weekend_energy_main:
   	li $v0, 4				# Print the main question question
    	la $a0, weekend_energy_main_question
    	syscall

    	li $v0, 5				# Get the user input
    	syscall
    	
    	beq $v0, 1, calculate_TV		# If the user chose to watch TV then jump to calculate_TV
	beq $v0, 2, calculate_Gaming		# If the user chose to play games then jump to calculate_gaming
	beq $v0, 3, calculate_Baking		# If the user chose to bake then jump to calculate_baking
	
calculate_TV:
	li $v0, 4				# Print the hours used question
    	la $a0, weekend_energy_hours_question
    	syscall
    	
    	li $v0, 5				# Get the user input
    	syscall
    	
    	bltz $v0, weekend_energy_invalid_hours		# Make sure the hours entered is vaild
    	bgt $v0, 24, weekend_energy_invalid_hours	# Make sure the hours entered is valid
    	
    	l.d $f2, ef_movie				# Load the emission factor for watching TV and convert the hours watched into double
    	mtc1 $v0, $f4
    	cvt.d.w $f4, $f4
    	mul.d $f4, $f4, $f2				# Emission = EF * hours 
   	j end_weekend_energy				# Go to the end of the function
    	
calculate_Gaming:
	li $v0, 4					# Print the hours used question
    	la $a0, weekend_energy_hours_question
    	syscall
    	
    	li $v0, 5					# Get the user input
    	syscall
    	
    	bltz $v0, weekend_energy_invalid_hours		# Make sure the hours entered is vaild
    	bgt $v0, 24, weekend_energy_invalid_hours	# Make sure the hours entered is vaild
    	
    	l.d $f2, ef_gaming				# Load the emission factor for playing on a gaming system and convert the hours played into a double
    	mtc1 $v0, $f4
    	cvt.d.w $f4, $f4
    	mul.d $f4, $f4, $f2				# Emission = EF * hours
   	j end_weekend_energy   				# Go to the end of the function
    	 				
calculate_Baking:
	li $v0, 4					# Print the minutes used question
    	la $a0, weekend_energy_baking_minutes
    	syscall
    	
    	li $v0, 5					# Get the user input
    	syscall
    	
    	bltz $v0, weekend_energy_invalid_minutes	# Make sure the minutes entered is vaild

	l.d $f2, ef_baking				# Load the emission factor for baking and convert the minutes into a double
	mtc1 $v0, $f4
    	cvt.d.w $f4, $f4
    	mul.d $f4, $f4, $f2				# Emission = EF * minutes
   	j end_weekend_energy				# Jump to the end of the function
   	
weekend_energy_invalid_hours: 
 	li $v0, 4					# Print the invalid hours string
    	la $a0, weekend_energy_invalid_hours_msg
    	syscall
    	
    	j weekend_energy_main				# Jump to ask the question again
    	
weekend_energy_invalid_minutes:  	
   	li $v0, 4					# Print the invalid minutes string
    	la $a0, weekend_enegry_invalid_minutes_msg
    	syscall
    	
   	j weekend_energy_main				# Jump to ask the question again
   	
end_weekend_energy:
	
   	# Multiply by 2 for weekday total
    	li $t3, 2
    	mtc1 $t3, $f6
    	cvt.d.w $f6, $f6
    	mul.d $f0, $f6, $f4       # Weekly energy emissions
   	
   	
   	
   	# Cleanup
    	lw $ra, 4($sp)              # Restore return address
    	lw $t0, 0($sp)              # Restore $t0
    	addiu $sp, $sp, 8           # Deallocate stack space
    	jr $ra                      # Return to main
 