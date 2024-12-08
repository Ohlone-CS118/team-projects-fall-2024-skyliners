# Weekday Transportation Calulations
# This module calculates the weekday transportation emissions 

.text
.globl handle_weekday_transportation

# preconditions: assumes that the $a and $f registers have already been saved
# postcondition: the total transportation emission for the weekday is stored in $f0
# Contributors: Ni Linn(Wrote subroutine) and Andy(error checking). 12/03/2024(wrote the subroutine) - 12/04/2024(error checking)
# Purpose: Calculates the carbon emission of the weekday transportation questions
handle_weekday_transportation:
    # Set up stack
    addiu $sp, $sp, -8     	# Allocate stack space  
    sw $ra, 4($sp)        	# Save return address  
    sw $fp, 0($sp)        	# stash the frame pointer  
    addi $fp, $sp, 4      	# set the frame pointer the beginning of the stack

ask_main_question:
    # Asks the user the main weekday transportation question.
    li $v0, 4
    la $a0, main_question
    syscall
 
    # Gets the user input as an integer so that the branching is easier 
    li $v0, 5
    syscall
    move $s0, $v0            # Save main choice (school/work/both)

	# Checks if the user inputted a valid input(less than 1 and greater than 3) and if they do, jump to the main_question_invalid label(error checking).
	blt $s0, 1, main_question_invalid	# check for invalid input
	bgt $s0, 3, main_question_invalid

ask_transport:
    # Asks the user the modeof transport question to use in the calculations.
    li $v0, 4
    la $a0, transport_question
    syscall
    
    # Gets the user input as an integer so that the branching is easier 
    li $v0, 5
    syscall
    move $s1, $v0            # Save transport mode
    
    	# Checks if the user inputted a valid input(less than 1 and greater than 5) and if they do, jump to the main_question_invalid label(error checking).
    	blt $s1, 1, transport_invalid	# check for invalid input
	bgt $s1, 5, transport_invalid
	
    # Goes to ask the miles if the user chose bus/public transit, personal car, or carpool
    beq $s1, 3, ask_miles    # If Bus/Public Transit
    beq $s1, 4, ask_miles    # If Personal Car
    beq $s1, 5, ask_miles    # If Carpool

    # If the code doesn't branch and the input is valid, then the user chose walking or biking and the emission is zero.
    l.d $f0, zero_value      # Non-motorized emissions (default to 0)
    j cleanup_weekday_transportation

ask_miles:
    # Asks the user how many miles in a day they go in their mode of transportation(asks for bus/public transit, personal car, and carpool)
    li $v0, 4
    la $a0, miles_question
    syscall

    # Gets the user miles input as a double for calculation
    li $v0, 7
    syscall
    mov.d $f2, $f0           # Save miles in $f2
    
    # Checks if the user put in a valid input(greater than 0) and if they didn't, jumps to the miles_invalid label.
    l.d $f0, zero_value      # load zero value
	c.lt.d $f2, $f0	# check if miles < 0
	bc1t miles_invalid

    # If the user said that they carpool
    beq $s1, 5, ask_carpool  # If carpool
    jal calculate_motorized_emissions  # Otherwise, calculate emissions
    j cleanup_weekday_transportation

ask_carpool:
    # If the user chose carpool we need to know how many people so we can divide by that number
    li $v0, 4
    la $a0, carpool_question
    syscall

    # Gets the carpool number as an integer for easier branching
    li $v0, 5
    syscall
    move $s2, $v0            # Save carpool count
        # Checks to make sure that the user did a valid input and jumps to the carpool_invalid if they didn't.
        blt $s2, 1, carpool_invalid	# check for invalid input

    jal calculate_motorized_emissions
    j cleanup_weekday_transportation

calculate_motorized_emissions:
    addiu $sp, $sp, -8       # Allocate space for local variables
    sw $s1, 0($sp)           # Save transport mode
    sw $s2, 4($sp)           # Save carpool count (if applicable)

    # Gets the emission factor for the user's choice
    beq $s1, 3, load_bus
    beq $s1, 4, load_car
    beq $s1, 5, load_carpool

load_bus:
    l.d $f0, ef_bus          # Load bus emission factor
    j process_emission

load_car:
    l.d $f0, ef_car          # Load car emission factor
    j process_emission

load_carpool:
    l.d $f0, ef_carpool      # Load carpool emission factor
    lw $s2, 4($sp)           # Retrieve carpool count
    mtc1 $s2, $f4            # Move carpool count to FP register
    cvt.d.w $f4, $f4         # Convert carpool count to double
    div.d $f0, $f0, $f4      # Adjust emission factor for carpool
    j process_emission

process_emission:
    mul.d $f0, $f0, $f2      # Daily emissions = factor * miles
    li $s3, 5                # Weekdays multiplier
    mtc1 $s3, $f4            # Move multiplier to FP register
    cvt.d.w $f4, $f4         # Convert to double
    mul.d $f0, $f0, $f4      # Weekly emissions = daily emissions * 5

    lw $s1, 0($sp)           # Restore transport mode
    lw $s2, 4($sp)           # Restore carpool count
    addiu $sp, $sp, 8        # Deallocate local variables
    jr $ra                   # Returning control to handle_weekday_transportation

cleanup_weekday_transportation:
	 # Prints the weekday transportation results
	li $v0, 4
    	la $a0, weekday_transportation_result
    	syscall

    	li $v0, 3
    	mov.d $f12, $f0          # Load emissions for printing
    	syscall

    # Restore stack
    lw $fp, 0($sp)        	# Restore frame pointer  
    lw $ra, 4($sp)        	# Restore return address  
    addiu $sp, $sp, 8      	# Deallocate stack space 
    jr $ra             		# Return to caller
    
main_question_invalid:
	# Lets the user know that their input was invalid and jumps to ask the question again.
	li $v0, 4
    	la $a0, main_question_invalid_msg   # Display invalid input message
    	syscall
    	j ask_main_question

transport_invalid:
	# Lets the user know that their input was invalid and jumps to ask the question again.
	li $v0, 4
    	la $a0, transport_question_invalid_msg   # Display invalid input message
    	syscall
    	j ask_transport
    
miles_invalid:
	# Lets the user know that their input was invalid and jumps to ask the question again.
	li $v0, 4
    	la $a0, miles_question_invalid_msg   # Display invalid input message
    	syscall
    	j ask_miles
    	
carpool_invalid:
	# Lets the user know that their input was invalid and jumps to ask the question again.
	li $v0, 4
    	la $a0, carpool_question_invalid_msg   # Display invalid input message
    	syscall
    	j ask_carpool
