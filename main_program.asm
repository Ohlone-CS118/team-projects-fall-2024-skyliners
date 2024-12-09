# Main file
# Contributors: Andy, Emma, Ni Linn. 12/02/2024-12/08/2024
# Purpose: Pulls in all the files/subrountines to ask the user questions, calculate, and display the user's carbon emissions.
# contains all the data and the main function

# When the user has an invaild input
.globl invalid_user_input

# msgs_and_sound
.globl less_half_msg
.globl half_and_equal_msg
.globl equal_half_msg
.globl equal_msg
.globl more_than_msg
.globl US_average
.globl half_average
   
# Text files
.globl energy1
.globl energy2
.globl transport1
.globl transport2
.globl waste1
.globl waste2
.globl warning
.globl feedback
.globl buffer

# Weekday waste
.globl lunch_question
.globl notes_question
.globl waste_hours
.globl waste_pages
.globl waste_invalid_hours_msg
.globl waste_invalid_pages_msg
.globl weekday_waste_result

.globl ef_reusable
.globl ef_aluminum 
.globl ef_plastic 
.globl ef_pre_packaged
.globl ef_digital_device
.globl ef_recycled_paper
.globl ef_regular_notebook

# weekday transportation
.globl main_question
.globl transport_question
.globl miles_question
.globl carpool_question
.globl weekday_transportation_result
.globl main_question_invalid_msg
.globl transport_question_invalid_msg
.globl miles_question_invalid_msg
.globl carpool_question_invalid_msg

.globl ef_bus
.globl ef_car
.globl ef_carpool
.globl zero_value
.globl hours_day

#weekday energy
.globl solar_question
.globl bulb_question
.globl light_hours_question
.globl invalid_hours_msg
.globl heater_or_blanket_question
.globl heater_hours_question
.globl weekday_energy_result

.globl ef_led
.globl ef_incandescent
.globl ef_heater
.globl ef_blanket
.globl solar_factor

#weekend energy
.globl weekend_energy_main_question
.globl weekend_energy_hours_question
.globl weekend_energy_invalid_hours_msg
.globl weekend_energy_baking_minutes
.globl weekend_enegry_invalid_minutes_msg
.globl weekend_energy_result

.globl ef_movie
.globl ef_gaming
.globl ef_baking

#weekend transportation. the emission factors are the same as weekday
.globl weekend_transportation_main_question
.globl weekend_miles_question
.globl weekend_carpool_question
.globl weekend_transportation_result



.globl PIXEL_SIZE
.globl WIDTH
.globl HEIGHT
.globl DISPLAY

.globl GRAY
.globl WHITE
.globl RED
.globl YELLOW
.globl GREEN
.globl BLUE
.globl BLACK

.globl MAX_NORMALIZED_HEIGHT

# weekend waste
.globl bag_question
.globl gathering_question
.globl food_waste_question
.globl packaging_waste_question
.globl personal_waste_question
.globl result_msg
.globl newline
.globl weekend_waste_result

.globl ef_reusable_bag
.globl ef_paper_bag
.globl ef_plastic_bag
.globl ef_reusable_items
.globl ef_mixed_items
.globl ef_disposable_items
.globl ef_food_waste_none
.globl ef_food_waste_moderate
.globl ef_food_waste_significant
.globl ef_packaging_waste_none
.globl ef_packaging_waste_moderate
.globl ef_packaging_waste_significant
.globl ef_recycled
.globl ef_non_recycled


.data
  # set display to:
#	Pixels width and height to 4x4
#	Display width and height to 256x256
#	Base address = 0x10000000
# This will make our screen width 64x64 (256/4 = 64)
# 64 * 64 * 4 = 16384 required bytes

display:.space 16384

# screen information
PIXEL_SIZE:	.word  4
WIDTH:	.word  64
HEIGHT:	.word  64
DISPLAY:.word  0x10000000

# colors
GRAY:	.word	0x00A0A0A0
WHITE:	.word	0x00FFFFFF
RED:	.word	0x00FF0000
YELLOW:	.word	0x00FFFF00
GREEN:	.word	0x0000FF00
BLUE:	.word	0x000000FF
PURPLE:	.word	0x00FF00FF
BLACK:	.word	0x00000000

