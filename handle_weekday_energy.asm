# Weekday Energy Calulations
# This module calculates the weekday energy emissions 

.text
.globl handle_weekday_energy

# preconditions: assumes that the $a and $f registers have already been saved
# postcondition: the total energy emission for the weekday is stored in $f0
# Contributors: Ni Linn(Wrote the subroutine) and Emma(error checking). 12/02/2024(wrote the subroutine) - 12/04/2024(error checking)
# Purpose: Gives prompts and calculates the carbon emission of the weekday energy questions
handle_weekday_energy:
    # Set up stack
    addiu $sp, $sp, -8     	# Allocate stack space  
    sw $ra, 4($sp)        	# Save return address  
    sw $fp, 0($sp)        	# stash the frame pointer  
    addi $fp, $sp, 4      	# set the frame pointer the beginning of the stack

solar_label:
    # Question 1: Solar Panels
    # Asks the user if they have solar or not. If they do, when we get the total energy emission for the weekdays, we'll divide the emission in half.
    li $v0, 4
    la $a0, solar_question
    syscall

    # Gets the user input as an integer so that the branching is easier 
    li $v0, 5
    syscall
    move $s0, $v0            # Save solar panel choice
    
    # If the user inputs something other than 1 or 2, then the code goes to the invalid_solar label(error checking). We don't jump anywhere else because this is just a flag for if we divide by 2 or not.
    blt $s0, 1, invalid_solar
    bgt $s0, 2, invalid_solar

light_bulb_label:
    # Question 2: Light Bulb Type
    # Asks the user if the have LED or incandescent light bulbs since they have a different emission factor.
    li $v0, 4
    la $a0, bulb_question
    syscall

    # Gets the user input as an integer so that the branching is easier 
    li $v0, 5
    syscall
    move $s1, $v0            # Save light bulb type. Need to save for later calculations.
    
    # If the user inputs something other than 1 or 2, then the code goes to the invalid_light label(error checking). We don't jump anywhere else because this is just a flag to know which emission factor to load.
    blt $s1, 1, invalid_light
    bgt $s1, 2, invalid_light
    
light_hours_prompt:
    # Question 3: Light Usage Hours (Allow 0-24)
    # Asks the user how many hours they have their lights on per day so that we can do the hours times the emission factor for the lights part of the total emission.
    li $v0, 4
    la $a0, light_hours_question
    syscall
    
    # Gets the hours as a word so that it's easier to check if the input is valid even though we'll have to convert it to a double later for the calculation
    li $v0, 5
    syscall
    move $s2, $v0               # Save valid light usage hours. Need to save for later calculations.
    
    # If the user inputs an integer that's less than 0 or greater than 24, then the code will jump to invalid_hours since there's only 24 hours in a day(error checking).
    blt $s2, 0, invalid_light_hours   # Check if input is below 0
    bgt $s2, 24, invalid_light_hours  # Check if input is above 24

heater_label:
    # Question 4: Heater or Blanket
    # Asks the user if they use a heater or a blanket since the heater has an emission but a blanket does not.
    li $v0, 4
    la $a0, heater_or_blanket_question
    syscall
    
    # Gets the user choice 
    li $v0, 5
    syscall
    move $s3, $v0               # Save heating choice. Need to save for later calculation.
    
    # If the user inputs anything other thn 1 or 2 then the code jumps to invalid_heater(error checking).
    blt $s3, 1, invalid_heater
    bgt $s3, 2, invalid_heater
    
    # if the user inputs heater
    beq $s3, 1, heater_hours_prompt
    
    # Calculate Light Bulb Emissions from light_hours_prompt after error checking.
    beq $s1, 1, use_led         # If LED
    beq $s1, 2, use_incandescent # If Incandescent

heater_hours_prompt:
	# Question 5: Heater Usage Hours (0-24)
	# Asks the user how many hours they have their heater on per day so that we can do the hours times the emission factor for the heater part of the total emission.
 	li $v0, 4
    	la $a0, heater_hours_question
    	syscall
    
   	# Gets the hours as a word so that it's easier to check if the input is valid even though we'll have to convert it to a double later for the calculation
    	li $v0, 5
    	syscall
    
    	# If the user inputs an integer that's less than 0 or greater than 24, then the code will jump to invalid_hours since there's only 24 hours in a day(error checking).
    	blt $v0, 0, invalid_heater_hours   # Check if input is below 0
    	bgt $v0, 24, invalid_heater_hours  # Check if input is above 24
    	move $s4, $v0               # Save valid heater usage hours
    	
