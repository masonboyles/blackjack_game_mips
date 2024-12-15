.eqv DIAMOND 0
.eqv HEART 1
.eqv SPADE 2
.eqv CLUBS 3
.eqv KING 4
.eqv ACE 5
.eqv TWO 6
.eqv THREE 7
.eqv FOUR 8
.eqv FIVE 9
.eqv SIX 10
.eqv SEVEN 11
.eqv EIGHT 12
.eqv NINE 13
.eqv TEN 14
.eqv JACK 15
.eqv QUEEN 16
.eqv WHITE 17
.eqv BLACK 18
.eqv BACKGROUND 19
.eqv CRY 32

.data 0x10010000

	player_suits:     # 10 integers for player suits
		.word 0x0, 0x0, 0x0, 0x0, 0x0
		.word 0x0, 0x0, 0x0, 0x0, 0x0
	player_values:     # 10 integers for player values
		.word 0x0, 0x0, 0x0, 0x0, 0x0
		.word 0x0, 0x0, 0x0, 0x0, 0x0
	dealer_suits:     # 10 integers for dealer suits
		.word 0x0, 0x0, 0x0, 0x0, 0x0
		.word 0x0, 0x0, 0x0, 0x0, 0x0
	dealer_values:	  # 10 integers for dealer values
		.word 0x0, 0x0, 0x0, 0x0, 0x0
		.word 0x0, 0x0, 0x0, 0x0, 0x0
	seed: .word 12345  	       # Initial seed value

.text 0x00400000

.globl main

main:
	lui     $sp, 0x1001         # Initialize stack pointer to the 1024th location above start of data
    	ori     $sp, $sp, 0x1000    # top of the stack will be one word below
                                #   because $sp is decremented first.
    	addi    $fp, $sp, -4        # Set $fp to the start of main's stack frame
	##### TODO: PRINT TEXT SAYING TO BUY IN: ##########
	add $s0, $0, $0 	# bank = 0
	addi $s5, $0, 11 	#S5 will hold 12 to check if key has been released
	
while_get_bank:
	jal get_key
	add $s0, $v0, $0
	beq $s0, $0, while_get_bank
	addi $a0, $0, 100
	jal pause
	
while_playing:
	
	########END IF BANK <= 0#######
	slt $t2, $0, $s0
	beq $t2, $0, end_game
	
	
	jal clear_board		# Calling Clear Board
	
	add $a0, $s0, $0
	
	jal put_leds		# Caliing put_leds to show the bank
	
	add $t1, $0, $0		#t1 will store blackjack boolean
	
	##### TODO: PRINT TEXT SAYING TO PLACE YOUR WAGER: ##########
	
	add $s1, $0, $0 	# wager = 0
	
while_get_wager:
	jal get_key
	add $s1, $v0, $0
	
	beq $s1, $0, while_get_wager
	addi $a0, $0, 100
	jal pause

	#######PRINTING OUT THE WAGER
	addi $a0, $s1, 32
	addi $a1, $0, 37
	addi $a2, $0, 28
	jal putChar_atXY

	#addi $t3, $0, 12###########LOGIC FOR PRESSING Q TO END###########
	#beq $t3, $t2 end
	
	addi $s3, $0, 2 	# player_hand_size = 2
	addi $s4, $0, 1		# dealer_hand_size = 1
	
