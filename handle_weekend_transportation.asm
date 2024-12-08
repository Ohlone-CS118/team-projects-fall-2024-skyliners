.text
.globl handle_weekend_transportation
# preconditions: assumes that the $a and $f registers have already been saved
# postcondition: the total transportation emission for the weekday is stored in $f0
# Contributors: Ni Linn(Wrote the weekday transport subroutine) and Emma(Since all calculations are the same as weekday transport, changed the labels to fit weekend). 
# 12/02/2024(wrote the subroutine) - 12/04/2024(error checking)
# Purpose: Gives prompts and calculates the carbon emission of the weekend transportation questions
handle_weekend_transportation:
	addiu $sp, $sp, -8     	# Allocate stack space  
	sw $ra, 4($sp)        	# Save return address  
	sw $fp, 0($sp)        	# stash the frame pointer  
	addi $fp, $sp, 4      	# set the frame pointer the beginning of the stack
	
ask_weekend_transportation_main_question:
	# Asks the main question of the weekend transport section. All other questions will come from this question
    	li $v0, 4
    	la $a0, weekend_transportation_main_question
    	syscall

    	li $v0, 5
    	syscall
    	move $s1, $v0		# Store the transport method. We need to do this because bus/public transit, personal car, and carpool all go to weekend_ask_miles and then to their own labels.
    				# They also go to calculate_weekend_motorized_emissions and their own labels again
    				
    	# Goes to the appropriate label based on user choice
	beq $s1, 1, no_emission    	 # If walk
	beq $s1, 2, no_emission    	 # If bike
    	beq $s1, 3, weekend_ask_miles    # If Bus/Public Transit
    	beq $s1, 4, weekend_ask_miles    # If Personal Car
    	beq $s1, 5, weekend_ask_miles    # If Carpool
    
	# If user inputs something other than one of the choices it says that the choice is invaild and jumps back to the question(error checking).
	li $v0, 4
    	la $a0, invalid_user_input
    	syscall
    	
    	j ask_weekend_transportation_main_question
 
no_emission: 
	# User choice walk and bike both go this label since they don't produce any emissions(not taking into account from being made in the bike's case)
   	l.d $f0, zero_value      # Non-motorized emissions (default to 0)
   	j end_weekend_transportation
   	
weekend_ask_miles: 
	# Asks for the miles in a day for user choice bus/public transit, person car, and carpool.
	li $v0, 4
    	la $a0, weekend_miles_question
    	syscall
	
	# Gets the user input for miles as a double
    	li $v0, 7
    	syscall
    	mov.d $f2, $f0           # Save miles in $f2. Needed for the emission calculation
    	
    	# Checks to make sure that the user did a valid input and jumps to the weekend_miles_invalid if they didn't.
    	l.d $f0, zero_value      # load zero value
	c.lt.d $f2, $f0	# check if miles < 0
	bc1t weekend_miles_invalid

    	beq $s1, 5, weekend_ask_carpool  # If carpool
    	jal calculate_weekend_motorized_emissions  # Otherwise, calculate emissions
    	j end_weekend_transportation

weekend_miles_invalid:
	# Tells the user that their input was invalid and jumps to ask the question again.
	li $v0, 4
    	la $a0, invalid_user_input   # Display invalid input message
    	syscall
    	j weekend_ask_miles

weekend_ask_carpool:
	# If the user chose carpool we need to know how many people so we can divide by that number
 	li $v0, 4
    	la $a0, weekend_carpool_question
    	syscall

	# Gets the carpool number as an integer for easier branching
    	li $v0, 5
    	syscall
    	move $s2, $v0            # Save carpool count
    	
    	# Checks to make sure that the user did a valid input and jumps to the weekend_carpool_invalid if they didn't.
    	blt $s2, 1, weekend_carpool_invalid	# check for invalid input

    	jal calculate_weekend_motorized_emissions	# Calculate the emission
    	j end_weekend_transportation
    	
weekend_carpool_invalid:
	# Tells the user that their input was invalid and jumps to ask the question again.
	li $v0, 4
    	la $a0, invalid_user_input   # Display invalid input message
    	syscall
    	j weekend_carpool_invalid

calculate_weekend_motorized_emissions:
    	addiu $sp, $sp, -8       # Allocate space for local variables
    	sw $s1, 0($sp)           # Save transport mode
    	sw $s2, 4($sp)           # Save carpool count (if applicable)

	# Gets the emission factor for the user's choice
    	beq $s1, 3, weekend_load_bus
    	beq $s1, 4, weekend_load_car
    	beq $s1, 5, weekend_load_carpool

weekend_load_bus:
    	l.d $f0, ef_bus          # Load bus emission factor for calculation
    	j process_weekend_emission

weekend_load_car:
    	l.d $f0, ef_car          # Load car emission factor for calculation
    	j process_weekend_emission

weekend_load_carpool:
    	l.d $f0, ef_carpool      # Load carpool emission factor
    	lw $s2, 4($sp)           # Retrieve carpool count
    	mtc1 $s2, $f4            # Move carpool count to FP register
    	cvt.d.w $f4, $f4         # Convert carpool count to double
    	div.d $f0, $f0, $f4      # Adjust emission factor for carpool
    	j process_weekend_emission

process_weekend_emission:
    	mul.d $f0, $f0, $f2      # Daily emissions = factor * miles
    	li $s3, 2                # Weekend multiplier
    	mtc1 $s3, $f4            # Move multiplier to FP register
    	cvt.d.w $f4, $f4         # Convert to double
    	mul.d $f0, $f0, $f4      # Weekly emissions = daily emissions * 2

    	lw $s1, 0($sp)           # Restore transport mode
    	lw $s2, 4($sp)           # Restore carpool count
    	addiu $sp, $sp, 8        # Deallocate local variables
    	jr $ra                   # Returning control to handle_weekday_transportation

end_weekend_transportation:

	# Prints the weekend energy emission results
	li $v0, 4
    	la $a0, weekend_transportation_result
    	syscall

    	li $v0, 3
    	mov.d $f12, $f0          # Load emissions for printing
    	syscall

	# Cleanup
    	lw $fp, 0($sp)        	# Restore frame pointer  
	lw $ra, 4($sp)        	# Restore return address  
	addiu $sp, $sp, 8      	# Deallocate stack space  
	jr $ra             	# Return to caller