use_led:
    # If the user said that they have LED light bulbs then we go here, load the emission factor, and sends it to the calculation label
    l.d $f0, ef_led             # Load LED emission factor
    j calculate_light_emissions

use_incandescent:
    # If the user said that they have incandescent light bulbs then we go here, load the emission factor, and sends it to the lights calculation label for consistency's sake.
    l.d $f0, ef_incandescent    # Load incandescent emission factor
    j calculate_light_emissions

calculate_light_emissions:
    # Convert the hours from word to double so that we can use them in the calculation
    mtc1 $s2, $f4               # Move hours to floating-point register
    cvt.d.w $f4, $f4            # Convert hours to double
    mul.d $f6, $f0, $f4         # Total light bulb emissions = EF * hours

    # Calculate Heater or Blanket Emissions
    beq $s3, 1, use_heater      # If Heater
    beq $s3, 2, use_blanket     # If Blanket

use_heater:
    mtc1 $s4, $f16               # Move hours to floating-point register
    cvt.d.w $f16, $f16            # Convert hours to double

    # Loads the emission factor for if the user chose the heater for the calculations and jumps to the sum calculation label
    l.d $f0, ef_heater          # Load heater emission factor
    mul.d $f8, $f0, $f16         # Total heater emissions = EF * hours
    j sum_energy_emissions

use_blanket:
    # Loads the emission factor for if the user chose the blanket(0) for the calculations and jumps to the sum calculation label
    l.d $f8, ef_blanket         # Load blanket emission factor (0 emissions)
    j sum_energy_emissions

invalid_solar:
	# If user inputs something other than one of the choices it says that the choice is invaild and jumps back to the question(error checking).
	li $v0, 4
    	la $a0, invalid_user_input
    	syscall
    	
    	j solar_label

invalid_light:
	# If user inputs something other than one of the choices it says that the choice is invaild and jumps back to the question(error checking).
	li $v0, 4
    	la $a0, invalid_user_input
    	syscall
    	
    	j light_bulb_label

invalid_heater:
	# If user inputs something other than one of the choices it says that the choice is invaild and jumps back to the question(error checking).
	li $v0, 4
    	la $a0, invalid_user_input
    	syscall
    	
    	j heater_label    	
    	
invalid_light_hours:
    	# Tells the user that they entered an invalid input and send them back to enter the hours again(error checking).
    	li $v0, 4
    	la $a0, invalid_hours_msg   # Display invalid input message
    	syscall
    	j light_hours_prompt        # Retry the question


invalid_heater_hours:
    	# Tells the user that they entered an invalid input and send them back to enter the hours again(error checking).
    	li $v0, 4
    	la $a0, invalid_hours_msg   # Display invalid input message
    	syscall
    	j heater_hours_prompt        # Retry the question

sum_energy_emissions:
	# Checks if the user has solar because that affects the calculations
    	beq $s0, 1, use_solar	# If the user has solar
    	beq $s0, 2, no_solar	# If the user does not have solar
    
use_solar:
	# The user has solar so the energy emission for the weekday is (light + heater/blanket)/2
    	l.d $f14, solar_factor	# Load the solar factor
    	add.d $f10, $f6, $f8    # energy emissions = light + heater/blanket
    	div.d $f10, $f10, $f14	# Divide by 2 for the solar
    	j multiply_five
    	
no_solar:
	# The user does not have solar so the total energy emission for the weekday is just the light + heater/blanket
    	add.d $f10, $f6, $f8        # energy emissions = light + heater/blanket
    	j multiply_five

multiply_five:

    # Multiply by 5 for weekday total
    li $s4, 5
    mtc1 $s4, $f4
    cvt.d.w $f4, $f4
    mul.d $f0, $f10, $f4       # Weekly energy emissions
    
    # Prints the weekday energy results
    li $v0, 4
    la $a0, weekday_energy_result
    syscall

    li $v0, 3
    mov.d $f12, $f0          # Load emissions for printing
    syscall

    # Restore stack
    lw $fp, 0($sp)        	# Restore frame pointer  
    lw $ra, 4($sp)        	# Restore return address  
    addiu $sp, $sp, 8      	# Deallocate stack space 
    jr $ra             		# Return to caller
