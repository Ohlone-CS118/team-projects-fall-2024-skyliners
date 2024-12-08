# Weekend Waste Calulations

.text
.globl handle_weekend_waste
# preconditions: assumes that the $a and $f registers have already been saved
# postcondition: the total waste emission for the weekday is stored in $f0
# Contributors: Ni Linn(Wrote subroutine) and Emma(error checking). 12/03/2024(wrote the subroutine) - 12/04/2024(error checking)
# Purpose: Calculates the carbon emission of the weekend waste questions
handle_weekend_waste:
    # Set up stack
    addiu $sp, $sp, -8     	# Allocate stack space  
    sw $ra, 4($sp)        	# Save return address  
    sw $fp, 0($sp)        	# stash the frame pointer  
    addi $fp, $sp, 4      	# set the frame pointer the beginning of the stack

    # Handle grocery bag emissions
    jal handle_bag_emission
    mov.d $f10, $f12             # Store bag emissions in $f10

    # Handle gathering emissions
    jal handle_gathering_emission
    mov.d $f8, $f12              # Store gathering emissions in $f8

    # Handle food waste emissions
    jal handle_food_waste
    mov.d $f6, $f12              # Store food waste emissions in $f6

    # Handle packaging waste emissions
    jal handle_packaging_waste
    mov.d $f4, $f12              # Store packaging waste emissions in $f4

    # Handle personal waste habits
    jal handle_personal_waste
    mov.d $f2, $f12              # Store personal waste emissions in $f2

    # Calculate total emissions
    add.d $f12, $f10, $f8        # Add bag and gathering emissions
    add.d $f12, $f12, $f6        # Add food waste emissions
    add.d $f12, $f12, $f4        # Add packaging waste emissions
    add.d $f12, $f12, $f2        # Add personal waste emissions

    # Multiply total emissions by 2 (for two days of the weekend)
    li $s1, 2                    # Load the value 2 into $t1
    mtc1 $s1, $f0                # Move $t1 into floating-point register $f0
    cvt.d.w $f0, $f0             # Convert $f0 to double
    mul.d $f0, $f12, $f0        # Multiply total emissions by 2
    
    # Prints the weekend waste results
    li $v0, 4
    la $a0, weekend_waste_result
    syscall

    li $v0, 3
    mov.d $f12, $f0          # Load emissions for printing
    syscall

    # Restore stack
    lw $fp, 0($sp)        	# Restore frame pointer  
    lw $ra, 4($sp)        	# Restore return address  
    addiu $sp, $sp, 8      	# Deallocate stack space 
    jr $ra             		# Return to caller

# preconditions: assumes that the $a and $f registers have already been saved
# postcondition: the waste emission for the question is stored in $f12
# Contributors: Ni Linn(Wrote subroutine) and Emma(error checking). 12/03/2024(wrote the subroutine) - 12/04/2024(error checking)
# Purpose: Gives prompts and calculates the carbon emission of the bag question
# Subroutine for grocery bag emissions
handle_bag_emission:
    # Set up stack
    addiu $sp, $sp, -8     	# Allocate stack space  
    sw $ra, 4($sp)        	# Save return address  
    sw $fp, 0($sp)        	# stash the frame pointer  
    addi $fp, $sp, 4      	# set the frame pointer the beginning of the stack
    
    # Asks the user what kind of bag they use for shopping
    li $v0, 4
    la $a0, bag_question
    syscall
    
    # Gets the user input as an integer so that the branching is easier 
    li $v0, 5
    syscall

    # Goes to get the emission factor based on the user's choice
    beq $v0, 1, bag_reusable
    beq $v0, 2, bag_paper
    beq $v0, 3, bag_plastic
    
    # If user inputs something other than one of the choices it says that the choice is invaild and jumps back to the question(error checking).
    li $v0, 4                   # Print invalid input message
    la $a0, invalid_user_input
    syscall
    
    j handle_bag_emission

bag_reusable:
    # Gets the emission factor for the user's choice
    l.d $f12, ef_reusable_bag
    j end_bag

bag_paper:
    # Gets the emission factor for the user's choice
    l.d $f12, ef_paper_bag
    j end_bag