# bar graph values
MAX_NORMALIZED_HEIGHT: .double 1
ZERO_DOUBLE: .double 0
AVERAGE_AMERICAN_EMISSION: .double 16000
WEEKS_IN_A_YEAR: .double 52

# Invalid user input
invalid_user_input:	.asciiz "\nInvalid input! Please try again.\n"

# Prompts for weekday waste
lunch_question: 	.asciiz "\n\nHow do you pack your lunch? (1-Reusable container, 2-Aluminum foil, 3-Plastic wrap, 4-Pre-packaged meal): "
notes_question:		.asciiz "\nWhat do you use for notes? (1-Digital device, 2-Recycled paper, 3-Regular notebook): "
waste_hours:		.asciiz "\nHow many hours do you use your digital device?(0-24): "
waste_pages:		.asciiz "\nHow many pages(front and back) do you use? (Enter a number greater or equal to 0): "
waste_invalid_hours_msg: 	.asciiz "\nInvalid input! Please enter a value between 0 and 24."
waste_invalid_pages_msg: 	.asciiz "\nInvalid input! Please enter a value greater than 0."
weekday_waste_result:		.asciiz "\nYour weekday waste emissions represented by black (kg CO2): "

# Prompts for weekday transportation
main_question: .asciiz "\n\nDo you go to (1-School, 2-Work, 3-Both)? "
main_question_invalid_msg: .asciiz "\nInvalid input! Please enter a value between 1 and 3."
transport_question: .asciiz "\nWhat do you take (1-Walk, 2-Bike, 3-Bus/Public Transit, 4-Personal Car, 5-Carpool)? "
transport_question_invalid_msg: .asciiz "\nInvalid input! Please enter a value between 1 and 5."
miles_question: .asciiz "\nHow many miles do you travel daily? "
carpool_question: .asciiz "\nIf carpool, how many people (including yourself)? "
miles_question_invalid_msg: .asciiz "\nInvalid input! Please enter a value greater than 0."
carpool_question_invalid_msg: .asciiz "\nInvalid input! Please enter a value greater than 1."
weekday_transportation_result: .asciiz "\nYour weekday transportation emissions represented by green (kg CO2): "

# Prompts for weekday energy
solar_question: .asciiz "\n\nDo you have solar panels installed? (1-Yes, 2-No): "
bulb_question: .asciiz "\nDo you use LED bulbs or Incandescent bulbs? (1-LED, 2-Incandescent): "
light_hours_question: .asciiz "\nHow many hours do you leave your lights on daily? (0-24): "
invalid_hours_msg: .asciiz "\nInvalid input! Please enter a value between 0 and 24."
heater_or_blanket_question: .asciiz "\nDo you use a heater or just a blanket? (1-Heater, 2-Blanket): "
heater_hours_question: .asciiz "\nHow many hours do you use the heater daily? (0-24): "
weekday_energy_result: .asciiz "\nYour weekday energy emissions represented by yellow (kg CO2): "

# Lets user know bar graphs are resetting
reset_bar_graphs_message:	.asciiz "\n\nNow resetting bar graphs to display new data. Clearing them in 5 seconds...\n"

# Prompts for weekend energy
weekend_energy_main_question:	.asciiz "\n\nDo you spend your weekend (1-Watching Movies on the TV, 2-Gaming on the TV, or 3-Baking)? "
weekend_energy_hours_question:	.asciiz "\nHow many hours? (0-24): "
weekend_energy_invalid_hours_msg: .asciiz "\nInvalid input! Please enter a value between 0 and 24."
weekend_energy_baking_minutes:	.asciiz "\nHow many minutes does the item that you're baking take? (Enter a number starting from 0): "
weekend_enegry_invalid_minutes_msg: .asciiz "\nInvalid input! Please enter a value greater or equal to 0."
weekend_energy_result: .asciiz "\nYour weekend energy emissions represented by yellow (kg CO2): "

