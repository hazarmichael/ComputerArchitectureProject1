# 	Ibaa Taleeb 1203073
# 	Hazar Michael 1201838
.data
file_path:       .asciiz   "C:\\Users\\HaZaR\\Desktop\\Mips Project\\Calendar.txt"
file_descriptor: .word 0
line_not_found_msg: .asciiz "     This day is not saved in the Calendar.\n"
buffer:          .space 1024  # Adjust size accordingly
menu_prompt:     .asciiz "\nChoose an option:\n1. View a specific line.\n2. View multiple lines.\n3.View Slot Type in Specific Day\n4.View Statistics.\n5.Add a new appointment.\n6.Delete an appointment.\n7.Exit the program.\nEnter your choice: "
user_prompt:     .asciiz "\nEnter the day you want to view: "
days_prompt:     .asciiz "\nHow many days do you want to view ? "
newline:         .asciiz "\n"
day_separator:   .asciiz ":"
time_separator:  .asciiz ": "
lecture_separator: .asciiz "-"
office_separator: .asciiz "-"
lecture_suffix:   .asciiz " L, "
office_suffix:    .asciiz " OH, "
meeting_suffix:   .asciiz " M\n"
space: .asciiz " "        # Space character
dash: .asciiz "-"         # Dash character
new_appointment_prompt:     .asciiz "Enter the day number for the new appointment: "
start_time_prompt:          .asciiz "Enter the lecture start time (between 8 and 17): "
end_time_prompt:            .asciiz "Enter the lecture end time (between 8 and 17): "
meeting_start_prompt:       .asciiz "Enter the meeting start time (between 8 and 17): "
meeting_end_prompt:         .asciiz "Enter the meeting end time (between 8 and 17): "
office_start_prompt:        .asciiz "Enter the office hours start time (between 8 and 17): "
office_end_prompt:          .asciiz "Enter the office hours end time (between 8 and 17): "
error:                      .asciiz "Error: Invalid time. Please enter a time between 8 and 17.\n"
time_error:                 .asciiz "Error: Time conflict. Please choose a different time.\n"

same_start_and_end_time_error_lecture_msg:  .asciiz "Error: Lecture start time and end time cannot be the same.\n"
same_start_and_end_time_error_meeting_msg:  .asciiz "Error: Meeting start time and end time cannot be the same.\n"
same_start_and_end_time_error_office_msg:   .asciiz "Error: Office hours start time and end time cannot be the same.\n"

insert_new_appointment: .asciiz""
choose_another_time_prompt: .asciiz "\nchoose another time\n"
invalid_input_msg:  .asciiz "Invalid input. Please enter a number between 1 and 7.\n"
total_lecture_hours: .word 0 # Total lecture hours

total_lecture_hours_msg: .asciiz "\nTotal Lecture Hours: "
total_office_hours_msg: .asciiz "\nTotal Office Hours: "
total_meeting_hours_msg: .asciiz "\nTotal Meeting Hours: "
avg_lectures_per_day_msg: .asciiz "\nAverage Lectures per Day: "
ratio_lectures_office_hours_msg: .asciiz "\nRatio (Lectures/Office Hours): "
lecture_office_ratio_msg: .asciiz "\nRatio (Lectures/Office Hours): "


error_day_not_found: .asciiz "\nError:The Day is not found." 
day_prompt: .asciiz "Enter the day number: "
error_prompt: .asciiz "Error: Day not found or start time not found.\n"
no_appointment_prompt: .asciiz "No appointment found.\n"
lecture_prompt: .asciiz "Appointment is a lecture.\n"
office_hour_prompt: .asciiz "Appointment is office hour.\n"
meeting_prompt: .asciiz "Appointment is a meeting.\n"
appointment_deleted_prompt: .asciiz "Appointment deleted.\n"


###################################################################################################################################
.text
main:
    # Open the file
    li   $v0, 13         # open file
    la   $a0, file_path
    li   $a1, 0          # read-only
    li   $a2, 0          # mode is default permissions
    syscall
    
    sw   $v0, file_descriptor  # Save the file descriptor  		$v0 the file descriptor

    # Read from the file
    li   $v0, 14         # read from file
    lw   $a0, file_descriptor
    la   $a1, buffer						#$a1 address of input buffer
    li   $a2, 1024        # max bytes to read			#$a2 maximum number of characters to read
    syscall
    
    
            jal  print_buffer 				#jal is jump and link, so will go to print buffer func and return to here 