bag_plastic:
    # Gets the emission factor for the user's choice
    l.d $f12, ef_plastic_bag
    j end_bag
    
end_bag:
    # Restore stack
    lw $fp, 0($sp)        	# Restore frame pointer  
    lw $ra, 4($sp)        	# Restore return address  
    addiu $sp, $sp, 8      	# Deallocate stack space 
    jr $ra             		# Return to caller
    

# preconditions: assumes that the $a and $f registers have already been saved
# postcondition: the waste emission for the question is stored in $f12
# Contributors: Ni Linn(Wrote subroutine) and Emma(error checking). 12/03/2024(wrote the subroutine) - 12/04/2024(error checking)
# Purpose: Gives prompts and calculates the carbon emission of the gathering question
# Subroutine for gathering emissions
handle_gathering_emission:
    # Set up stack
    addiu $sp, $sp, -8     	# Allocate stack space  
    sw $ra, 4($sp)        	# Save return address  
    sw $fp, 0($sp)        	# stash the frame pointer  
    addi $fp, $sp, 4      	# set the frame pointer the beginning of the stack
 
    # Asks the user what they use at gatherings
    li $v0, 4
    la $a0, gathering_question
    syscall

    # Gets the user input as an integer so that the branching is easier 
    li $v0, 5
    syscall
    
    # Goes to get the emission factor based on the user's choice
    beq $v0, 1, gathering_reusable
    beq $v0, 2, gathering_mixed
    beq $v0, 3, gathering_disposable

    # If user inputs something other than one of the choices it says that the choice is invaild and jumps back to the question(error checking).
    li $v0, 4                   # Print invalid input message
    la $a0, invalid_user_input
    syscall
    
    j handle_gathering_emission

gathering_reusable:
    # Gets the emission factor for the user's choice
    l.d $f12, ef_reusable_items
    j end_gathering 
    
gathering_mixed:
    # Gets the emission factor for the user's choice
    l.d $f12, ef_mixed_items
    j end_gathering 

gathering_disposable:
    # Gets the emission factor for the user's choice
    l.d $f12, ef_disposable_items
    j end_gathering 
    
end_gathering:    
    # Restore stack
    lw $fp, 0($sp)        	# Restore frame pointer  
    lw $ra, 4($sp)        	# Restore return address  
    addiu $sp, $sp, 8      	# Deallocate stack space 
    jr $ra             		# Return to caller

# preconditions: assumes that the $a and $f registers have already been saved
# postcondition: the waste emission for the question is stored in $f12
# Contributors: Ni Linn(Wrote subroutine) and Emma(error checking). 12/03/2024(wrote the subroutine) - 12/04/2024(error checking)
# Purpose: Gives prompts and calculates the carbon emission of the food waste question
# Subroutine for food waste
handle_food_waste:
    # Set up stack
    addiu $sp, $sp, -8     	# Allocate stack space  
    sw $ra, 4($sp)        	# Save return address  
    sw $fp, 0($sp)        	# stash the frame pointer  
    addi $fp, $sp, 4      	# set the frame pointer the beginning of the stack
    
    # Asks the user how much food waste they produce
    li $v0, 4
    la $a0, food_waste_question
    syscall

    # Gets the user input as an integer so that the branching is easier 
    li $v0, 5
    syscall
    
    # Goes to get the emission factor based on the user's choice
    beq $v0, 1, food_none
    beq $v0, 2, food_moderate
    beq $v0, 3, food_significant
    
    # If user inputs something other than one of the choices it says that the choice is invaild and jumps back to the question(error checking).
    li $v0, 4                   # Print invalid input message
    la $a0, invalid_user_input
    syscall
    
    j handle_food_waste

food_none:
    # Gets the emission factor for the user's choice
    l.d $f12, ef_food_waste_none
    j food_waste_end

food_moderate:
    # Gets the emission factor for the user's choice
    l.d $f12, ef_food_waste_moderate
    j food_waste_end

food_significant:
    # Gets the emission factor for the user's choice
    l.d $f12, ef_food_waste_significant
    j food_waste_end