# Prompts for weekend transport
weekend_transportation_main_question:	.asciiz "\n\nHow do you travel to leisure activities? (1-Walk, 2-Bike, 3-Bus/Public Transit, 4-Car, 5-Carpool)"
weekend_miles_question:	.asciiz "\nHow many miles do you travel daily? "
weekend_carpool_question: 	.asciiz "\nIf carpool, how many people (including yourself)? "
weekend_transportation_result: .asciiz "\nYour weekend transportation emissions represented by green (kg CO2): "

# Prompts for weekend waste
bag_question: .asciiz "\n\nWhat kind of bags do you use for groceries? (1: Reusable tote, 2: Paper bag, 3: Plastic bag): "
gathering_question: .asciiz "\nAfter hosting a gathering, did you use reusable or disposable items? (1: Reusable items, 2: Mixed items, 3: Disposable items): "
food_waste_question: .asciiz "\nHow much food waste did you generate during the weekend? (1: None, 2: Moderate, 3: Significant): "
packaging_waste_question: .asciiz "\nHow much packaging waste (e.g., boxes, plastic wraps) did you generate? (1: None, 2: Moderate, 3: Significant): "
personal_waste_question: .asciiz "\nDid you separate your recyclable waste? (1: Yes, 2: No): "
result_msg: .asciiz "\nYour total weekend CO2�� emissions are: "
newline: .asciiz "\n"
weekend_waste_result: .asciiz "\nYour weekend waste emissions represented by black (kg CO2): "

# Prompts for total CO2
weekday_total_result:	.asciiz "\nYour weekday total emissions represented by blue (kg CO2) is now: "
weekend_total_result:	.asciiz "\nYour weekend total emissions represented by blue (kg CO2) is now: "
week_total_result:	.asciiz "\nYour week total emissions (kg CO2): "
yearly_projection_result:	.asciiz "\nYour yearly projected emissions represented by blue (kg CO2): "
average_american_result:	.asciiz "\nThis is compared to the average American yearly emission represented in purple which is 16 tons (16000 kg CO2)"

# Emission factors (double-precision)
ef_bus: .double 0.1            # Public transit (kg CO2 per mile)
ef_car: .double 0.3            # Personal car (kg CO2 per mile)
ef_carpool: .double 0.3        # Carpool (kg CO2 per mile, adjusted by passengers)
zero_value: .double 0.0        # Non-motorized transport

ef_led: .double 0.01           # LED light bulb (kg CO2 per hour)
ef_incandescent: .double 0.05  # Incandescent bulb (kg CO2 per hour)
ef_heater: .double 1.5         # Heater (kg CO2 per hour)
ef_blanket: .double 0.0        # Blanket (no emissions)
solar_factor: .double 2.0      # Halfs the emission if has solar
hours_day: .double 24.0

ef_reusable: .double 0.03
ef_aluminum: .double 0.01
ef_plastic: .double 0.04
ef_pre_packaged: .double 2.5
ef_digital_device: .double 0.02 # per hour
ef_recycled_paper: .double 0.01 # per page
ef_regular_notebook: .double 0.05 # per page

ef_movie: .double 0.08          # Watching movies on the TV (kg CO2 per hour)
ef_gaming: .double 0.16  	# Gaming on the TV (kg CO2 per hour)(emission from TV + from gaming system(0.08))
ef_baking: .double 0.02        	# Baking (kg CO2 per minute)


ef_reusable_bag: .double 0.05
ef_paper_bag: .double 0.15
ef_plastic_bag: .double 0.03
ef_reusable_items: .double 0.08
ef_mixed_items: .double 0.20
ef_disposable_items: .double 0.40
ef_food_waste_none: .double 0.0
ef_food_waste_moderate: .double 5.0
ef_food_waste_significant: .double 10.0
ef_packaging_waste_none: .double 0.0
ef_packaging_waste_moderate: .double 3.0
ef_packaging_waste_significant: .double 6.0
ef_recycled: .double 1.0
ef_non_recycled: .double 2.0