menu_loop:

    # Prompt the user to choose an option
    li   $v0, 4          # print string 		
    la   $a0, menu_prompt
    syscall

    # Get user input for the menu option
    li   $v0, 5          # read integer and the integer is stored in $v0 
    syscall
    move $t7, $v0        # Save the user choice in $t7					$t7 --> user's choice 

    # Check if the user input is within the valid range (1 to 7)
    li   $t0, 1
    li   $t1, 7
    blt  $t7, $t0, invalid_input
    bgt  $t7, $t1, invalid_input

    # Branch based on user's choice
    
    beq  $t7, 1, view_specific_line
    beq  $t7, 2, view_multiple_lines 
    beq  $t7, 3, findSlotDay
    beq  $t7, 4, Statistics
    beq  $t7, 5, add_new_appointment
    beq  $t7, 6, delete_appointment
    beq  $t7, 7, exit_program

	
    j menu_loop  # Jump back to the beginning of the menu loop

###################################################################################################################################  
  invalid_input:
    # Display an error message for invalid input
    li   $v0, 4          # print string
    la   $a0, invalid_input_msg 
    syscall

    j menu_loop  # Jump back to the beginning of the menu loop
#########################################################################################################
view_specific_line:
    # Get user input for line number 
    la   $a0, user_prompt        
    li   $v0, 4          # print string
    syscall

    li   $v0, 5          # read integer
    syscall 
    
    move $t4, $v0        # Save the user input in $t4					$t4 -> the day that the user wants to view
   
    
    move $a0,$t4 				#these three lines are for printing the number of the selected day again
    li $v0,1				#1 is for Printing an Integer
    syscall

    # Print the selected line from the buffer
    la   $a0, buffer      # Pass buffer address
    j  print_selected_line

    # If the specified line is not found, print a message
    la   $a0, line_not_found_msg
    li   $v0, 4          # print string
    syscall

    j menu_loop
    
#############################################################################################################################

# Function to print a specific line from the buffer
print_selected_line:
    move $t0, $a0         # Save the buffer address     			  $t0 has the buffer address 
  
    loop:
        lb   $t5, 0($t0)   # Load a character ( byte )    $t5 is the stack pointer 
        # Check for newline character
        
        
        beq $t5 , ':' , compare_prev    #when : is met then we have to check the prev number because it's a day number 
        beq $t5 , 0 , line_not_found  # Specified line not found
        inner:
        addi $t0, $t0, 1 
        j loop 
        
    compare_prev: 
         move $t9, $t0        #$t9 --->  :
         subi $t9, $t9 , 1 
         lb $t8 , 0($t9)     # The first Day Digit is in $t8     (for example 14 , now  $t8 is 4)
         subi $t8 , $t8 , '0' 			# Converts the ASCII  to an actual number,             $t8 the second digit
         subi $t7,$t9, 1 
         lb $s1 , 0($t7)
         bge $s1 , 48 , blt_57           #to see if it's >= 0 (48 is the ascii of 0) 
         
    blt_57:
        ble $s1 , 57 , the_num_is_Two_digits
           
    the_num_is_Two_digits:
        subi $s1,$s1,'0'  
        mul $s1,$s1, 10
        add $s1, $s1,$t8  
          
        beq $s1, $t4, this_is_the_line  
         
        j  inner
         
    this_is_the_line: 
        move $s3, $t0  
         
    loop3:  
        lb $s4, 0($s3)
        beq $s4, '\n', menu_loop 
        move $a0, $s4 
        li $v0, 11 
        syscall 
        add $s3, $s3, 1 
         
        j loop3

line_not_found:
    # Print a message when the specified line is not found
    la   $a0, line_not_found_msg
    li   $v0, 4          # print string
    syscall
    j menu_loop

###################################################################################################################################