deal_cards:
	addi $sp, $sp, -4  	#
    	sw $t1, 0($sp)         # Save $t1

    
    	# Load 12 into a0 and get random cards
    	addi $a0, $0, 12
    	
    	jal generate_random_number
    	sw $v0, player_values($0)
    	
    	
    	jal generate_random_number
    	sw $v0, dealer_values($0)
    	
    	jal generate_random_number
    	addi $t8, $0, 4
    	sw $v0, player_values($t8)
    	
    	# Load 3 into a0 to get random suits
    	addi $a0, $0, 3
    	
    	jal generate_random_number
    	sw $v0, player_suits($0)
    	
    	
    	jal generate_random_number
    	sw $v0, player_suits($t8)
    	
    	
    	jal generate_random_number
    	sw $v0, dealer_suits($0)
    	
    	
    	#PRINT THE DEALER AND TWO PLAYER CARDS
    	lw $a0, dealer_suits($0)
    	lw $a1, dealer_values($0)
    	addi $a2, $0, 3
    	addi $a3, $0, 5
    	jal print_card
    	
    	addi $a0, $0, 100
    	jal pause
    	
    	lw $a0, player_suits($0)
    	lw $a1, player_values($0)
    	addi $a2, $0, 3
    	addi $a3, $0, 12
    	jal print_card
    	
    	addi $a0, $0, 100
    	jal pause
    	
    	addi $t8, $0, 4
    	lw $a0, player_suits($t8)
    	lw $a1, player_values($t8)
    	addi $a2, $0, 9
    	addi $a3, $0, 12
    	jal print_card
    	
    	addi $a0, $0, 100
    	jal pause

    	   		       #
  
    	lw $t1, 0($sp)         # Restore $t1
    	addi $sp, $sp, 4
    	
    	
    	addi $sp, $sp, -4  	#
    	sw $t1, 0($sp)         # Save $t1

    	
    	la $a0, player_values
    	add $a1, $s3, $0
    	jal sum_of_hand
    	
    	
    	lw $t1, 0($sp)         # Restore $t1
    	addi $sp, $sp, 4
    	
    	addi $t5, $0, 21
    	beq $v0, $t5, blackjack
    	
	
	add $t7, $0, $0		# decisioni = 0
deciding:
	addi $sp, $sp, -4  	#
    	sw $t1, 0($sp)         # Save $t1
    	jal get_key
    	lw $t1, 0($sp)         # Restore $t1
    	addi $sp, $sp, 4
    	
    	add $t7, $v0, $0
    	
    	jal get_accelX
    	
    	add $t8, $0, $0
    	addi $t6, $0, 150
    	slt $t8, $v0, $t6
    	
    	bne $t8, $0, hitting
    	
    	add $t8, $0, $0
    	addi $t6, $0, 350
    	slt $t8, $t6, $v0
    	
    	bne $t8, $0, dealer_going
    	
    	
    	beq $t7, $0, deciding	#if decision hasnt been made, keep looping until it is
    	
    	addi $a0, $0, 100
	jal pause
	
    	addi $t8, $0, 10
    	beq $t7, $t8, hitting
    	
dealer_going:
	add $t9, $0, $0
	addi $sp, $sp, -4
    	sw $t1, 0($sp)         # Save $t1
    	
    	la $a0, dealer_values
    	add $a1, $s4, $0
    	
    	jal sum_of_hand
    	
    	lw $t1, 0($sp)         # Restore $t1
    	addi $sp, $sp, 4
    	
    	addi $t5, $0, 17	# t5 is 17
    	slt $t6, $v0, $t5	# if sum is less than 17, we should hit
    	addi $t7, $0, 1		#
    	beq $t7, $t6,  dealer_hitting	#
    	
    	add $s2, $v0, $0	# s2 CAN HOLD OUR DEALER SUM WHEN DONE HITTING
    	
    	beq $t9, $0, deliver_payout
    	j while_playing
    	
deliver_payout:
   	la $a0, player_values
   	add $a1, $s3, $0
   	jal sum_of_hand

   	
   	beq $v0, $s2, while_playing ##################
   	slt $t9, $s2, $v0
   	beq $t9, $0, subtract_loss
   	addi $a0, $0, 382219
	jal put_sound
	addi $a0, $0, 100
    	jal pause
    	jal sound_off
   	add $s0, $s0, $s1
   	j while_playing
   	
subtract_loss:
	sub $s0, $s0, $s1	# bank = bank - wager
	addi $a0, $0, 191113
	jal put_sound
	addi $a0, $0, 100
    	jal pause
    	jal sound_off
	j while_playing
    	