# Text files. Different paths for each person
energy1:	.asciiz "./team-projects-fall-2024-skyliners/text_files/EnergyFact1.txt"
energy2:	.asciiz "./team-projects-fall-2024-skyliners/text_files/EnergyFact2.txt"
transport1:	.asciiz "./team-projects-fall-2024-skyliners/text_files/transportationFact1.txt"
transport2:	.asciiz "./team-projects-fall-2024-skyliners/text_files/transportationFact2.txt"
waste1:		.asciiz "./team-projects-fall-2024-skyliners/text_files/WasteFact1.txt"
waste2:		.asciiz "./team-projects-fall-2024-skyliners/text_files/WasteFact2.txt"
warning:	.asciiz "./team-projects-fall-2024-skyliners/text_files/warning.txt"
feedback:	.asciiz "./team-projects-fall-2024-skyliners/text_files/feedback.txt"
buffer:		.space 1024 

# msgs_and_sound values
less_half_msg:		.asciiz "\nCongrats! Your yearly projection of carbon emission is less than half of the U.S. average emission!"
half_and_equal_msg:	.asciiz "\nYour yearly projection of carbon emission is less than the U.S. average emission but more than half." 
equal_half_msg:		.asciiz "\nYour yearly projection of carbon emission is exactly half of the U.S. average emission. That's kind of impressive."
equal_msg:		.asciiz "\nYour yearly projection of carbon emission is exactly the U.S. average emission. You can do better."
more_than_msg:		.asciiz "\nYour yearly projection of carbon emission is more than the U.S. average emission. What are you doing with your life???"
US_average:		.double 16000
half_average:		.double 8000

.globl main
.text



