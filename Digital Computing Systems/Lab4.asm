.data 		#Data segment

enter_string : .asciiz "\nPlease enter a character\n"	#String to be printed
output_string : .asciiz "\nThe final string is:\n"	#String to be printed

result: .space 100
space: .space 100

.text		#Text segment

main:		#Start of code section

  
jal init

add $a0, $s0, $zero
jal get_string

add $a0, $s0, $zero
  
add $a1, $s1, $zero

add $a2, $zero, $v0
jal process_string

add $a0, $s1, $zero
jal out_string

li $v0, 10		#exit syscall
syscall			#do the syscall
###############################################################
init:

	la $s0,	result			#loading result address to register s0
	la $s1, space			#loading space address to register s1
	la $s2, enter_string
	la $s3, output_string
	addi $t0,$0, 0 			#value useful for loop
	add $t1, $zero, $zero
	add $t2, $zero, $zero
	add $t3, $zero, $zero
	add $t4, $zero, $zero
	add $t5, $zero, $zero
	add $t6, $zero, $zero
	add $t7, $zero, $zero
	add $t8, $zero, $zero
	addi $t9, $0, 10 
		
	jr $ra
################################################################
################################################################
get_string:

#$a0 = string1
#$v0 = return 
	
	move $a0, $s2		#load the address of message into a0
	li $v0, 4
	syscall

	li $v0, 12		#read_character syscall
	syscall			#do the syscall
				
	beq $v0,'@', exit	#if input=@ goes to exit
	
	sb $v0, result($t0)		#else stores 0 in the next byte
	addi $t0, $t0, 1	#increases t0, to point to the next byte
	beq $t0,99,exit		#if it surpasses the limit goes to exit
	j get_string		#jump to get_string 

exit: 	
	add $v0, $zero, $t0	#stores the num_characters in v0
	sb $t9, result($t0)
	jr $ra
################################################################
process_string:

checkingLoop:			#ascii for exit function

	lb $t1, 0($s0)		
	addi $s0,$s0,1		

	beq $t1, $t9, end_process
	
	beq $t1,' ',store
	
case1:				#searching if byte is a number (ascii code between 47 and 58)
	addi $t4, $s0,58
	slt $t2, $t1, $t4	#searching if byte<58
	bne $t2, $0, number	#if yes, goes to number

number:				#searching if byte>47 so we can consider it number
	addi $t7,$0,47	
	slt $t3, $t7,$t1	#searching if byte>47
	bne $t3,$0, store	#if yes, goes to store
	
	j case2  		#else goes to the next case

case2:				#searching if byte is a capital letter (ascii code between 64 and 91)
	addi $t5,$0,91
	slt $t2, $t1,$t5	#searching if byte<91
	bne $t2,$0, uppercase	#if yes, goes to uppercase 

uppercase:			#searching if byte>64 so we can consider it uppercase letter
	addi $t7,$0,64	
	slt $t3, $t7,$t1	#searching if byte>64
	bne $t3,$0, store	#if yes, goes to store

	j case3			#else goes to the next case

case3:				#searching if byte is a lowercase letter (ascii code between 96 and 123)
	addi $t6,$0,123
	slt $t2,$t1,$t6		#searching if byte<123
	bne $t2,$0, lowercase	#If yes, goes to lowercase

lowercase:			#searching if byte>96 so we can consider it lowercase letter
	addi $t7,$0,96	
	slt $t3, $t7,$t1	#searching if byte>96
	bne $t3,$0, store	#if yes, goes to store

	j end			#else goes to the next case

end:				#if the byte is neither a number nor a letter we repeat the previous process 	
	j checkingLoop		#jumps to checkingLoop
store:				#else we store the byte into space
	sb   $t1, 0($s1)
	addi $s1,$s1,1
	j checkingLoop		#jumps to checkingLoop
end_process:
	add  $v0, $zero, $t0
	add  $t1, $zero, 100
	sub  $v1, $t1, $t0
	jr $ra
###############################################################################################
out_string:

	move $a0, $s3		#load address of output_string in a0
	li $v0,4		#print_string syscall
	syscall			#do the syscall

	la $a0, space		#loading address of space in a0
	li $v0,4		#print_string syscall
	syscall			#do the syscall
	jr $ra