dealer_hitting:
	addi $sp, $sp, -12  	#
    	
    	sw $t1, 0($sp)         # Save $t1
    	sw $t6, 4($sp)
    	sw $t7, 8($sp)
    	
    	#GENERATE NEW SUIT AND VALUE FOR DEALER
    	addi $a0, $0, 3
    	jal generate_random_number
    	sll $t0, $s4, 2
    	sw, $v0, dealer_suits($t0)
    	addi $a0, $0, 12
    	jal generate_random_number
    	sll $t0, $s4, 2
    	sw, $v0, dealer_values($t0)
    	
    	#PRINT THE NEW CARD
    	lw $a0, dealer_suits($t0)
    	lw $a1, dealer_values($t0)
    	
    	sll $t5, $s4, 2
    	sll $t8, $s4, 1
    	add $a2, $t5, $t8
    	addi $a2, $a2, 3
    	addi $a3, $0, 5
    	jal print_card
    	
    	addi $a0, $0, 200
    	jal pause

    	lw $t1, 0($sp)         # 
    	lw $t6, 4($sp)
    	lw $t7, 8($sp)
    	addi $sp, $sp, 12
    	
    	addi $s4, $s4, 1	#INCREMENT PLAYER HAND SIZE
    	
    	#######CHECK FOR DEALER BUST############
    	addi $sp, $sp, -12
    	sw $t1, 0($sp)         # Save $t1
    	sw $t6, 4($sp)
    	sw $t7, 8($sp)
    	la $a0, dealer_values
    	add $a1, $s4, $0
    	jal sum_of_hand
    	lw $t1, 0($sp)         #
    	lw $t6, 4($sp)
    	lw $t7, 8($sp)
    	addi $sp, $sp, 12
    	
    	addi $t8, $0, 22		# t8 is 21
    	slt $t8, $v0, $t8		# if the sum <21, t8 will be 1
    	beq $t8, $0, dealer_bust	# otherwise, its a bust
    	j dealer_going
    	

dealer_bust:
	addi $t9, $0, 1
	add $s0, $s0, $s1
	addi $a0, $0, 382219
	jal put_sound
	addi $a0, $0, 100
    	jal pause
    	jal sound_off
	j while_playing
	
 
hitting:
	addi $sp, $sp, -12
    	sw $t1, 0($sp)         # Save $t1
    	sw $t6, 4($sp)
    	sw $t7, 8($sp)
    	
    	# GENERATE NEW SUIT AND VALUE FOR PLAYER
    	addi $a0, $0, 3
    	jal generate_random_number
    	sll $t0, $s3, 2
    	sw $v0, player_suits($t0)
    	addi $a0, $0, 12
    	jal generate_random_number
    	sll $t0, $s3, 2
    	sw $v0, player_values($t0)
    	
    	#PRINT THE NEW CARD
    	lw $a0, player_suits($t0)
    	lw $a1, player_values($t0)
    	sll $t5, $s3, 2
    	sll $t8, $s3, 1
    	add $a2, $t5, $t8
    	addi $a2, $a2, 3
    	addi $a3, $0, 12
    	jal print_card
    	
    	addi $a0, $0, 200
    	jal pause

    	lw $t1, 0($sp)         
    	lw $t6, 4($sp)
    	lw $t7, 8($sp)
    	addi $sp, $sp, 12
    	
    	addi $s3, $s3, 1	#INCREMENT PLAYER HAND SIZE
    	
    	la $a0, player_values	#CALCULATE NEW SUM OF HAND
    	add $a1, $s3, $0
    	jal sum_of_hand
    	
    	addi $t8, $0, 22	# t8 is 22
    	slt $t8, $v0, $t8	# if sum less than 22, t8 is 1
    	beq $t8, $0, bust	# if t8 is 0, sum is >= 22
    	j deciding
    	

bust:
	sub $s0, $s0, $s1	# bank = bank - wager
	addi $t6, $0, 1
	addi $a0, $0, 191113
	jal put_sound
	addi $a0, $0, 100
    	jal pause
    	jal sound_off
	j while_playing
	

blackjack:
	add $s0, $s0, $s1
	add $s0, $s0, $s1
	addi $a0, $0, 382219
	jal put_sound
	addi $a0, $0, 100
	jal pause
	jal sound_off
	j while_playing 
    	
    	
	
#############################################
#Generates a random number between 0 and x-1#
#############################################

.globl generate_random_number
generate_random_number:
    # Load the LFSR seed
    lw $t0, seed        # $t0 = current LFSR value (16-bit)

    # Extract the tapped bits
    andi $t1, $t0, 0x1  # $t1 = bit 0 (LSB of $t0)
    srl $t2, $t0, 2     # Shift $t0 right by 2
    andi $t2, $t2, 0x1  # $t2 = bit 2
    srl $t3, $t0, 3     # Shift $t0 right by 3
    andi $t3, $t3, 0x1  # $t3 = bit 3
    srl $t4, $t0, 5     # Shift $t0 right by 5
    andi $t4, $t4, 0x1  # $t4 = bit 5

    # XOR the tapped bits together
    xor $t5, $t1, $t2   # $t5 = bit0 XOR bit2
    xor $t5, $t5, $t3   # $t5 = $t5 XOR bit3
    xor $t5, $t5, $t4   # $t5 = $t5 XOR bit5

    # Shift the LFSR and insert the feedback bit
    srl $t0, $t0, 1     # Shift right by 1
    sll $t5, $t5, 15    # Shift feedback to MSB (bit 15)
    or $t0, $t0, $t5    # Insert the feedback bit

    # Update the seed
    sw $t0, seed        # Store the updated LFSR value


    # Limit output to range [0, $a0] using repeated subtraction
    add $t6, $t0, $0       # $t6 = current LFSR value
    addiu $t7, $a0, 1   # $t7 = $a0 + 1 (divisor)

