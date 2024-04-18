#############################################################
#							    #
# Written by: Bouritis Ioannis, Dimas Christos		    #
# Date: 18 / 11 / 2022					    #
# Note:         			`		    #							    
#							    #
#############################################################
#############################################################
#							    #
#							    #
#		      Data segment		            #
#							    #
#							    #
#############################################################
.data 	

	prompt:  .asciiz "Please determine operation, entry(E), inquiry(I), quit(Q):\n"
	enum:    .asciiz "Please enter entry number:\n"
	fname:   .asciiz "Please enter first name:\n"
	lname:   .asciiz "Please enter last name:\n"
	pnum:    .asciiz "Please enter phone number:\n"
	inqr:    .asciiz "Please enter index number:\n"
	newEntry:.asciiz "Thank you, the new entry is the following:\n"

	input: .space 5
   
               	 
	list: .space 480	#space for up to 10 (cat_num, phone_num, first_name, last_name)
    
           	 
	noEnt:	.asciiz	"There is no such entry in the phonebook.\n"
	full:	.asciiz	"You cannot store more than 10 entries.\n"
	isNum:	.asciiz	"The number is:\n"
	
    	nline:  .asciiz	"\n"
	nline2:	.asciiz	"\n\n"
    
#############################################################
#							    #
#							    #
#		      Text segment			    #
#							    #
#							    #
#############################################################
.text		

main:				#Start of code section

jal Prompt_User

jal Get_User_Prompt

addi $t1, $zero, 0		#used for entry num
addi $t3, $zero, 0		#used for phone num
addi $t4, $t4, 0

menu:

	lb $t0, input		#stores the input to $t0
	
	beq $t0, 81, terminate	#if user enters Q or q terminates the program
	beq $t0, 113, terminate

	beq $t0, 69, entry	#if user enters E or e jumps to entry subrutine
	beq $t0, 101, entry

	beq $t0, 73, inquiry	#if user enters I or i jumps to inquiry subrutine
	beq $t0, 105, inquiry

	loop:
		jal Prompt_User
		jal Get_User_Prompt
		j menu

	entry:
		jal Get_Entry

		j loop

		inquiry:
			jal find_inq

			j loop
	terminate:
		li $v0, 10
		syscall

Prompt_User:
	li $v0, 4		#syscall to print string
	la $a0, prompt		#load the address of prompt to $a0
	syscall			#do the syscall

	jr $ra

Get_User_Prompt:

	li $v0,8		#syscall to scan string
	la $a0, input		#loads the address of input in a0
	ori $a1, $zero, 5
	syscall			#do the syscall

	jr $ra

Get_Entry:
	
	addi $sp, $sp, -8	
	sw $ra, 0($sp)		#save $ra to the stack

	bge $t1, 10, fullCat	#if $t1 = 10 then go to fullCat

	addi $t1, $t1, 1	#counter continues

	jal Get_First_Name	#jumps to Get_First_Name

	jal Get_Last_Name	#jumps to Get_Last_Name

	jal Get_Phone_Number	#jumps to Get_Phone_Number

	jal Get_Number		#jumps to Get_Number


	li $v0, 4		#syscall to print string
	la $a0, newEntry	#load the address of newEntry to $a0
	syscall			#do the syscall
					
	jal Print_Entry		#goes to print_Entry

	j checklimit		#jumps to checklimit
	
	fullCat:
		li $v0, 4	#syscall to print string
		la $a0, full	#load the address of full to $a0
		syscall
	checklimit:
		lw $ra, 0($sp)	#restore $ra from the stack
		addi $sp, $sp, 8#reset stack pointer

		jr $ra


Get_Number:

	li $v0, 4		#syscall to print string
	la $a0, enum		#load the address of enum to $a0
	syscall			#do the syscall

	li $v0, 5
	la $a0, list($t3)
	ori $a1, $zero, 20
	syscall

	addi $t3, $t3, 4

	jr $ra
	
Get_First_Name:

	li $v0, 4		#syscall to print string
	la $a0, fname		#load the address of fname to $a0
	syscall

	li $v0, 8		#syscall to read string
	la $a0, list($t3)
	ori $a1, $zero, 20
	syscall

	addi $t3, $t3, 20

	jr $ra
Get_Last_Name:

	li $v0, 4		#syscall to print string
	la $a0, lname		#load the address of lnameto $a0
	syscall
	
	li $v0, 8		#syscall to read string
	la $a0, list($t3)	#load the address of lname to $a0
	ori $a1, $zero, 20
	syscall

	addi $t3, $t3, 20

	jr $ra
Get_Phone_Number:

	li $v0, 4		#syscall to print string
	la $a0, pnum		#load the address of pnum to $a0
	syscall

	li $v0, 5		#syscall to read integer
	syscall
	
	sw $v0, list($t3)

	addi $t3, $t3, 4

	jr $ra

