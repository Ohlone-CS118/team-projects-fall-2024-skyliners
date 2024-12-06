# Weekday Transportation Calulations
# This module calculates the weekday transportation emissions 

.text
.globl handle_weekday_transportation

# preconditions: assumes that the $a, $t, $f registers have already been saved
# postcondition: the total transportation emission for the weekday is stored in $f0
# Handle weekday transportation input and calculations
handle_weekday_transportation:
    addiu $sp, $sp, -8       # Allocate space on the stack
    sw $ra, 4($sp)           # Save return address to main
    sw $t0, 0($sp)           # Save temporary register $t0

ask_main_question:
    li $v0, 4
    la $a0, main_question
    syscall

    li $v0, 5
    syscall
    move $s0, $v0            # Save main choice (school/work/both)

	blt $s0, 1, main_question_invalid	# check for invalid input
	bgt $s0, 3, main_question_invalid

ask_transport:
    li $v0, 4
    la $a0, transport_question
    syscall

    li $v0, 5
    syscall
    move $s1, $v0            # Save transport mode
    
    	blt $s1, 1, transport_invalid	# check for invalid input
	bgt $s1, 5, transport_invalid

    beq $s1, 3, ask_miles    # If Bus/Public Transit
    beq $s1, 4, ask_miles    # If Personal Car
    beq $s1, 5, ask_miles    # If Carpool

    l.d $f0, zero_value      # Non-motorized emissions (default to 0)
    j cleanup_weekday_transportation

ask_miles:
    li $v0, 4
    la $a0, miles_question
    syscall

    li $v0, 7
    syscall
    mov.d $f2, $f0           # Save miles in $f2
    l.d $f0, zero_value      # load zero value
	c.lt.d $f2, $f0	# check if miles < 0
	bc1t miles_invalid

    beq $s1, 5, ask_carpool  # If carpool
    jal calculate_motorized_emissions  # Otherwise, calculate emissions
    j cleanup_weekday_transportation

ask_carpool:
    li $v0, 4
    la $a0, carpool_question
    syscall

    li $v0, 5
    syscall
    move $s2, $v0            # Save carpool count
    
        blt $s2, 1, carpool_invalid	# check for invalid input

    jal calculate_motorized_emissions
    j cleanup_weekday_transportation

calculate_motorized_emissions:
    addiu $sp, $sp, -8       # Allocate space for local variables
    sw $s1, 0($sp)           # Save transport mode
    sw $s2, 4($sp)           # Save carpool count (if applicable)

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
    lw $ra, 4($sp)           # Restore return address
    lw $t0, 0($sp)           # Restore $t0
    addiu $sp, $sp, 8        # Deallocate stack space
    jr $ra                   # Returning control to main
    
    
    
main_question_invalid:
	li $v0, 4
    	la $a0, main_question_invalid_msg   # Display invalid input message
    	syscall
    	j ask_main_question
    

    
    
transport_invalid:
	li $v0, 4
    	la $a0, transport_question_invalid_msg   # Display invalid input message
    	syscall
    	j ask_transport
    
miles_invalid:
	li $v0, 4
    	la $a0, miles_question_invalid_msg   # Display invalid input message
    	syscall
    	j ask_miles
    	
carpool_invalid:
	li $v0, 4
    	la $a0, carpool_question_invalid_msg   # Display invalid input message
    	syscall
    	j ask_carpool