# Function to view multiple lines
view_multiple_lines:
    # Get user input for the number of days
    li   $v0, 4          #  print string
    la   $a0, days_prompt
    syscall

    li   $v0, 5          # read integer
    syscall
    move $t8, $v0        # Save the number of days in $t8

   
    # Loop to get user input for each day and print the corresponding lines
    li   $s7, 0          # Initialize loop counter
    days_loop: 
  move $a0,$s7
        bgt  $s7, $t8, menu_loop  # Exit loop when the desired number of days is reached
        # Get user input for the day
        la   $a0, user_prompt
        li   $v0, 4          #print string
        syscall

        li   $v0, 5          # read integer
        syscall
        move $t4, $v0        # Save the user input in $t4  
         
         j  findTheDay
 findTheDay: 
  
  # Initialize $t0 to point to the beginning of the buffer
    la   $a0, buffer
    move $t0, $a0         # Save the buffer address
    loop0:
        lb $t5,0($t0) 
        # Check for newline character
        beq $t5 , ':' , compare_prev0
        beq $t5 , 0 , Update
        addi $t0,$t0,1
        j loop0
        
       Update: 
       addi $s7,$s7,1
       j days_loop

        inner0:
        addi $t0, $t0, 1 
        j loop0 
        
        
         compare_prev0: 
         move $t9, $t0 
         subi $t9, $t9 , 1 
         lb $t8 , 0($t9)     # The first Day Digit is in $t8
         subi $t8 , $t8 , '0'          
         subi $t7,$t9, 1 
         lb $s1 , 0($t7)
         bge $s1 , 48 , blt_570
         
         
         blt_570:
           ble $s1 , 57 , the_num_is_Two_digits0
           
         the_num_is_Two_digits0:
         subi $s1,$s1,'0'  
         
         mul $s1,$s1, 10
         add $s1, $s1,$t8  
          
         beq $s1, $t4, this_is_the_line0  
         
         
         j  inner0
         
         this_is_the_line0: 
         
         move $s3, $t0  
         
          loop30:  
         lb $s4, 0($s3)
         beq $s4, '\n',Update
         move $a0, $s4 
         li $v0, 11 
         syscall 
         addi $s3, $s3, 1 
         
         j loop30