modulo_loop:
    bge $t6, $t7, subtract # If $t6 >= $t7, subtract $t7
    j end_modulo           # Otherwise, we are done
subtract:
    sub $t6, $t6, $t7      # $t6 -= $t7
    j modulo_loop

end_modulo:
    add $v0, $t6, $0          # $v0 = final value in range [0, $a0]
    jr $ra



######################
#Sums up a given hand#
######################

.globl sum_of_hand

sum_of_hand:
    # Save return address
    addi $sp, $sp, -4
    sw $ra, 0($sp)

    # Initialize variables
    add $t0, $0, $0  # total = 0
    add $t1, $0, $0  # aces = 0
    add $t2, $0, $0  # i = 0

loop_sum:
    beq $t2, $a1, end_loop_sum #if i>= hand_size we end the loop

    # Load the current card value
    sll $t3, $t2, 2  # Calculate offset
    add $t3, $a0, $t3  # Get address of hand[i] (Offset+location of hand)
    lw $t4, 0($t3)  # Load card value into $t4

    # Check if card is an ace
    addi $t5, $0, 1
    bne $t4, $t5, not_ace_sum

    # Handle ace
    addi $t1, $t1, 1  # Increment aces
    addi $t0, $t0, 11  # Add 11 to total
    j increment_i_sum

not_ace_sum:
    # Check if card is 0 or 10 or greater
    add $t5, $0, $0 # t5 is 0
    beq $t4, $t5, ten_or_zero_sum
    add $t5, $0, 10 #t5 is 10
    slt $t6, $t4, $t5 # t6 is 1 if card <10 we branch if card >= 10 so we branch when t6 is 0
    beq $t6, $0, ten_or_zero_sum # if t6 is 0 we branch

    # Add card value to total
    add $t0, $t0, $t4
    j increment_i_sum

ten_or_zero_sum:
    addi $t0, $t0, 10  # Add 10 to total

increment_i_sum:
    addi $t2, $t2, 1  # Increment i
    j loop_sum

end_loop_sum:

    # Adjust total for aces if necessary
while_loop_sum:
    addi $t5, $0, 21 #t5 is 21
    ble $t0, $t5, end_while_loop_sum #if total<=21 break ##########################
    beq $t1, $0, end_while_loop_sum # if aces == 0 break
    
    addi $t0, $t0, -10  # subtract 10 from total
    addi $t1, $t1, -1 	# subtract 1 from aces
    j while_loop_sum

end_while_loop_sum:

    # Move total to return register
    add $v0, $0, $t0

    # Restore return address
    lw $ra, 0($sp)
    addi $sp, $sp, 4

    # Return from function
    jr $ra

###################################################
#Prints a given card to the screen at a given spot#
###################################################

.globl print_card

print_card:
    # Save return address
    addi $sp, $sp, -4
    sw $ra, 0($sp)

    # Initialize loop counters
    add $t0, $0, $0  # i = 0
    add $t1, $0, $0  # j = 0

outer_loop_print_card:
    # Check outer loop condition (i < 5)
    addi $t2, $0, 5  # t2 is 5
    slt $t3, $t0, $t2
    bne $t3, $0, inner_loop_print_card  #if i < 5 go to inner loop

    # Exit outer loop if i >= 5
    j end_outer_loop_print_card

inner_loop_print_card:
    # Check inner loop condition (j < 5)
    addi $t2, $0, 5  # t2 is 5, 
    slt $t3, $t1, $t2
    bne $t3, $0, print_char # if j < 5 we prep to print the char

    # Reset inner loop counter and increment outer loop counter
    add $t1, $0, $0 	#j=0
    addi $t0, $t0, 1	#i +=1
    j outer_loop_print_card