food_waste_end:    
    # Restore stack
    lw $fp, 0($sp)        	# Restore frame pointer  
    lw $ra, 4($sp)        	# Restore return address  
    addiu $sp, $sp, 8      	# Deallocate stack space 
    jr $ra             		# Return to caller

# preconditions: assumes that the $a and $f registers have already been saved
# postcondition: the waste emission for the question is stored in $f12
# Contributors: Ni Linn(Wrote subroutine) and Emma(error checking). 12/03/2024(wrote the subroutine) - 12/04/2024(error checking)
# Purpose: Gives prompts and calculates the carbon emission of the packaging waste question
# Subroutine for packaging waste
handle_packaging_waste:
    # Set up stack
    addiu $sp, $sp, -8     	# Allocate stack space  
    sw $ra, 4($sp)        	# Save return address  
    sw $fp, 0($sp)        	# stash the frame pointer  
    addi $fp, $sp, 4      	# set the frame pointer the beginning of the stack
    
    # Asks the user how much packaging waste they produce
    li $v0, 4
    la $a0, packaging_waste_question
    syscall

    # Gets the user input as an integer so that the branching is easier 
    li $v0, 5
    syscall

    # Goes to get the emission factor based on the user's choice
    beq $v0, 1, packaging_none
    beq $v0, 2, packaging_moderate
    beq $v0, 3, packaging_significant

    # If user inputs something other than one of the choices it says that the choice is invaild and jumps back to the question(error checking).
    li $v0, 4                   # Print invalid input message
    la $a0, invalid_user_input
    syscall
    
    j handle_packaging_waste

packaging_none:
    # Gets the emission factor for the user's choice
    l.d $f12, ef_packaging_waste_none
    j packaging_end

packaging_moderate:
    # Gets the emission factor for the user's choice
    l.d $f12, ef_packaging_waste_moderate
    j packaging_end

packaging_significant:
    # Gets the emission factor for the user's choice
    l.d $f12, ef_packaging_waste_significant
    j packaging_end
    
packaging_end:    
    # Restore stack
    lw $fp, 0($sp)        	# Restore frame pointer  
    lw $ra, 4($sp)        	# Restore return address  
    addiu $sp, $sp, 8      	# Deallocate stack space 
    jr $ra             		# Return to caller

# preconditions: assumes that the $a, $t, $f registers have already been saved
# postcondition: the total waste emission for the weekday is stored in $f0
# Contributors: Ni Linn(Wrote subroutine) and Emma(error checking). 12/03/2024(wrote the subroutine) - 12/04/2024(error checking)
# Purpose: Gives prompts and calculates the carbon emission of the personal waste habits question
# Subroutine for personal waste habits
handle_personal_waste:
    # Set up stack
    addiu $sp, $sp, -8     	# Allocate stack space  
    sw $ra, 4($sp)        	# Save return address  
    sw $fp, 0($sp)        	# stash the frame pointer  
    addi $fp, $sp, 4      	# set the frame pointer the beginning of the stack
    
    # Asks the user what their personal waste habits are
    li $v0, 4
    la $a0, personal_waste_question
    syscall

    # Gets the user input as an integer so that the branching is easier 
    li $v0, 5
    syscall

    # Goes to get the emission factor based on the user's choice
    beq $v0, 1, recycled
    beq $v0, 2, non_recycled
    
    # If user inputs something other than one of the choices it says that the choice is invaild and jumps back to the question(error checking).
    li $v0, 4                   # Print invalid input message
    la $a0, invalid_user_input
    syscall
    
    j handle_personal_waste

recycled:
    # Gets the emission factor for the user's choice
    l.d $f12, ef_recycled
    j personal_waste_end

non_recycled:
    # Gets the emission factor for the user's choice
    l.d $f12, ef_non_recycled
    j personal_waste_end
    
personal_waste_end:    
    # Restore stack
    lw $fp, 0($sp)        	# Restore frame pointer  
    lw $ra, 4($sp)        	# Restore return address  
    addiu $sp, $sp, 8      	# Deallocate stack space 
    jr $ra             		# Return to caller