###################################################################################################################################

 Statistics:
    # Initialize registers and pointers
    la   $t0, buffer     # Load the address of the input buffer
    li   $s4, 0          # Initialize total lecture hours
    li   $s5, 0          # Initialize total office hours
    li   $s6, 0          # Initialize total meeting hours
    li   $s7, 0          # Initialize total days
    li   $t1, 0          # Initialize total lecture hours for ratio calculaetion

    read_loop:
      
        la   $a1, buffer      # Buffer to read into
        move  $t0,$a1

        totalloop:
            lb   $t5, 0($t0)   # Load a character
            beq $t5, 10, totalloop_end   # Check for end of line            		10 = ascii of \n   
            
            # Check if the character is '-'
            beq $t5, '-', process_dash
            beq $t5,0,calculateAndPrint 				# 0 indicates the end of the buffer
            # If not '-' or if we didn't reach the end of buffer, move to the next character
            addi $t0, $t0, 1
            j totalloop

        process_dash:
            # Save the location of '-'
            move $t9, $t0

            # Read the previous two bytes as start time
            sub $t2, $t9, 2   # for example 10-12 it read 1 from number 10 
            lb $t5, 0($t2)
            subi $t5, $t5, '0'  # Convert ASCII to integer # t5 have the first digit from start time
            lb $s1, 1($t2)      #pointer go to the next digit 
            subi $s1, $s1, '0'  # Convert ASCII to integer # s1 have the seoned digit from start time
            mul $t5, $t5, 10    # Multiply current result by 10
            add $s1, $s1, $t5   # Add the new digit							  $S1 have the start time

            # Read the next two bytes after '-' as end time
            add $t3, $t9, 1   # for example 10-12 it read 1 from number 12
            lb $t4, 0($t3)
            subi $t4, $t4, '0'  # Convert ASCII to integer # t4 have the first digit from end time
            lb $t6, 1($t3)      #pointer go to the next digit
            subi $t6, $t6, '0'  # Convert ASCII to integer # s1 have the seoned digit from end time  
            mul $t4, $t4, 10    # Multiply current result by 10
            add $t6, $t6, $t4   # Add the new digit  							$t6 have the end time

            # Read the character after end time
            lb $t7, 4($t9) 

           # Calculate hours based on the type of appointment
            beq $t7, 'L', process_lecture
            beq $t7, 'O', process_office_hour
            beq $t7, 'M', process_meeting         

            addi $t0,$t0,1
            j totalloop
    
           process_lecture:
            # Calculate lecture hours for the day
           sub $s3, $t6, $s1
           add $s4, $s4, $s3
           add $t1, $t1, $s3  # For ratio calculation
           addi $t0,$t0,1
           j totalloop

        process_office_hour:
            # Calculate office hours for the day
            sub $s3, $t6, $s1
            add $s5, $s5, $s3 
            addi $t0,$t0,1				#Increments the buffer pointer $t0 to move to the next character in the buffer.
            j totalloop

        process_meeting:
            # Calculate meeting hours for the day
            sub $s3, $t6, $s1
            add $s6, $s6, $s3 
            addi $t0,$t0,1
            j totalloop

        totalloop_end:
            # Increment the total days counter
            addi $s7, $s7, 1

            # Move to the next line
            addi $t0, $t0, 1
            j totalloop
            
    calculateAndPrint:
    # Calculate average lectures per day   
        # Convert integers to floating-point values
        mtc1 $s4, $f2   # Move integer in $s4 to $f2 (first operand)
        mtc1 $s7, $f4   # Move integer in $s7 to $f4 (second operand)
        
        # Divide the floating-point values
        div.s $f0, $f2, $f4

    # Calculate the ratio between total lecture hours and total office hours
        # Convert integers to floating-point values
        mtc1 $s4, $f13   # Move integer in $s4 to $f2 (first operand)
        mtc1 $s5, $f14   # Move integer in $s7 to $f4 (second operand)
        
        # Divide the floating-point values
        div.s $f15, $f13, $f14

    # Print the total lecture hours
    li   $v0, 4          # print string
    la   $a0, total_lecture_hours_msg
    syscall

    li   $v0, 1          # print integer
    move $a0, $s4
    syscall

    # Print the total office hours
    li   $v0, 4          # print string
    la   $a0, total_office_hours_msg
    syscall

    li   $v0, 1          # print integer
    move $a0, $s5
    syscall

    # Print the total meeting hours
    li   $v0, 4          # print string
    la   $a0, total_meeting_hours_msg
    syscall
    
    li   $v0, 1          # print integer
    move $a0, $s6
    syscall

    # Print the average lectures per day
    li   $v0, 4          # print string
    la   $a0, avg_lectures_per_day_msg
    syscall

    li $v0, 2        # for printing floating number 
    mov.s $f12, $f0  # Load the result into $f12
    syscall

    # Print the ratio between total lecture hours and total office hours
    li   $v0, 4          # print string
    la   $a0, ratio_lectures_office_hours_msg
    syscall

    li $v0, 2        # System call for print_float
    mov.s $f12, $f15  # Load the result into $f12
    syscall

    j menu_loop  # Jump back to the beginning of the menu loop
    
###################################################################################################################################

