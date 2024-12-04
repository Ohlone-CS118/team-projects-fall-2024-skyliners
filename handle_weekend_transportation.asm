.text
.globl handle_weekend_transportation
# preconditions: assumes that the $a, $t, $f registers have already been saved
# postcondition: the total transportation emission for the weekday is stored in $f0
# Handle weekend transportation input and calculations
handle_weekend_transportation:
    	addiu $sp, $sp, -8       # Allocate space on the stack
    	sw $ra, 4($sp)           # Save return address to main
    	sw $t0, 0($sp)           # Save temporary register $t0
    
    	li $v0, 4
    	la $a0, weekend_transportation_main_question
    	syscall

    	li $v0, 5
    	syscall
    	move $t1, $v0		# Store the transport method

    	beq $t1, 3, weekend_ask_miles    # If Bus/Public Transit
    	beq $t1, 4, weekend_ask_miles    # If Personal Car
    	beq $t1, 5, weekend_ask_miles    # If Carpool

    	l.d $f0, zero_value      # Non-motorized emissions (default to 0)
    
    	j end_weekend_transportation
 
  
weekend_ask_miles: 
	li $v0, 4
    	la $a0, weekend_miles_question
    	syscall

    	li $v0, 7
    	syscall
    	mov.d $f2, $f0           # Save miles in $f2

    	beq $t1, 5, weekend_ask_carpool  # If carpool
    	jal calculate_weekend_motorized_emissions  # Otherwise, calculate emissions
    	j end_weekend_transportation

weekend_ask_carpool:
 	li $v0, 4
    	la $a0, weekend_carpool_question
    	syscall

    	li $v0, 5
    	syscall
    	move $t2, $v0            # Save carpool count

    	jal calculate_weekend_motorized_emissions
    	j end_weekend_transportation

calculate_weekend_motorized_emissions:
    	addiu $sp, $sp, -8       # Allocate space for local variables
    	sw $t1, 0($sp)           # Save transport mode
    	sw $t2, 4($sp)           # Save carpool count (if applicable)

    	beq $t1, 3, weekend_load_bus
    	beq $t1, 4, weekend_load_car
    	beq $t1, 5, weekend_load_carpool

weekend_load_bus:
    	l.d $f0, ef_bus          # Load bus emission factor
    	j process_weekend_emission

weekend_load_car:
    	l.d $f0, ef_car          # Load car emission factor
    	j process_weekend_emission

weekend_load_carpool:
    	l.d $f0, ef_carpool      # Load carpool emission factor
    	lw $t2, 4($sp)           # Retrieve carpool count
    	mtc1 $t2, $f4            # Move carpool count to FP register
    	cvt.d.w $f4, $f4         # Convert carpool count to double
    	div.d $f0, $f0, $f4      # Adjust emission factor for carpool
    	j process_weekend_emission

process_weekend_emission:
    	mul.d $f0, $f0, $f2      # Daily emissions = factor * miles
    	li $t3, 2                # Weekend multiplier
    	mtc1 $t3, $f4            # Move multiplier to FP register
    	cvt.d.w $f4, $f4         # Convert to double
    	mul.d $f0, $f0, $f4      # Weekly emissions = daily emissions * 2

    	lw $t1, 0($sp)           # Restore transport mode
    	lw $t2, 4($sp)           # Restore carpool count
    	addiu $sp, $sp, 8        # Deallocate local variables
    	jr $ra                   # Returning control to handle_weekday_transportation

end_weekend_transportation:
	li $v0, 4
    	la $a0, weekend_transportation_result
    	syscall

    	li $v0, 3
    	mov.d $f12, $f0          # Load emissions for printing
    	syscall


    	lw $ra, 4($sp)           # Restore return address
    	lw $t0, 0($sp)           # Restore $t0
    	addiu $sp, $sp, 8        # Deallocate stack space
    	jr $ra                   # Returning control to main
