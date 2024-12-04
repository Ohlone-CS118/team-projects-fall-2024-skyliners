.text

.globl handle_weekday_waste
# preconditions: assumes that the $a, $t, $f registers have already been saved
# postcondition: the total waste emission for the weekday is stored in $f0
handle_weekday_waste:
	addiu $sp, $sp, -8       # Allocate stack space
    	sw $ra, 4($sp)           # Save return address
    	sw $t0, 0($sp)           # Save temporary register $t0
    	
ask_lunch_question: 	
    	li $v0, 4
    	la $a0, lunch_question
    	syscall

    	li $v0, 5
    	syscall
    	move $t1, $v0		# Save lunch choice
    	j get_lunch_emission
    	
ask_notes_question:
   	li $v0, 4
    	la $a0, notes_question
    	syscall

    	li $v0, 5
    	syscall
    	move $t1, $v0            # Save notes choice (Digital device, Recycled paper, Regular notebook
    	
    	beq $t1, 1, get_waste_hours		# If choice = digital device then go to get_waste_hours
    	beq $t1, 2, get_waste_pages		# If choice = recycled paper then go to get_waste_pages
    	beq $t1, 3, get_waste_pages		# If choice = regular paper then go to get_waste_pages
    	
    	# If user inputs something other than one of the choices
	li $v0, 4
    	la $a0, invalid_user_input
    	syscall
    	
    	j ask_notes_question
    	
get_waste_hours:
	li $v0, 4
    	la $a0, waste_hours
    	syscall
    	
    	li $v0, 5
    	syscall
    	
    	blt $v0, 0, waste_invalid_hours   # Check if input is below 0
    	bgt $v0, 24, waste_invalid_hours  # Check if input is above 24
    	move $t2, $v0               # Save valid light usage hours
    	j waste_valid_hours 
    	
    	
get_waste_pages:
	li $v0, 4
    	la $a0, waste_pages
    	syscall
    	
    	li $v0, 5
    	syscall
    	
    	blt $v0, 0, waste_invalid_hours   # Check if input is below 0
    	move $t2, $v0               # Save valid page count
    	beq $t1, 2, waste_valid_recycled_pages		# If choice = recycled paper then go to get_waste_pages
    	beq $t1, 3, waste_valid_regular_pages		# If choice = regular paper then go to get_waste_pages

waste_invalid_pages:
	li $v0, 4
    	la $a0, waste_invalid_pages_msg   # Display invalid input message
    	syscall
    	j ask_notes_question        # Retry the question
    	
waste_invalid_hours:
    	li $v0, 4
    	la $a0, waste_invalid_hours_msg   # Display invalid input message
    	syscall
    	j ask_notes_question        # Retry the question
    	
    	
waste_valid_hours:
	l.d $f2, ef_digital_device
	mtc1 $t2, $f4               # Move hours to floating-point register
    	cvt.d.w $f4, $f4            # Convert hours to double
    	mul.d $f6, $f2, $f4         # Total digital device emissions = EF * hours
    	j end_handle_weekday_waste

waste_valid_recycled_pages:
	l.d $f2, ef_recycled_paper
	mtc1 $t2, $f4               # Move hours to floating-point register
    	cvt.d.w $f4, $f4            # Convert hours to double
    	mul.d $f6, $f2, $f4         # Total recycled paper emissions = EF * pages
    	j end_handle_weekday_waste
    	
waste_valid_regular_pages:
	l.d $f2, ef_regular_notebook
	mtc1 $t2, $f4               # Move hours to floating-point register
    	cvt.d.w $f4, $f4            # Convert hours to double
    	mul.d $f6, $f2, $f4         # Total regular paper emissions = EF * pages
   	j end_handle_weekday_waste

get_lunch_emission:
	beq $t1, 1, get_reusable_ef
	beq $t1, 2, get_aluminum_ef
	beq $t1, 3, get_plastic_ef
	beq $t1, 4, get_pre_packaged_ef
	
	# If user inputs something other than one of the choices
	li $v0, 4
    	la $a0, invalid_user_input
    	syscall
    	
    	j ask_lunch_question
	
get_reusable_ef: 
	l.d $f8, ef_reusable
	j ask_notes_question
	
get_aluminum_ef:
	l.d $f8, ef_aluminum
	j ask_notes_question
		
get_plastic_ef:
	l.d $f8, ef_plastic
	j ask_notes_question
	
get_pre_packaged_ef:
	l.d $f8, ef_pre_packaged
	j ask_notes_question

end_handle_weekday_waste:	
    	add.d $f6, $f8, $f6	# add lunch emission and notes emission
    	
    	# multiply by 5 for all weekdays
    	li $t4, 5
    	mtc1 $t4, $f4
    	cvt.d.w $f4, $f4
    	mul.d $f0, $f6, $f4       # Weekly waste emissions
    	
    	li $v0, 4
    	la $a0, weekday_waste_result
    	syscall

    	li $v0, 3
    	mov.d $f12, $f0          # Load emissions for printing
    	syscall
    	
    	# Cleanup
    	lw $ra, 4($sp)              # Restore return address
    	lw $t0, 0($sp)              # Restore $t0
    	addiu $sp, $sp, 8           # Deallocate stack space
    	jr $ra                      # Return to main
