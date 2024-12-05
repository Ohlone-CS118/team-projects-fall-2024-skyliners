# Weekend Waste Calulations

.text
.globl handle_weekend_waste
# preconditions: assumes that the $a, $t, $f registers have already been saved
# postcondition: the total waste emission for the weekday is stored in $f0
# Contributors: Ni Linn(Wrote subroutine) and Emma(error checking). 12/03/2024(wrote the subroutine) - 12/04/2024(error checking)
# Purpose: Calculates the carbon emission of the weekend waste questions
handle_weekend_waste:
    # Set up stack
    addiu $sp, $sp, -8           # Allocate stack space
    sw $ra, 4($sp)               # Save return address
    sw $t0, 0($sp)               # Save $t0

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

    # Restore stack
    lw $ra, 4($sp)               # Restore return address
    lw $t0, 0($sp)               # Restore $t0
    addiu $sp, $sp, 8            # Deallocate stack space

    jr $ra

# preconditions: assumes that the $a, $t, $f registers have already been saved
# postcondition: the total waste emission for the weekday is stored in $f0
# Contributors: Ni Linn(Wrote subroutine) and Emma(error checking). 12/03/2024(wrote the subroutine) - 12/04/2024(error checking)
# Purpose: Gives prompts and calculates the carbon emission of the bag question
# Subroutine for grocery bag emissions
handle_bag_emission:
    li $v0, 4
    la $a0, bag_question
    syscall

    li $v0, 5
    syscall
    move $s0, $v0

    beq $s0, 1, bag_reusable
    beq $s0, 2, bag_paper
    beq $s0, 3, bag_plastic
    
    # If user inputs something other than one of the choices it says that the choice is invaild and jumps back to the question(error checking).
    li $v0, 4                   # Print invalid input message
    la $a0, invalid_user_input
    syscall
    
    j handle_bag_emission

bag_reusable:
    l.d $f12, ef_reusable_bag
    jr $ra

bag_paper:
    l.d $f12, ef_paper_bag
    jr $ra

bag_plastic:
    l.d $f12, ef_plastic_bag
    jr $ra

# preconditions: assumes that the $a, $t, $f registers have already been saved
# postcondition: the total waste emission for the weekday is stored in $f0
# Contributors: Ni Linn(Wrote subroutine) and Emma(error checking). 12/03/2024(wrote the subroutine) - 12/04/2024(error checking)
# Purpose: Gives prompts and calculates the carbon emission of the weekend waste questions
# Subroutine for gathering emissions
handle_gathering_emission:
    li $v0, 4
    la $a0, gathering_question
    syscall

    li $v0, 5
    syscall
    move $s0, $v0


    beq $s0, 1, gathering_reusable
    beq $s0, 2, gathering_mixed
    beq $s0, 3, gathering_disposable

    # If user inputs something other than one of the choices it says that the choice is invaild and jumps back to the question(error checking).
    li $v0, 4                   # Print invalid input message
    la $a0, invalid_user_input
    syscall
    
    j handle_gathering_emission

gathering_reusable:
    l.d $f12, ef_reusable_items
    jr $ra

gathering_mixed:
    l.d $f12, ef_mixed_items
    jr $ra

gathering_disposable:
    l.d $f12, ef_disposable_items
    jr $ra

# Subroutine for food waste
handle_food_waste:
    li $v0, 4
    la $a0, food_waste_question
    syscall

    li $v0, 5
    syscall
    move $s0, $v0

    beq $s0, 1, food_none
    beq $s0, 2, food_moderate
    beq $s0, 3, food_significant
    
    # If user inputs something other than one of the choices it says that the choice is invaild and jumps back to the question(error checking).
    li $v0, 4                   # Print invalid input message
    la $a0, invalid_user_input
    syscall
    
    j handle_food_waste

food_none:
    l.d $f12, ef_food_waste_none
    jr $ra

food_moderate:
    l.d $f12, ef_food_waste_moderate
    jr $ra

food_significant:
    l.d $f12, ef_food_waste_significant
    jr $ra

# Subroutine for packaging waste
handle_packaging_waste:
    li $v0, 4
    la $a0, packaging_waste_question
    syscall

    li $v0, 5
    syscall
    move $s0, $v0

    beq $s0, 1, packaging_none
    beq $s0, 2, packaging_moderate
    beq $s0, 3, packaging_significant

    # If user inputs something other than one of the choices it says that the choice is invaild and jumps back to the question(error checking).
    li $v0, 4                   # Print invalid input message
    la $a0, invalid_user_input
    syscall
    
    j handle_packaging_waste

packaging_none:
    l.d $f12, ef_packaging_waste_none
    jr $ra

packaging_moderate:
    l.d $f12, ef_packaging_waste_moderate
    jr $ra

packaging_significant:
    l.d $f12, ef_packaging_waste_significant
    jr $ra

# preconditions: assumes that the $a, $t, $f registers have already been saved
# postcondition: the total waste emission for the weekday is stored in $f0
# Contributors: Ni Linn(Wrote subroutine) and Emma(error checking). 12/03/2024(wrote the subroutine) - 12/04/2024(error checking)
# Purpose: Gives prompts and calculates the carbon emission of the weekend waste questions
# Subroutine for personal waste habits
handle_personal_waste:
    li $v0, 4
    la $a0, personal_waste_question
    syscall

    li $v0, 5
    syscall
    move $s0, $v0

    beq $s0, 1, recycled
    beq $s0, 2, non_recycled
    
    # If user inputs something other than one of the choices it says that the choice is invaild and jumps back to the question(error checking).
    li $v0, 4                   # Print invalid input message
    la $a0, invalid_user_input
    syscall
    
    j handle_personal_waste

recycled:
    l.d $f12, ef_recycled
    jr $ra

non_recycled:
    l.d $f12, ef_non_recycled
    jr $ra