main:
# set the frame pointer to the beginning of the stack
    	move $fp, $sp   	# Set the frame pointer to the stack pointer
    	
    	la $a0, warning		# set path
    	la $a1, buffer		# set buffer
    	jal readFromFile
    
    	li $v0, 4
    	la $a0, buffer
	syscall   	
	
	li $v0, 11		# Newline to seperate the warning from the rest of the code
	la $a0, 10
	syscall
	
	li $v0, 11		# Newline to seperate the warning from the rest of the code
	la $a0, 10
	syscall
    
	la $a0, WHITE		# set white as the background color
	lw $a0, 0($a0)		
	jal backgroundColor	# color the background
	
	
	li $a0, 3        # set first bar starting x position to x = 3
	li $a1, 15        # set first bar starting x position to x = 15
	li $a2, 64		# set bar height to 64
	la $a3, GRAY		# set color to gray
	lw $a3, 0($a3)
	jal drawBar		# draw bar

	li $a0, 18        # set second bar starting x position to x = 18
    	li $a1, 30        # set second bar starting x position to x = 30
    	li $a2, 64		# set bar height to 64
	la $a3, GRAY		# set color to gray
	lw $a3, 0($a3)
	jal drawBar		# draw bar
	
	
	li $a0, 33        # set third bar starting x position to x = 33
 	li $a1, 45        # set third bar starting x position to x = 45		
	li $a2, 64		# set bar height to 64
	la $a3, GRAY		# set color to gray
	lw $a3, 0($a3)
	jal drawBar		# draw bar
	
	li $a0, 48        # set fourth bar starting x position to x = 48
	li $a1, 60        # set fourth bar starting x position to x = 60
	li $a2, 64		# set bar height to 64
	la $a3, GRAY		# set color to gray
	lw $a3, 0($a3)
	jal drawBar		# draw bar
	

	
	
    # Input weekday transportation data
    	move $t6, $a0		# Save value in $a0
    	move $t7, $a1		# Save value in $a1
    
    	la $a0, transport1		# set path
    	la $a1, buffer		# set buffer
    	jal readFromFile
    
    	li $v0, 4
    	la $a0, buffer
	syscall
	
	move $a0, $t6		# Reset $a0
	move $a1, $t7		# Reset $a1
	
    	jal handle_weekday_transportation
    
    
    # Normalize emissions for calculated weekday transportation
	jal normalize_emission_weekday  # Normalize the emission value in $f0
	move $t4, $v0           # Save normalized height in $t4

	li $a0, 3        # set first bar starting x position to x = 3
 	li $a1, 15        # set first bar starting x position to x = 15
 	move $a2, $t4        # set first bar height to normalized height
    	la $a3, GREEN        # set color to green
    	lw $a3, 0($a3)
	jal drawBar		# draw bar
    
    
    
    	mov.d $f24, $f0		# Store the weekday transportation in $f24 for a running total
 
       mov.d $f0, $f24	# move current value of total in $f24 to $f0 to draw total bar    
           # Normalize total emissions for weekdays
	jal normalize_emission_weekday  # Normalize the emission value in $f0
	move $t4, $v0           # Save normalized height in $t4

	li $a0, 48        # set foourth bar starting x position to x = 48
 	li $a1, 60        # set fourth bar starting x position to x = 60
 	move $a2, $t4        # set bar height to normalized height
    	la $a3, BLUE        # set color to blue
    	lw $a3, 0($a3)
	jal drawBar		# draw bar
	
	
	li $v0, 4
        la $a0, weekday_total_result	# load weekday total result string
        syscall
    
    	li $v0, 3
    	mov.d $f12, $f24	# load weekday total result double
    	syscall
	
     # Input weekday energy data
     	move $t6, $a0		# Save value in $a0
    	move $t7, $a1		# Save value in $a1
    	
    	li $v0, 11		# Newline to seperate the fact from the prompts
	la $a0, 10
	syscall
	
	li $v0, 11		# Newline to seperate the fact from the prompts
	la $a0, 10
	syscall
    
    	la $a0, energy1		# set path
    	la $a1, buffer		# set buffer
    	jal readFromFile
    
    	li $v0, 4
    	la $a0, buffer
	syscall
	
	move $a0, $t6		# Reset $a0
	move $a1, $t7		# Reset $a1
	
    	jal handle_weekday_energy
    	add.d $f24, $f24, $f0	# Store the weekday energy in $f24 for a running total
    
       # Normalize emissions for calculated weekday energy
	jal normalize_emission_weekday  # Normalize the emission value in $f0
	move $t4, $v0           # Save normalized height in $t4

	li $a0, 18        # set second bar starting x position to x = 18
 	li $a1, 30        # set second bar starting x position to x = 30
 	move $a2, $t4        # set bar height to normalized height
    	la $a3, YELLOW        # set color to yellow
    	lw $a3, 0($a3)
	jal drawBar		# draw bar
    
    
    mov.d $f0, $f24	# move current value of total in $f24 to $f0 to draw total bar  
    
           # Normalize total emissions for weekdays
	jal normalize_emission_weekday  # Normalize the emission value in $f0
	move $t4, $v0           # Save normalized height in $t4

	li $a0, 48        # set foourth bar starting x position to x = 48
 	li $a1, 60        # set fourth bar starting x position to x = 60
 	move $a2, $t4        # set bar height to normalized height
    	la $a3, BLUE        # set color to blue
    	lw $a3, 0($a3)
	jal drawBar		# draw bar
    
    
    # display running total
    	li $v0, 4
        la $a0, weekday_total_result	# load weekday total result string
        syscall
    
    	li $v0, 3
    	mov.d $f12, $f24	# load weekday total result double
    	syscall
    
    # Input weekly waste data and calculate
    	move $t6, $a0		# Save value in $a0
    	move $t7, $a1		# Save value in $a1
    	
    	li $v0, 11		# Newline to seperate the fact from the prompts
	la $a0, 10
	syscall
	
	li $v0, 11		# Newline to seperate the fact from the prompts
	la $a0, 10
	syscall
    
    	la $a0, waste1		# set path
    	la $a1, buffer		# set buffer
    	jal readFromFile
    
    	li $v0, 4
    	la $a0, buffer
	syscall
	
	move $a0, $t6		# Reset $a0
	move $a1, $t7		# Reset $a1
    
   	jal handle_weekday_waste
   	add.d $f24, $f24, $f0	# Store the weekday waste in $f26 for a running total
    
    
    

       # Normalize emissions for calculated weekday waste
	jal normalize_emission_weekday  # Normalize the emission value in $f0
	move $t4, $v0           # Save normalized height in $t4

	li $a0, 33        # set second bar starting x position to x = 33
 	li $a1, 45        # set second bar starting x position to x = 45
 	move $a2, $t4        # set bar height to normalized height
    	la $a3, BLACK        # set color to black
    	lw $a3, 0($a3)
	jal drawBar		# draw bar
    
    
    	mov.d $f0, $f24	# move current value of total in $f24 to $f0 to draw total bar  
    
           # Normalize total emissions for weekdays
	jal normalize_emission_weekday  # Normalize the emission value in $f0
	move $t4, $v0           # Save normalized height in $t4

	li $a0, 48        # set foourth bar starting x position to x = 48
 	li $a1, 60        # set fourth bar starting x position to x = 60
 	move $a2, $t4        # set bar height to normalized height
    	la $a3, BLUE        # set color to blue
    	lw $a3, 0($a3)
	jal drawBar		# draw bar
    
    
        # display running total
    	li $v0, 4
        la $a0, weekday_total_result	# load weekday total result string
        syscall
    
    	li $v0, 3
    	mov.d $f12, $f24	# load weekday total result double
    	syscall
    
    	# warning message
    	li $v0, 4
    	la $a0, reset_bar_graphs_message	# display reset bars message
    	syscall
    
    	li $v0, 32
    	la $a0, 5000	# sleep for 5 seconds
    	syscall
    
    
    
    
    # reset bars
    	li $a0, 3        # set first bar starting x position to x = 3
	li $a1, 15        # set first bar starting x position to x = 15
	li $a2, 64		# set bar height to 64
	la $a3, GRAY		# set color to gray
	lw $a3, 0($a3)
	jal drawBar		# draw bar

	li $a0, 18        # set second bar starting x position to x = 18
    	li $a1, 30        # set second bar starting x position to x = 30
    	li $a2, 64		# set bar height to 64
	la $a3, GRAY		# set color to gray
	lw $a3, 0($a3)
	jal drawBar		# draw bar
	
	
	li $a0, 33        # set third bar starting x position to x = 33
 	li $a1, 45        # set third bar starting x position to x = 45		
	li $a2, 64		# set bar height to 64
	la $a3, GRAY		# set color to gray
	lw $a3, 0($a3)
	jal drawBar		# draw bar
	
	li $a0, 48        # set fourth bar starting x position to x = 48
	li $a1, 60        # set fourth bar starting x position to x = 60
	li $a2, 64		# set bar height to 64
	la $a3, GRAY		# set color to gray
	lw $a3, 0($a3)
	jal drawBar		# draw bar
	
    
    	mov.d $f22, $f24	# move current total to $f22 to save and then reset total to get total for weekend
    
    	la $t0, ZERO_DOUBLE	
    	ldc1 $f24, 0($t0)	# load zero into f24
   
    
    # Input weekend energy data
    	move $t6, $a0		# Save value in $a0
    	move $t7, $a1		# Save value in $a1
    	
    	li $v0, 11		# Newline to seperate the fact from the prompts
	la $a0, 10
	syscall
    
    	la $a0, energy2		# set path
    	la $a1, buffer		# set buffer
    	jal readFromFile
    
    	li $v0, 4
    	la $a0, buffer
	syscall
	
	move $a0, $t6		# Reset $a0
	move $a1, $t7		# Reset $a1
    	jal handle_weekend_energy
    	add.d $f24, $f24, $f0	# Store the weekday energy in $f24 for a running total
    
    
    
        
    # Normalize emissions for calculated weekend energy
	jal normalize_emission_weekend # Normalize the emission value in $f0
	move $t4, $v0           # Save normalized height in $t4

	li $a0, 3        # set first bar starting x position to x = 3
 	li $a1, 15        # set first bar starting x position to x = 15
 	move $a2, $t4        # set first bar height to normalized height
    	la $a3, YELLOW        # set color to yellow
    	lw $a3, 0($a3)
	jal drawBar		# draw bar
    
    
    
        mov.d $f0, $f24	# move current value of total in $f24 to $f0 to draw total bar    
           # Normalize total emissions for weekends
	jal normalize_emission_weekend  # Normalize the emission value in $f0
	move $t4, $v0           # Save normalized height in $t4

	li $a0, 48        # set foourth bar starting x position to x = 48
 	li $a1, 60        # set fourth bar starting x position to x = 60
 	move $a2, $t4        # set bar height to normalized height
    	la $a3, BLUE        # set color to blue
    	lw $a3, 0($a3)
	jal drawBar		# draw bar
    
    
        # display weekend running total
        li $v0, 4
        la $a0, weekend_total_result	# load weekend total result string
        syscall
    
    	li $v0, 3
    	mov.d $f12, $f24	# load weekend total result double
    	syscall
    
    
    # Input weekend transportation data
    	move $t6, $a0		# Save value in $a0
    	move $t7, $a1		# Save value in $a1
    	
    	li $v0, 11		# Newline to seperate the fact from the prompts
	la $a0, 10
	syscall
	
	li $v0, 11		# Newline to seperate the fact from the prompts
	la $a0, 10
	syscall
    
    	la $a0, transport2		# set path
    	la $a1, buffer		# set buffer
    	jal readFromFile
    
    	li $v0, 4
    	la $a0, buffer
	syscall
	
	move $a0, $t6		# Reset $a0
	move $a1, $t7		# Reset $a1
    
    	jal handle_weekend_transportation
    	add.d $f24, $f24, $f0	# Store the weekday energy in $f24 for a running total
    
    
      # Normalize emissions for calculated weekend  tranportation
	jal normalize_emission_weekend  # Normalize the emission value in $f0
	move $t4, $v0           # Save normalized height in $t4

	li $a0, 18        # set second bar starting x position to x = 18
 	li $a1, 30        # set second bar starting x position to x = 30
 	move $a2, $t4        # set bar height to normalized height
    	la $a3, GREEN        # set color to green
    	lw $a3, 0($a3)
	jal drawBar		# draw bar
    
    
    mov.d $f0, $f24	# move current value of total in $f24 to $f0 to draw total bar  
    
           # Normalize total emissions for weekends
	jal normalize_emission_weekend  # Normalize the emission value in $f0
	move $t4, $v0           # Save normalized height in $t4

	li $a0, 48        # set foourth bar starting x position to x = 48
 	li $a1, 60        # set fourth bar starting x position to x = 60
 	move $a2, $t4        # set bar height to normalized height
    	la $a3, BLUE        # set color to blue
    	lw $a3, 0($a3)
	jal drawBar		# draw bar

    	# display weekend running total
        li $v0, 4
        la $a0, weekend_total_result	# load weekend total result string
        syscall
    
    	li $v0, 3
    	mov.d $f12, $f24	# load weekend total result double
    	syscall

