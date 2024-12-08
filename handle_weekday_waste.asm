.text

.globl handle_weekday_waste
# preconditions: assumes that the $a and $f registers have already been saved
# postcondition: the total energy emission for the weekday is stored in $f0
# Contributors: Emma. 12/02/2024(wrote the subroutine) - 12/04/2024(error checking)
# Purpose: Gives prompts and calculates the carbon emission of the weekday energy questions
handle_weekday_waste:
	# Set up stack
    	addiu $sp, $sp, -8     	# Allocate stack space  
    	sw $ra, 4($sp)        	# Save return address  
    	sw $fp, 0($sp)        	# stash the frame pointer  
    	addi $fp, $sp, 4      	# set the frame pointer the beginning of the stack

    	
ask_lunch_question: 	
	# Asks the lunch question and gets the user choice for calculations
    	li $v0, 4		# Prints
    	la $a0, lunch_question
    	syscall

	# Gets the user's choice as an integer because it's just used for branching
    	li $v0, 5
    	syscall
    	
    	# Goes to the appropriate label based on user choice
	beq $v0, 1, get_reusable_ef
	beq $v0, 2, get_aluminum_ef
	beq $v0, 3, get_plastic_ef
	beq $v0, 4, get_pre_packaged_ef
	
	# If user inputs something other than one of the choices it says that the choice is invaild and jumps back to the question(error checking).
	li $v0, 4
    	la $a0, invalid_user_input
    	syscall
    	
    	j ask_lunch_question
    	
ask_notes_question:
	# Asks the notes question and gets the user choice for calculations
   	li $v0, 4
    	la $a0, notes_question
    	syscall

    	li $v0, 5
    	syscall
    	move $s1, $v0            # Save notes choice (Digital device, Recycled paper, Regular notebook). Need to save the choice because get_waste_pages also has a branch based on $s1.
    	
   	# Goes to the appropriate label based on user choice
    	beq $s1, 1, get_waste_hours		# If choice = digital device then go to get_waste_hours
    	beq $s1, 2, get_waste_pages		# If choice = recycled paper then go to get_waste_pages
    	beq $s1, 3, get_waste_pages		# If choice = regular paper then go to get_waste_pages
    	
	# If user inputs something other than one of the choices it says that the choice is invaild and jumps back to the question(error checking).
	li $v0, 4
    	la $a0, invalid_user_input
    	syscall
    	
    	j ask_notes_question
    	
get_waste_hours:
	# Asks the user for how many hours they use their digital device to use for calculations
	li $v0, 4
    	la $a0, waste_hours
    	syscall
    	
    	# Get user input as an integer so that the error check is more simple even though we convert it to a double for calculations later
    	li $v0, 5
    	syscall
    	
    	# Error checking
    	blt $v0, 0, waste_invalid_hours   # Check if input is below 0
    	bgt $v0, 24, waste_invalid_hours  # Check if input is above 24
    	move $s2, $v0               	  # Save valid hours
    	
    	# If the hours entered are valid, then we can continue with the calculations
    	j waste_valid_hours 
    	
    	
get_waste_pages:
	# Get the user input for how many pages(front and back) they use for both recycled and regular paper.
	li $v0, 4
    	la $a0, waste_pages
    	syscall
    	
    	# Get user input as a word so that the error check is more simple even though we convert it to a double for calculations later
    	li $v0, 5
    	syscall
    	
    	blt $v0, 0, waste_invalid_hours   # Check if input is below 0
    	move $s2, $v0               # Save valid page count
    	
    	# Since the flow would have gone to waste_invalid_hours if the user entered a negative number, we can now go to the calculations based on what the user entered
    	beq $s1, 2, waste_valid_recycled_pages		# If choice = recycled paper then go to get_waste_pages
    	beq $s1, 3, waste_valid_regular_pages		# If choice = regular paper then go to get_waste_pages

waste_invalid_pages:
	# If the user entered a negative number then the flow of the code goes here to tell them that they put in an invalid input and sends them back to the pages question(error checking)
	li $v0, 4
    	la $a0, invalid_user_input
    	syscall
    	j get_waste_pages        # Retry the question
    	
waste_invalid_hours:
	# If the user entered a number that is less than 0 or greater than 24 then the flow of code goes here to tell them that their input was invalid 
	# and sends them back to the hours question(error checking).
	li $v0, 4
    	la $a0, invalid_user_input
    	syscall
    	j get_waste_hours        # Retry the question
    	
    	
waste_valid_hours:
	# Loads in the emission factor and converts the hour word to a double for calculation, which is the emission for the question
	l.d $f2, ef_digital_device
	mtc1 $s2, $f4               # Move hours to floating-point register
    	cvt.d.w $f4, $f4            # Convert hours to double
    	mul.d $f6, $f2, $f4         # Total digital device emissions = EF * hours
    	j end_handle_weekday_waste

waste_valid_recycled_pages:
	# Loads in the emission factor and converts the page word to a double for calculation, which is the emission for the question
	l.d $f2, ef_recycled_paper
	mtc1 $s2, $f4               # Move hours to floating-point register
    	cvt.d.w $f4, $f4            # Convert hours to double
    	mul.d $f6, $f2, $f4         # Total recycled paper emissions = EF * pages
    	j end_handle_weekday_waste
    	
waste_valid_regular_pages:
	# Loads in the emission factor and converts the page word to a double for calculation, which is the emission for the question
	l.d $f2, ef_regular_notebook
	mtc1 $s2, $f4               # Move hours to floating-point register
    	cvt.d.w $f4, $f4            # Convert hours to double
    	mul.d $f6, $f2, $f4         # Total regular paper emissions = EF * pages
   	j end_handle_weekday_waste	
	
get_reusable_ef: 
	# Loads the emission factor, which is the only emission calculation for the lunch question, and jumps to the next question.
	l.d $f8, ef_reusable
	j ask_notes_question
	
get_aluminum_ef:
	# Loads the emission factor, which is the only emission calculation for the lunch question, and jumps to the next question.
	l.d $f8, ef_aluminum
	j ask_notes_question
		
get_plastic_ef:
	# Loads the emission factor, which is the only emission calculation for the lunch question, and jumps to the next question.
	l.d $f8, ef_plastic
	j ask_notes_question
	
get_pre_packaged_ef:
	# Loads the emission factor, which is the only emission calculation for the lunch question, and jumps to the next question.
	l.d $f8, ef_pre_packaged
	j ask_notes_question

end_handle_weekday_waste:	
    	add.d $f6, $f8, $f6	# add lunch emission and notes emission for the total emission of the day
    	
    	# multiply by 5 for all weekdays
    	li $s4, 5
    	mtc1 $s4, $f4
    	cvt.d.w $f4, $f4
    	mul.d $f0, $f6, $f4       # Weekly waste emissions
    	
   	# Prints the weekday waste emission results
    	li $v0, 4
    	la $a0, weekday_waste_result
    	syscall

    	li $v0, 3
    	mov.d $f12, $f0          # Load emissions for printing
    	syscall
    	
    	# Restore stack
    	lw $fp, 0($sp)        	# Restore frame pointer  
    	lw $ra, 4($sp)        	# Restore return address  
    	addiu $sp, $sp, 8      	# Deallocate stack space 
    	jr $ra             		# Return to caller