findSlotDay:
    find_day:
        # Ask the user for the day number
        la   $a0, day_prompt
        li   $v0, 4          #print string
        syscall

        li   $v0, 5          # read integer
        syscall
        move $t4, $v0        # Save the user input in $t4
        
        # Initialize $t0 to point to the beginning of the buffer
        la   $a0, buffer
        move $t0, $a0         # Save the buffer address
        
        day_loop:
            lb $t5, 0($t0)
            # Check for newline character
            beq $t5, ':', compare_day
            beq $t5, 0, not_found
            
            addi $t0, $t0, 1           
            j day_loop

        compare_day:
               
            move $t9, $t0
            subi $t9, $t9, 1
            lb $t8, 0($t9) # The first Day Digit is in $t8
            subi $t8, $t8, '0' # convert to ASCII
            subi $t7, $t9, 1       
            lb $s1, 0($t7)
            bge $s1, 48, blt_572

            blt_572:
                ble $s1, 57, the_num_is_Two_digits2

            the_num_is_Two_digits2:
                subi $s1, $s1, '0'
                mul $s1, $s1, 10
                add $s1, $s1, $t8
                
                beq $s1, $t4, found_day
                j day_loop

            found_day:
            move $s3, $t0     #  save the pointer in  $s3
            j find_start_time

    find_start_time:
        # Ask the user for start time
        la   $a0, start_time_prompt
        li   $v0, 4          # print string to enter start time 
        syscall

        li   $v0, 5          # read integer
        syscall
        move $t5, $v0        # Save the user input in 						$t5 (start time)

        # Find the start time in the line
        start_time_loop:
            lb $t6, 0($s3) # load the pointer in $t6
            beq $t6, '-', compare_start_time    #if the pointer pointing to dash then go to function compare
            
            addi $s3, $s3, 1
            j start_time_loop

        compare_start_time:
          # Save the location of '-'
            move $t9, $s3

            sub $t2, $t9, 2   # for example 10-12 it read 1 from number 10 
            lb $s5, 0($t2)
            subi $s5, $s5, '0'  # Convert ASCII to integer 		$t5 have the first digit from start time
            lb $s1, 1($t2)      #pointer go to the next digit 
            subi $s1, $s1, '0'  # Convert ASCII to integer # s1 have the seoned digit from start time
            mul $s5, $s5, 10    # Multiply current result by 10
            add $s1, $s1, $s5   # Add the new digit  S1 have the start time
     
            beq $s1, $t5, find_end_time
            j no_appointment_found

         find_end_time:
          # Save the location of '-'
            move $t9, $s3
        # Ask the user for end time
        la   $a0, end_time_prompt
        li   $v0, 4          # print string
        syscall

        li   $v0, 5          # read integer
        syscall
        move $t6, $v0        # Save the user input in $t6 (end time)

        # Find the end time in the line
        end_time_loop:

           # Read the next two bytes after '-' as end time
            add $t3, $t9, 1   # for example 10-12 it read 1 from number 12
            lb $t4, 0($t3)
            subi $t4, $t4, '0'  # Convert ASCII to integer # t4 have the first digit from end time
            lb $t7, 1($t3)      #pointer go to the next digit
            subi $t7, $t7, '0'  # Convert ASCII to integer # s1 have the seoned digit from end time  
            mul $t4, $t4, 10    # Multiply current result by 10
            add $t7, $t7, $t4   # Add the new digit  S1 have the end time

            beq $t7, $t6, check_appointment_type
            j no_appointment_found

    check_appointment_type:
          # Save the location of '-'
            move $t9, $s3
            # Read the character after end time
            lb $t8, 4($s3) 
           # Calculate hours based on the type of appointment
            beq $t8, 'L', process_lecture_type
            beq $t8, 'O', process_office_hour_type
            beq $t8, 'M', process_meeting_type     

            addi $s3,$s3,1
            j check_appointment_type
            
    process_lecture_type:
        # Print lecture prompt
        la   $a0, lecture_prompt
        li   $v0, 4          # syscall: print string
        syscall
        j menu_loop

    process_office_hour_type:
        # Print office hour prompt
        la   $a0, office_hour_prompt
        li   $v0, 4          # syscall: print string
        syscall
        j menu_loop

    process_meeting_type:
        # Print meeting prompt
        la   $a0, meeting_prompt
        li   $v0, 4          # syscall: print string
        syscall
        j menu_loop

        not_found:
            # Print an error message
            la   $a0, error_day_not_found
            li   $v0, 4          # syscall: print string
            syscall
            j menu_loop

    no_appointment_found:
        # Print an error message
        la   $a0, no_appointment_prompt
        li   $v0, 4          # syscall: print string
        syscall
        j menu_loop
###################################################################################################################################
exit_program:
    # Open the file for writing
   # li   $v0, 13            # syscall: open file
    #la   $a0, file_path          # output file name
   # li   $a1, 1             # Open for writing
   # li   $a2, 0             # mode is ignored
   # syscall                 # open file
    #move $s6, $v0           # save the file descriptor

    # Write the buffer to the file
    #li   $v0, 15            # syscall: write to file
   # move $a0, $s6           # file descriptor
    #la   $a1, buffer        # address of buffer
   # syscall                 # write to file

    # Close the file
    #li   $v0, 16            # syscall: close file
   # move $a0, $s6           # file descriptor
  #  syscall                 # close file

    # Exit the program
    li   $v0, 10            # syscall: exit
    syscall


 