# Input weekend waste data

	move $t6, $a0		# Save value in $a0
    	move $t7, $a1		# Save value in $a1
    
    	li $v0, 11		# Newline to seperate the fact from the prompts
	la $a0, 10
	syscall
	
	li $v0, 11		# Newline to seperate the fact from the prompts
	la $a0, 10
	syscall
    
    	la $a0, waste2		# set path
    	la $a1, buffer		# set buffer
    	jal readFromFile
    
    	li $v0, 4
    	la $a0, buffer
	syscall
	
	move $a0, $t6		# Reset $a0
	move $a1, $t7		# Reset $a1
	
    	jal handle_weekend_waste
    	add.d $f24, $f24, $f0	# Store the weekend energy in $f24 for a running total

 # Normalize emissions for calculated weekend waste
	jal normalize_emission_weekend  # Normalize the emission value in $f0
	move $t4, $v0           # Save normalized height in $t4

	li $a0, 33        # set second bar starting x position to x = 33
 	li $a1, 45        # set second bar starting x position to x = 45
 	move $a2, $t4        # set bar height to normalized height
    	la $a3, BLACK        # set color to black
    	lw $a3, 0($a3)
	jal drawBar		# draw bar
    
    
    	mov.d $f0, $f24	# move current value of total in $f24 to $f0 to draw total bar  
    
           # Normalize total emissions for weekends
	jal normalize_emission_weekend  # Normalize the emission value in $f0
	move $t4, $v0           # Save normalized height in $t4

	li $a0, 48        # set fourth bar starting x position to x = 48
 	li $a1, 60        # set fourth bar starting x position to x = 60
 	move $a2, $t4        # set bar height to normalized height
    	la $a3, BLUE        # set color to blue
    	lw $a3, 0($a3)
	jal drawBar		# draw bar

    	# display weekend running total
        li $v0, 4
        la $a0, weekend_total_result	# load weekend total result string
        syscall
    
    	li $v0, 3
    	mov.d $f12, $f24	# load weekend total result double
    	syscall
    
      # warning message
    	li $v0, 4
    	la $a0, reset_bar_graphs_message	# display reset bars message
    	syscall
    
    	li $v0, 32
    	la $a0, 5000	# sleep for 5 seconds
    	syscall
    
   	la $a0, WHITE		# set white as the background color
	lw $a0, 0($a0)		
	jal backgroundColor	# color the background
	 
    
    
    # reset bars
    	li $a0, 2        # set first bar starting x position to x = 2
	li $a1, 30        # set first bar starting x position to x = 30
	li $a2, 64		# set bar height to 64
	la $a3, GRAY		# set color to gray
	lw $a3, 0($a3)
	jal drawBar		# draw bar

	li $a0, 33        # set second bar starting x position to x = 33
    	li $a1, 61        # set second bar starting x position to x = 61
    	li $a2, 64		# set bar height to 64
	la $a3, GRAY		# set color to gray
	lw $a3, 0($a3)
	jal drawBar		# draw bar
	
	
	# calculates weekly total result
	add.d $f0, $f22, $f24	# set weekly total emissions in $f0
	
	# Print weekly total result string
	li $v0, 4
        la $a0, week_total_result	# load week total result string
        syscall
    
    	li $v0, 3
    	mov.d $f12, $f0	# load week total result double
    	syscall
    
	
	# Calculate the yearly projection
	la $t0, WEEKS_IN_A_YEAR	
    	ldc1 $f20, 0($t0)	# load 52 into f20
    	mul.d $f0, $f20, $f0
    
    	# print yearly projection result
    	li $v0, 4
        la $a0, yearly_projection_result	# load yearly projection result string
        syscall
    
    	li $v0, 3
    	mov.d $f12, $f0	# load yearly projection result double
    	syscall
    
	mov.d $f18, $f12		# Set $f18 to the yearly projection result so that we can preform branching
	
	# Print average American result
        li $v0, 4
        la $a0, average_american_result	# load average american string
        syscall

        # Normalize total emissions
	jal normalize_emission_total  # Normalize the emission value in $f0
	move $t4, $v0           # Save normalized height in $t4

	# Draw user's yearly projected bar
	li $a0, 2        # set fourth bar starting x position to x = 2
 	li $a1, 30        # set fourth bar starting x position to x = 20
 	move $a2, $t4        # set bar height to normalized height
    	la $a3, BLUE        # set color to blue
    	lw $a3, 0($a3)
	jal drawBar		# draw bar
       
        # loading average American emission to be normalized   	
    	la $t1, AVERAGE_AMERICAN_EMISSION	
    	ldc1 $f0, 0($t1)	# load 16000 into f0
   
        # Normalize total emissions
	jal normalize_emission_total  # Normalize the emission value in $f0
	move $t4, $v0           # Save normalized height in $t4

	# draw average American yearly emission
	li $a0, 33        # set fourth bar starting x position to x = 33
 	li $a1, 61        # set fourth bar starting x position to x = 61
 	move $a2, $t4        # set bar height to normalized height
    	la $a3, PURPLE        # set color to blue
    	lw $a3, 0($a3)
	jal drawBar		# draw bar 
  
  	move $t6, $a0		# Save value in $a0
    	move $t7, $a1		# Save value in $a1
  
	jal msgs		# Go to the msgs subroutine
    	
    	li $v0, 11		# Newline to seperate the feedback from the projection msg
	la $a0, 10
	syscall
	
	li $v0, 11		# Newline to seperate the feedback from the projection msg
	la $a0, 10
	syscall
    
    	la $a0, feedback		# set path
    	la $a1, buffer		# set buffer
    	jal readFromFile
    
    	li $v0, 4
    	la $a0, buffer
	syscall
	
	move $a0, $t6		# Reset $a0
	move $a1, $t7		# Reset $a1
        
    	# Exit program
    	li $v0, 10
    	syscall