print_char:

    addi $sp, $sp, -20  #
    			#
    sw $a2, 0($sp)	# Saving arguments to the stack
    sw $a1, 4($sp)	#
    sw $a0, 8($sp)	#
    sw $t0, 12($sp)
    sw $t1, 16($sp)
    
    # Calculate character to print (34)
    addi $a0, $0, WHITE   # load white into a0 to print card
    # Calculate x and y coordinates
    add $a1, $a2, $t0   # a1 is posx + i
    add $a2, $a3, $t1   # a2 is posy + j
    # Call putChar_atXY
    jal putChar_atXY
    
    
       #
    lw $a2, 0($sp)	#
    lw $a1, 4($sp)	# restore arguments from stack
    lw $a0, 8($sp)	#
    lw $t0, 12($sp)
    lw $t1, 16($sp)
    addi $sp, $sp, 20
    			#
    
    

    # Increment inner loop counter and check if it's 5
    addi $t1, $t1, 1	# j+=1
    j inner_loop_print_card

end_outer_loop_print_card:

    ###### Calling putChar_atPXY(number_value+35, posx, posy) ##########
    addi $sp, $sp, -20  #
    			#
    sw $a2, 0($sp)	# Saving arguments to the stack
    sw $a1, 4($sp)	#
    sw $a0, 8($sp)	#
    sw $t0, 12($sp)
    sw $t1, 16($sp)
    
    add $t3, $a0, $0
    add $t4, $a1, $0
    add $t5, $a2, $0
    add $t6, $a3, $0
    
    addi $a0, $t4, 4
    add $a1, $t5, $0						
    add $a2, $t6, $0
    
    jal putChar_atXY
    
    			#
    
    ###### Calling putChar_atPXY(number_value+35, posx+3, posy+4) ##########

    
    addi $a0, $t4, 4
    addi $a1, $t5, 3						
    addi $a2, $t6, 4
    
    jal putChar_atXY
    
    
    add $a0, $t3, $0
    addi $a1, $t5, 1						
    add $a2, $t6, $0
    
    jal putChar_atXY
    
 
    
    ###### Calling putChar_atPXY(number_suit+48, posx+4, posy+4) ##########
    
    
    add $a0, $t3, $0
    addi $a1, $t5, 4						
    addi $a2, $t6, 4
    
    jal putChar_atXY
    
       #
    lw $a2, 0($sp)	#
    lw $a1, 4($sp)	# restore arguments from stack
    lw $a0, 8($sp)	#
    lw $t0, 12($sp)
    lw $t1, 16($sp)
    addi $sp, $sp, 20
    

    # Restore return address
    lw $ra, 0($sp)
    addi $sp, $sp, 4

    # Return from function
    jr $ra
    
	
###############################
# Erases all cards from screen#
###############################
.globl clear_board
clear_board:
    addi $sp, $sp, -4
    sw $ra, 0($sp)
    addi $t0, $0, 3  # i = 0
    addi $t1, $0, 3  # j = 0

outer_loop_clear:
    addi $t2, $0, 27  # t2 is 30
    bne $t0, $t2, inner_loop_clear  #if i<30 we can enter the inner loop
    j end_outer_loop_clear  #other wise prepare to exit

inner_loop_clear:
    addi $t2, $0, 37  #t2 is 40
    bne $t1, $t2, call_putchar_clear   #if j < 40 we should get ready to print

    bne $t1, $t2, inner_loop_clear

    addi $t1, $0, 3
    addi $t0, $t0, 1 # increment i
    j outer_loop_clear # jump back to the outer loop

call_putchar_clear:
    addi $a0, $0, BACKGROUND  # Character to print
    add $a1, $t1, $0  # x-coordinate
    add $a2, $t0, $0  # y-coordinate
    jal putChar_atXY

    addi $t1, $t1, 1 #incremnet j
    j inner_loop_clear

end_outer_loop_clear:
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra
    
end_game:
	jal clear_board
	addi $a0, $0, CRY
	addi $a1, $0, 15
	addi $a2, $0, 15
	jal putChar_atXY
	addi $a0, $0, 100
	jal pause
	j end_game
    
    
.include "procs_board.asm"               # Use this line for board implementation
#.include "procs_mars.asm"                # Use this line for simulation in MARS