#################################################################################################################################

 add_new_appointment:
    # Prompt user for day number
    li   $v0, 4
    la   $a0, new_appointment_prompt
    syscall

    li   $v0, 5
    syscall
    move $s0, $v0   # Save day number in $s0

    # Prompt user for lecture start time
    get_lecture_start_time:
        li   $v0, 4
        la   $a0, start_time_prompt
        syscall

        li   $v0, 5
        syscall
        move $s1, $v0   # Save lecture start time in $s1

        # Check if lecture start time is valid (between 8 and 17)
        blt  $s1, 8, invalid_time_lecture_start
        bgt  $s1, 17, invalid_time_lecture_start
        j get_lecture_end_time

    invalid_time_lecture_start:
        # Print error message for lecture start time
        li   $v0, 4
        la   $a0, error 
        syscall
        j get_lecture_start_time

    # Prompt user for lecture end time
    get_lecture_end_time:
        li   $v0, 4
        la   $a0, end_time_prompt
        syscall

        li   $v0, 5
        syscall
        move $s2, $v0   # Save lecture end time in $s2

        # Check if lecture end time is valid (between 8 and 17)
        blt  $s2, 8, invalid_time_lecture_end
        bgt  $s2, 17, invalid_time_lecture_end

        # Check if lecture start time is the same as lecture end time
        beq  $s1, $s2, same_start_and_end_time_error_lecture

        # Check if lecture duration is at least 1 hour
        sub $t0, $s2, $s1
        bge $t0, 1, check_meeting

    invalid_time_lecture_end:
        # Print error message for lecture end time
        li   $v0, 4
        la   $a0, error
        syscall
        j get_lecture_end_time

same_start_and_end_time_error_lecture:
    # Print error message for same start and end time of the lecture
    li   $v0, 4
    la   $a0, same_start_and_end_time_error_lecture_msg
    syscall
    j get_lecture_end_time  # Prompt the user to enter the end time of the lecture again

    check_meeting:
        # Prompt user for meeting start time
        li   $v0, 4
        la   $a0, meeting_start_prompt
        syscall

        li   $v0, 5
        syscall
        move $s5, $v0   # Save meeting start time in $s5

        # Check if meeting start time is valid (between 8 and 17)
        blt  $s5, 8, invalid_time_meeting_start
        bgt  $s5, 17, invalid_time_meeting_start
        j get_meeting_end_time

    invalid_time_meeting_start:
        # Print error message for meeting start time
        li   $v0, 4
        la   $a0, error
        syscall
        j check_meeting

    get_meeting_end_time:
        # Prompt user for meeting end time
        li   $v0, 4
        la   $a0, meeting_end_prompt
        syscall

        li   $v0, 5
        syscall
        move $s6, $v0   # Save meeting end time in $s6

        # Check if meeting end time is valid (between 8 and 17)
        blt  $s6, 8, invalid_time_meeting_end
        bgt  $s6, 17, invalid_time_meeting_end

        # Check if meeting start time is the same as meeting end time
        beq  $s5, $s6, same_start_and_end_time_error_meeting

        # Check if meeting start time is at least 1 hour before meeting end time
        sub $t0, $s6, $s5
        bge $t0, 1, check_office_start_time

    invalid_time_meeting_end:
        # Print error message for meeting end time
        li   $v0, 4
        la   $a0, error
        syscall
        j get_meeting_end_time

same_start_and_end_time_error_meeting:
    # Print error message for same start and end time of the meeting
    li   $v0, 4
    la   $a0, same_start_and_end_time_error_meeting_msg
    syscall
    j get_meeting_end_time  # Prompt the user to enter the end time of the meeting again

    check_office_start_time:
        # Prompt user for office hours start time
        li   $v0, 4
        la   $a0, office_start_prompt
        syscall

        li   $v0, 5
        syscall
        move $s3, $v0   # Save office hours start time in $s3

        # Check if office hours start time is valid (between 8 and 17)
        blt  $s3, 8, invalid_time_office_start
        bgt  $s3, 17, invalid_time_office_start
        j get_office_end_time

    invalid_time_office_start:
        # Print error message for office hours start time
        li   $v0, 4
        la   $a0, error
        syscall
        j   check_office_start_time
        
        
    get_office_end_time:
        # Prompt user for office hours end time
        li   $v0, 4
        la   $a0, office_end_prompt
        syscall

        li   $v0, 5
        syscall
        move $s4, $v0   # Save office hours end time in $s4

        # Check if office hours end time is valid (between 8 and 17)
        blt  $s4, 8, invalid_time_office_end
        bgt  $s4, 17, invalid_time_office_end

        # Check if office hours start time is the same as office hours end time
        beq  $s3, $s4, same_start_and_end_time_error_office

        # Check if office hours start time is at least 1 hour before office hours end time
        sub $t0, $s4, $s3
        bge $t0, 1, save_appointment

    invalid_time_office_end:
        # Print error message for office hours end time
        li   $v0, 4
        la   $a0, error
        syscall
        j get_office_end_time

