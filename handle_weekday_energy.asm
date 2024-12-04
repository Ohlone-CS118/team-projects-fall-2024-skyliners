# Weekday Energy Calulations
# This module calculates the weekday energy emissions 

.text
.globl handle_weekday_energy

# preconditions: assumes that the $a, $t, $f registers have already been saved
# postcondition: the total energy emission for the weekday is stored in $f0
# Handle weekday energy input and calculations
handle_weekday_energy:
    addiu $sp, $sp, -8       # Allocate stack space
    sw $ra, 4($sp)           # Save return address
    sw $t0, 0($sp)           # Save temporary register $t0

solar_label:
    # Question 1: Solar Panels
    li $v0, 4
    la $a0, solar_question
    syscall

    li $v0, 5
    syscall
    move $t0, $v0            # Save solar panel choice
    
    blt $t0, 1, invalid_solar
    bgt $t0, 2, invalid_solar

light_bulb_label:
    # Question 2: Light Bulb Type
    li $v0, 4
    la $a0, bulb_question
    syscall

    li $v0, 5
    syscall
    move $t1, $v0            # Save light bulb type
    
    blt $t1, 1, invalid_light
    bgt $t1, 2, invalid_light
    
    # Question 3: Light Usage Hours (Allow 0-24)
light_hours_prompt:
    li $v0, 4
    la $a0, light_hours_question
    syscall

    li $v0, 5
    syscall
    blt $v0, 0, invalid_hours   # Check if input is below 0
    bgt $v0, 24, invalid_hours  # Check if input is above 24
    move $t2, $v0               # Save valid light usage hours
    j valid_hours

invalid_hours:
    li $v0, 4
    la $a0, invalid_hours_msg   # Display invalid input message
    syscall
    j light_hours_prompt        # Retry the question

valid_hours:

heater_label:
    # Question 4: Heater or Blanket
    li $v0, 4
    la $a0, heater_or_blanket_question
    syscall

    li $v0, 5
    syscall
    move $t3, $v0               # Save heating choice
    
    blt $t3, 1, invalid_heater
    bgt $t3, 2, invalid_heater

    # Calculate Light Bulb Emissions
    beq $t1, 1, use_led         # If LED
    beq $t1, 2, use_incandescent # If Incandescent

use_led:
    l.d $f0, ef_led             # Load LED emission factor
    j calculate_light_emissions

use_incandescent:
    l.d $f0, ef_incandescent    # Load incandescent emission factor

calculate_light_emissions:
    mtc1 $t2, $f4               # Move hours to floating-point register
    cvt.d.w $f4, $f4            # Convert hours to double
    mul.d $f6, $f0, $f4         # Total light bulb emissions = EF * hours

    # Calculate Heater or Blanket Emissions
    beq $t3, 1, use_heater      # If Heater
    beq $t3, 2, use_blanket     # If Blanket

use_heater:
    l.d $f0, ef_heater          # Load heater emission factor
    mul.d $f8, $f0, $f4         # Total heater emissions = EF * hours
    j sum_energy_emissions

use_blanket:
    l.d $f8, ef_blanket         # Load blanket emission factor (0 emissions)
    j sum_energy_emissions

invalid_solar:
# If user inputs something other than one of the choices
	li $v0, 4
    	la $a0, invalid_user_input
    	syscall
    	
    	j solar_label

invalid_light:
# If user inputs something other than one of the choices
	li $v0, 4
    	la $a0, invalid_user_input
    	syscall
    	
    	j light_bulb_label

invalid_heater:
# If user inputs something other than one of the choices
	li $v0, 4
    	la $a0, invalid_user_input
    	syscall
    	
    	j heater_label

sum_energy_emissions:
    add.d $f10, $f6, $f8        # Total energy emissions = light + heater/blanket

    # Multiply by 5 for weekday total
    li $t4, 5
    mtc1 $t4, $f4
    cvt.d.w $f4, $f4
    mul.d $f0, $f10, $f4       # Weekly energy emissions

    # Cleanup
    lw $ra, 4($sp)              # Restore return address
    lw $t0, 0($sp)              # Restore $t0
    addiu $sp, $sp, 8           # Deallocate stack space
    jr $ra                      # Return to main
