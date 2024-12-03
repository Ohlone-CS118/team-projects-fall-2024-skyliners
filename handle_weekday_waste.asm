# need to move to main when andy is done

# weekday waste
.globl lunch_question
.globl notes_question
.globl waste_hours
.globl waste_pages
.globl waste_invalid_hours_msg
.globl waste_invalid_pages_msg

.globl ef_reusable
.globl ef_aluminum 
.globl ef_plastic 
.globl ef_pre_packaged
.globl ef_digital_device
.globl ef_recycled_paper
.globl ef_regular_notebook

# weekday waste values
lunch_question: 	.asciiz "How do you pack your lunch? 1)Reusable container 2)Aluminum foil 3)Plastic wrap 4)Pre-packaged meal"
notes_question:		.asciiz "What do you use for notes? 1)Digital device 2)Recycled paper 3)Regular notebook"
waste_hours:		.asciiz "How many hours do you use your digital device?(0-24)"
waste_pages		.asciiz "How many pages do you use?(0-20)"
waste_invalid_hours_msg: 	.asciiz "\nInvalid input! Please enter a value between 0 and 24."
waste_invalid_pages_msg: 	.asciiz "\nInvalid input! Please enter a value between 0 and 20."

ef_reusable: .double 0.03
ef_aluminum: .double 0.01
ef_plastic: .double 0.04
ef_pre_packaged: .double 2.5
ef_digital_device: .double 0.02 # per hour
ef_recycled_paper: .double 0.01 # per page
ef_regular_notebook: .double 0.05 # per page

.text

.globl handle_weekday_waste

	addiu $sp, $sp, -8       # Allocate stack space
    	sw $ra, 4($sp)           # Save return address
    	sw $t0, 0($sp)           # Save temporary register $t0
    	
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
    	bgt $v0, 20, waste_invalid_hours  # Check if input is above 24
    	move $t2, $v0               # Save valid page count
    	beq $t1, 2, get_waste_valid_recycled_pages		# If choice = recycled paper then go to get_waste_pages
    	beq $t1, 3, get_waste_valid_regular_pages		# If choice = regular paper then go to get_waste_pages

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
    	add.d $f6, $f8, $f10	# add lunch emission and notes emission
    	
    	# multiply by 5 for all weekdays
    	li $t4, 5
    	mtc1 $t4, $f4
    	cvt.d.w $f4, $f4
    	mul.d $f0, $f6, $f4       # Weekly waste emissions
    	
    	# Cleanup
    	lw $ra, 4($sp)              # Restore return address
    	lw $t0, 0($sp)              # Restore $t0
    	addiu $sp, $sp, 8           # Deallocate stack space
    	jr $ra                      # Return to main