same_start_and_end_time_error_office:
    # Print error message for same start and end time of office hours
    li   $v0, 4
    la   $a0, same_start_and_end_time_error_office_msg
    syscall
    j get_office_end_time  # Prompt the user to enter the end time of office hours again

save_appointment:
    # Check if lecture start time is not the same as office hours start time, meeting start time, or lecture end time
    bne $s1, $s3, not_same_start_times_1
    bne $s1, $s5, not_same_start_times_1
    bne $s1, $s2, not_same_start_times_1
    j time_conflict_error

not_same_start_times_1:
    # Check if office hours start time is not the same as meeting start time or lecture end time
    bne $s3, $s5, not_same_start_times_2
    bne $s3, $s2, not_same_start_times_2
    j time_conflict_error

not_same_start_times_2:
    # Check if meeting start time is not the same as lecture end time
    bne $s5, $s2, not_same_start_times_3
    j time_conflict_error

not_same_start_times_3:
    li   $t0, 0

    li   $v0, 1
    move $a0, $s0
    syscall
    sb   $a0, buffer($t0)
    addiu $t0, $t0, 1

    li   $v0, 4
    la   $a0, time_separator
    syscall
    sb   $a0, buffer($t0)
    addiu $t0, $t0, 1

    li   $v0, 1
    move $a0, $s1
    syscall
    sb   $a0, buffer($t0)
    addiu $t0, $t0, 1

    li   $v0, 4
    la   $a0, lecture_separator
    syscall
    sb   $a0, buffer($t0)
    addiu $t0, $t0, 1

    li   $v0, 1
    move $a0, $s2
    syscall
    sb   $a0, buffer($t0)
    addiu $t0, $t0, 1

    li   $v0, 4
    la   $a0, lecture_suffix
    syscall
    sb   $a0, buffer($t0)
    addiu $t0, $t0, 1

    li   $v0, 1
    move $a0, $s3
    syscall
    sb   $a0, buffer($t0)
    addiu $t0, $t0, 1

    li   $v0, 4
    la   $a0, office_separator
    syscall
    sb   $a0, buffer($t0)
    addiu $t0, $t0, 1

    li   $v0, 1
    move $a0, $s4
    syscall
    sb   $a0, buffer($t0)
    addiu $t0, $t0, 1

    li   $v0, 4
    la   $a0, office_suffix
    syscall
    sb   $a0, buffer($t0)
    addiu $t0, $t0, 1

    li   $v0, 1
    move $a0, $s5
    syscall
    sb   $a0, buffer($t0)
    addiu $t0, $t0, 1

    li   $v0, 4
    la   $a0, lecture_separator
    syscall
    sb   $a0, buffer($t0)
    addiu $t0, $t0, 1

    li   $v0, 1
    move $a0, $s6
    syscall
    sb   $a0, buffer($t0)
    addiu $t0, $t0, 1

    li   $v0, 4
    la   $a0, meeting_suffix
    syscall
    sb   $a0, buffer($t0)
    addiu $t0, $t0, 1

    jal  print_buffer
    j menu_loop


    time_conflict_error:
        # Print error message for time conflicts
        li   $v0, 4
        la   $a0, time_error
        syscall
        j menu_loop 

###################################################################################################################################
# Function to delete appointment
delete_appointment:
    # Ask the user for the day, start time, and end time
    la   $a0, day_prompt
    li   $v0, 4          # print string
    syscall

    li   $v0, 5          # read integer
    syscall
    move $t4, $v0        # Save the user input in $t4

    # Initialize $t0 to point to the beginning of the buffer
    la   $a0, buffer
    move $t0, $a0  # Save the buffer address

    # Search for the day in the buffer
    day_loop3:
        lb $t5, 0($t0)
        # Check for newline character
        beq $t5, ':', compare_day3
        beq $t5, 0, no_appointment_found

        addi $t0, $t0, 1
        j day_loop3

    compare_day3:
        move $t9, $t0
        subi $t9, $t9, 1
        lb $t8, 0($t9)  # The first Day Digit is in $t8
        subi $t8, $t8, '0'  # convert to ASCII
        subi $t7, $t9, 1
        lb $s1, 0($t7)
        bge $s1, 48, blt_573

    blt_573:
        ble $s1, 57, the_num_is_Two_digits3

    the_num_is_Two_digits3:
        subi $s1, $s1, '0'
        mul $s1, $s1, 10
        add $s1, $s1, $t8


        beq $s1, $t4, found_day3
        j day_loop3

    found_day3:
        move $s3, $t0  # save the pointer in $s3
        j find_start_time3

