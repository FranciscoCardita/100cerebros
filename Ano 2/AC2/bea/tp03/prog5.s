# Contador em anel de 4 bits (ring counter) com deslocamento à esquerda ou à direita,
# dependendo do valor lido do porto RB1: se RB1=1, deslocamento à esquerda. Frequência
# de atualização de 3 Hz (deslocamento à esquerda: 0001, 0010, 0100, 1000, 0001, ...).


		.equ SFR_BASE_HI, 0xBF88 		# 16 MSbits of SFR area
		.equ TRISE, 0x6100 				# TRISE address is 0xBF886100
		.equ PORTE, 0x6110 				# PORTE address is 0xBF886110
		.equ LATE,  0x6120 				# LATE  address is 0xBF886120

		.equ TRISB, 0x6040 				# TRISB address is 0xBF886040
		.equ PORTB, 0x6050 				# PORTB address is 0xBF886050
		.equ LATB,  0x6060 				# LATB  address is 0xBF886060

		.equ PUT_CHAR, 3
		.equ PRINT_INT, 6
		.equ READ_CORE_TIMER, 11 
		.equ RESET_CORE_TIMER, 12
		.equ TARGET_CORE_VAL, 20000

		.data

		.text
		.globl main

# map:
# counter     -> $s0
# RB          -> $t0
# SFR_BASE_HI -> $t1
# 

main: 	addu $sp, $sp, -4
		sw $ra, 0($sp)					# save $ra

		lui $t1, SFR_BASE_HI 			# set up base address
		lw $t2, TRISE($t1) 				# 
		andi $t2, $t2, 0xFFF0 			# 
		sw $t2, TRISE($t1)				# configure RE0 to RE3 as output
		lw $t2, TRISB($t1) 				# 
		ori $t2, $t2, 0x0002 			# 
		sw $t2, TRISB($t1)				# configure RB1 as input

		li $s0, 1						# initialize counter to 0
	
loop:									# while(1) {
		lw $t0, PORTB($t1)				#
		andi $t0, $t0, 0x0002			#   read RB1

		beq $t0, $0, else				#   if (RB1 == 1) { 
										#     // left shift (take first, save, shift, put first as last)
		andi $t2, $s0, 0x0008			#     get counter(3)

		bne $t2, $0, lelse				#     if (counter(3) == 1) {
		sll $s0, $s0, 1					#       sll(counter);
		andi $s0, $s0, 0xFFFE			#	    counter(0) = 1;
										#
		j endif							#
lelse:									#     } else {
		sll $s0, $s0, 1					#       sll(counter);
		ori $s0, $s0, 0x0001			#	    counter(0) = 0;
		j endif
										#     }
else:									#   } else {
										#     // right shift (take last, save, shift, put last as first)
		andi $t2, $s0, 0x0001			#     get counter(0)

		bne $t2, $0, relse				#     if (counter(0) == 0) {
		srl $s0, $s0, 1					#       srl(counter);
		andi $s0, $s0, 0xFFF7			#	    counter(3) == 0;
										#
		j endif							#
relse:									#     } else {
		srl $s0, $s0, 1					#       srl(counter);
		ori $s0, $s0, 0x0008			#	    counter(3) == 1;
										#     }
endif:									#   }

		andi $s0, $s0, 0x000F			#   // count only s0's 4 least significant bits

		move $a0, $s0					#
		li $a1, 0x00040002				#
		li $v0, PRINT_INT				#
		syscall							#

		li $a0, '\n' 					# 
		li $v0, PUT_CHAR 				#
		syscall							#   print s0 value

		lw $t2, LATE($t1) 				#   // Read LATE register
		andi $t2, $t2, 0xFFF0 			#   // Modify bits 3 to 0
		or $t2, $t2, $s0				# 
		sw $t2, LATE($t1)				#   write s0 to RE0 to RE3

		li $a0, 333
		jal delay						#   delay(333) // 3 Hz frequency = 1/3 seconds update rate = 333ms update rate

		j loop							# }


		lw $ra, 0($sp)					# retore ra
		addu $sp, $sp, 4
		jr $ra



delay:
whiled: beq $a0, $0, endw						# while(ms > 0) {

		li $v0, RESET_CORE_TIMER				#
		syscall 								#   resetCoreTimer();

wait:	li $v0, READ_CORE_TIMER 				#
		syscall 								#
		blt $v0, TARGET_CORE_VAL, wait 			#   while(readCoreTimer() < 20000);
 
		addi $a0, $a0, -1						#   ms--;
		j whiled								# }

endw:	jr $ra