Print_Entry:

	addi $sp, $sp, -16
	
	sw $s0, 0($sp)		#save $s0 to the stack
	sw $a3, 4($sp)		#save $a3 to the stack
	sw $a1, 8($sp)		#save $a1 to the stack

	addi $s0, $t3, -44
	
	addi $a1, $zero, 100	#a1=20 
	
	remove1:
		
	    lb $a3,list($s0)	# Load character at index
	    addi $s0,$s0,1  	# Increment index
	    bnez $a3,remove1	# Loop until the end of string is reached
	    beq $a1,$s0,skip1	# Do not remove \n when string = maxlength
	    addi $t5,$s0,-2 	# If above not true, Backtrack index to 'n'
	    sb $0, list($t5)	# Add the terminating character in its place
		
	    skip1:
   	 
		addi $s0,$t3,-24
   	 
	remove2:
		
	    lb $a3,list($s0)	# Load character at index
	    addi $s0,$s0,1  	# Increment index
	    bnez $a3,remove2 	# Loop until the end of string is reached
	    beq $a1,$s0,skip2	# Do not remove \n when string = maxlength
	    addi $t5,$s0,-2 	# If above not true, Backtrack index to 'n'
	    sb $0, list($t5)	# Add the terminating character in its place
		
	    skip2:
		
	li $v0, 4		#syscall to print string
	la $a0, list($t4)	#load the address of the string to be printed
	syscall			#do the syscall

	# print space, 32 is ASCII code for space
	li $a0, 32
	li $v0, 11  		# syscall number for printing character
	syscall			#do the syscall
   	 
   	 
	addi $t4,$t4, 20
   	 
	li $v0, 4               #System call code for printing string = 4  
    	la $a0, list($t4)       #Load address of string to be printed into $a0  
    	syscall			#do the syscall
   	 
    
    
	addi $t4,$t4, 20
   	 
   		 
	# print space, 32 is ASCII code for space
	li $a0, 32
	li $v0, 11 		#syscall number for printing character
	syscall			#do the syscall
   	 
	li $v0, 1               #System call code for printing int = 1  
    	lw $a0, list($t4)       #Load address of string to be printed into $a0  
    	syscall			#do the syscall
   	   
	addi $t4,$t4, 4
   	 
		
	# print space, 32 is ASCII code for space
	li $a0, 32
	li $v0, 11  		#syscall number for printing character
	syscall
   	 
   	lw $s0, 0($sp)          #Restore $s0 from the stack
	lw $a3, 4($sp)         	#Restore $a3 from the stack
	lw $a1, 8($sp)          #Restore $a1 from the stack
   	 
    	addi $sp, $sp, 16       #Reset stack pointer
   	 
   	 
	 
    	jr $ra
		
find_inq: 
		
	addi $sp, $sp, -8
  	sw $a1, 0($sp)    	#Save $a1 to the stack
	sw $ra, 4($sp)  	#Save $ra to the stack
		
		
	addi $t8, $zero, 0	#Initialize $t8 to zero
		
	
	li $v0, 4               #System call code for printing string = 4  
    	la $a0, inqr            #Load address of string to be printed into $a0  
    	syscall                 #Call operating system to perform operation


	li $v0,5                #Tell syscall to read an integer
    	syscall			#Call operating system to perform operation
		
	move $a1, $v0		#Move the user's integer to from $v0 to $a1
		
	move $t7, $a1		#Keeps a copy of users input in $a2
		
	bgt $a1,$t1,ex1 	#If $a1 > $t1 there is no such entry
	ble $a1,$zero, ex1	#If $a1 <= 0 then jumps to ex1
		

	loopi:			#Beginning of loop
		
		ble $a1, 1, next	#If $t8 <= 1 then jump to next
		addi $t8, $t8, 44	#Increase $t8 by 44 (next entry)
		addi $a1, $a1, -1	#Decrease  $v0 by 1 (for the loop to end)
		j loopi			#Jump to loopi
		
	next:
			
		jal Print_fEntry
			
		j ex2
			
		ex1:
			
			li $v0, 4       #System call code for printing string = 4  
			la $a0, noEnt   #Load address of string to be printed into $a0  
			syscall									#Call operating system to perform operation
			
		
		ex2:
			
			
			lw $a1, 0($sp)  #Restore $a1 from the stack
			lw $ra, 4($sp) 	#Restore $ra from the stack
   	 
			addi $sp, $sp, 8 #Reset stack pointer
   	 
		
		
			jr $ra 								


Print_fEntry:
			
	li $v0, 4           	#System call code for printing string = 4  
	la $a0, isNum       	#Load address of string to be printed into $a0  
	syscall  
		
	li $v0, 1           	#Prints $t7         	 
	move $a0, $t7                 	 
    	syscall
			
	li $v0, 11		# syscall 11: print a character based on its ASCII value
	li $a0, 46 		# ASCII value of a '.' is "46"
	syscall
		
	# print space, 32 is ASCII code for space
	li $a0, 32
	li $v0, 11  		# syscall number for printing character
	syscall
			

	li $v0, 4            	#System call code for printing string = 4  
	la $a0, list($t8)       #Load address of string to be printed into $a0  
	syscall   		#Call operating system to perform operation
		
   	 
	# print space, 32 is ASCII code for space
			
	li $a0, 32
	li $v0, 11  		# syscall number for printing character
	syscall			#Call operating system to perform operation
   	 
   	addi $t8,$t8, 20	#Increases $t8 by 20, to reach the surname field
   	 
	li $v0, 4               #System call code for printing string = 4  
	la $a0, list($t8)       #Load address of string to be printed into $a0  
	syscall			#Call operating system to perform operation
   	 
   	 
   		 
	# print space, 32 is ASCII code for space
	li $a0, 32
	li $v0, 11 		# syscall number for printing character
	syscall			#Call operating system to perform operation
	 
	 
	addi $t8,$t8, 20	#Increases $t8 by 20, to reach the phone field
   	 
	li $v0, 1               #System call code for printing int = 1 
	lw $a0, list($t8)       #Load address of string to be printed into $a0  
	syscall			#Call operating system to perform operation
   	   
   	 
	li $v0, 4               #System call code for printing string = 4  
	la $a0, nline2          #Load address of string to be printed into $a0  
	syscall			#Call operating system to perform operation
			
	jr $ra