find_start_time3:
    # Ask the user for start time
    la   $a0, start_time_prompt
    li   $v0, 4          # print string
    syscall

    li   $v0, 5          # read integer
    syscall
    move $t5, $v0  # Save the user input in $t5 (start time)

    # Find the start time in the line
    start_time_loop3:
        lb $t6, 0($s3)  # load the pointer in $t6
        beq $t6, '-', compare_start_time3  # if the pointer pointing to dash then go to function compare

        addi $s3, $s3, 1
        j start_time_loop3

    compare_start_time3:
        # Save the location of '-'
        move $t9, $s3

        sub $t2, $t9, 2  # for example 10-12 it reads 1 from number 10 
        lb $s5, 0($t2)
        subi $s5, $s5, '0'  # Convert ASCII to integer # t5 have the first digit from start time
        lb $s1, 1($t2)  # pointer go to the next digit 
        subi $s1, $s1, '0'  # Convert ASCII to integer # s1 have the second digit from start time
        mul $s5, $s5, 10  # Multiply current result by 10
        add $s1, $s1, $s5  # Add the new digit  S1 have the start time

        beq $s1, $t5, find_end_time3
        j no_appointment_found3

find_end_time3:
    # Save the location of '-'
    move $t9, $s3
    # Ask the user for end time
    la   $a0, end_time_prompt
    li   $v0, 4          # print string
    syscall

    li   $v0, 5          # read integer
    syscall
    move $t6, $v0  # Save the user input in $t6 (end time)

    # Find the end time in the line
    end_time_loop3:
        # Read the next two bytes after '-' as end time
        add $t3, $t9, 1  # for example, 10-12 it reads 1 from number 12
        lb $t4, 0($t3)
        subi $t4, $t4, '0'  # Convert ASCII to integer # t4 have the first digit from end time
        lb $t7, 1($t3)  # pointer go to the next digit
        subi $t7, $t7, '0'  # Convert ASCII to integer # s1 have the second digit from end time
        mul $t4, $t4, 10  # Multiply current result by 10
        add $t7, $t7, $t4  # Add the new digit  S1 have the end time

        beq $t7, $t6, delete_appointment_found
        j no_appointment_found3

delete_appointment_found:
  # Calculate the offset to the start time from the current position
    li $t8, 2           # Approximate length of one time slot (e.g., "08-10")
    sub $t9, $t9, $t8   # Move $t9 back to the start of the start time

    # Calculate the length of the appointment string to overwrite
    # This should include start time, dash, and end time
    li $t7, 8          # Length to overwrite, e.g., "08-10 M, "

    # Overwrite the appointment details with white spaces
    overwrite_loop:
        li $t8, ' '     # Load ASCII value of space character into $t8
        sb $t8, 0($t9)  # Overwrite the current character with a space
        addi $t9, $t9, 1 # Move to the next character
        addi $t7, $t7, -1 # Decrement the length counter
        bgtz $t7, overwrite_loop # Continue loop until the entire range is overwritten

    # After overwriting, continue with the rest of the function
    la   $a0, appointment_deleted_prompt
    li   $v0, 4          # Print string
    syscall
    jal print_buffer     # Call print_buffer to display updated buffer

    j menu_loop

    no_appointment_found3:
    la   $a0, no_appointment_prompt
    li   $v0, 4          # print string
    syscall
    j menu_loop
    
            jal print_buffer
########################################################################################################
# Function to print buffer content
print_buffer:
    # Load buffer address into $a0
    la   $a0, buffer

    # Print the null-terminated string in the buffer
    li   $v0, 4
    syscall
    
    li   $v0, 11
    li   $a0, '\n'
    syscall

    # Return from the function
    jr   $ra
