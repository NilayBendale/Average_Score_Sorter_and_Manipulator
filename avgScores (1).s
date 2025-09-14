.data
orig: .word 0:25	# Array to store original scores (25 words initialized to 0)
sorted: .word 0:25	# Array to store sorted scores (25 words initialized to 0)

# String prompts and messages
prompt_assign: .asciiz "Enter the number of assignments (between 1 and 25): "
prompt_score: .asciiz "Enter score: "
str_orig: .asciiz "Original scores: " 
str_sort: .asciiz "Sorted scores (in descending order): " 
prompt_drop: .asciiz "Enter the number of (lowest) scores to drop: "
str_avg: .asciiz "Average (rounded down) with dropped scores removed: "
drop_msg: .asciiz "All scores dropped!\n"
final_msg: .asciiz "-- program is finished running -–\n"
space: .asciiz " "
newline: .asciiz "\n"

.text
.globl main

# Function: main
# Description: Main program that orchestrates the score calculation process
# 1. Get number of assignments from user (1-25)
# 2. Collect scores for each assignment
# 3. Print original scores
# 4. Copy scores to a new array and sort in descending order
# 5. Print sorted scores
# 6. Get number of lowest scores to drop
# 7. Calculate and print average of remaining scores

# Register usage:
# $s0 - Number of assignments/scores
# $s1 - Base address of original scores array
# $s2 - Base address of sorted scores array
# $s3 - Number of scores to drop
# $t0-$t9 - Temporary values for calculations
# Stack usage:
# 0($sp) - Return address
main:
    addi $sp, $sp, -4	# Allocate space on stack
    sw $ra, 0($sp)	# Save return address

# Function: get_count
# Description: Gets and validates the number of assignments from user
# 1. Prompt user for number of assignments
# 2. Read integer input
# 3. Validate input is between 1 and 25
# 4. If invalid, ask again

# Register usage:
# $v0 - System call code and input value
# $s0 - Stored number of assignments
# Returns: 
# $s0 - Number of assignments (between 1 and 25)
get_count:
    li $v0, 4			# System call code for print_string
    la $a0, prompt_assign	# Load address of prompt string
    syscall			# Print the prompt
    li $v0, 5			# System call code for read_int
    syscall			# Read integer from user
    move $s0, $v0		# Store number of assignments in $s0
    ble $s0, 1, get_count	# If count <= 1, ask again
    bgt $s0, 25, get_count	# If count > 25, ask again

# Function: input_loop
# Description: Collects scores for each assignment
# 1. For each assignment (0 to count-1):
# a. Prompt user for score
# b. Read integer input
# c. Reject if score is 0 and restart
# d. Store score in orig array

# Register usage:
# $s1 - Base address of orig array
# $t0 - Loop counter
# $t2 - Byte offset for current element
# $t3 - Address of current element
# $v0 - System call code and input value
# Parameters:
# $s0 - Number of assignments
    la $s1, orig	# Load address of original scores array into $s1
    li $t0, 0		# Initialize counter for input loop

input_loop:
    beq $t0, $s0, print_orig	# If all scores are collected, go to print_orig
    li $v0, 4			# System call code for print_string
    la $a0, prompt_score	# Load address of score prompt
    syscall			# Print the prompt
    li $v0, 5			# System call code for read_int
    syscall			# Read integer from user
    beq $v0, $zero, get_count	# If score is 0, reject and restart
    sll $t2, $t0, 2		# $t2 = $t0 * 4 (calculate byte offset)
    add $t3, $s1, $t2		# $t3 = address of orig[counter]
    sw $v0, 0($t3)		# Store score in array
    addi $t0, $t0, 1		# Increment counter
    j input_loop		# Continue loop

# Function: print_orig
# Description: Prints the original scores array
# 1. Print header message
# 2. Call printArray function to display scores

# Register usage:
# $a0 - String address and array address parameter
# $a1 - Array length parameter
# $v0 - System call code
# Parameters:
# $s0 - Number of scores
# $s1 - Base address of orig array
print_orig:
    li $v0, 4		# System call code for print_string
    la $a0, str_orig	# Load address of original scores message
    syscall		# Print the message
    la $a0, orig	# Load address of original scores array
    move $a1, $s0	# Set array length parameter
    jal printArray	# Call printArray function

# Function: copy_loop
# Description: Copies original scores to sorted array
# 1. For each element in orig array:
# a. Copy value to corresponding position in sorted array

# Register usage:
# $s2 - Base address of sorted array
# $t1 - Loop counter
# $t2 - Byte offset for current element
# $t3 - Address of current element in orig
# $t4 - Value of current element
# $t5 - Address of current element in sorted
# Parameters:
# $s0 - Number of scores
# $s1 - Base address of orig array
copy_loop:
    la $s2, sorted	# Load address of sorted array into $s2
    li $t1, 0		# Initialize counter for copy loop
copy_loop_iter:
    beq $t1, $s0, sel_sort	# If all elements are copied, go to selection sort
    sll $t2, $t1, 2		# $t2 = $t1 * 4 (calculate byte offset)
    add $t3, $s1, $t2		# $t3 = address of orig[counter]
    lw  $t4, 0($t3)		# $t4 = value at orig[counter]
    add $t5, $s2, $t2		# $t5 = address of sorted[counter]
    sw  $t4, 0($t5)		# sorted[counter] = orig[counter]
    addi $t1, $t1, 1		# Increment counter
    j copy_loop_iter		# Continue loop

# Function: sel_sort
# Description: Sorts the scores in descending order using selection sort
# 1. For each position i from 0 to n-2:
# a. Find the maximum value in positions i to n-1
# b. Swap the maximum value with the value at position i

# Register usage:
# $t0 - Outer loop counter (i)
# $t1 - Array length - 1
# $t2 - Index of maximum element found so far
# $t3 - Inner loop counter (j)
# $t4, $t7 - Byte offsets for array access
# $t5, $t8 - Addresses of array elements
# $t6, $t9 - Values of array elements
# Parameters:
# $s0 - Number of scores
# $s2 - Base address of sorted array
sel_sort:
    li $t0, 0	# Initialize outer loop counter i = 0
sort_outer:
    addi $t1, $s0, -1		# $t1 = array length - 1
    bge $t0, $t1, print_sorted	# If i >= length-1, sorting is done
    move $t2, $t0		# $t2 = i (index of max element found so far)
    addi $t3, $t0, 1		# $t3 = i + 1 (inner loop counter j)
sort_inner:
    beq $t3, $s0, sort_swap	# If j == length, go to swap
    sll $t4, $t3, 2		# $t4 = j * 4 (byte offset for j)
    add $t5, $s2, $t4		# $t5 = address of sorted[j]
    lw $t6, 0($t5)		# $t6 = sorted[j]
    sll $t7, $t2, 2		# $t7 = max_index * 4 (byte offset for max_index)
    add $t8, $s2, $t7		# $t8 = address of sorted[max_index]
    lw $t9, 0($t8)		# $t9 = sorted[max_index]
    ble $t6, $t9, skip_upd	# If sorted[j] <= sorted[max_index], skip update
    move $t2, $t3		# Update max_index = j
skip_upd:
    addi $t3, $t3, 1		# Increment j
    j sort_inner		# Continue inner loop
sort_swap:
    sll $t4, $t0, 2		# $t4 = i * 4 (byte offset for i)
    sll $t7, $t2, 2		# $t7 = max_index * 4 (byte offset for max_index)
    add $t5, $s2, $t4		# $t5 = address of sorted[i]
    add $t6, $s2, $t7		# $t6 = address of sorted[max_index]
    lw $t1, 0($t5)		# $t1 = sorted[i]
    lw $t3, 0($t6)		# $t3 = sorted[max_index]
    sw $t3, 0($t5)		# sorted[i] = sorted[max_index]
    sw $t1, 0($t6)		# sorted[max_index] = sorted[i]
    addi $t0, $t0, 1		# Increment i
    j sort_outer
    
# Function: print_sorted
# Description: Prints the sorted scores array
# 1. Print header message
# 2. Call printArray function to display scores

# Register usage:
# $a0 - String address and array address parameter
# $a1 - Array length parameter
# $v0 - System call code
# Parameters:
# $s0 - Number of scores
# $s2 - Base address of sorted array
print_sorted:
    li $v0, 4		# System call code for print_string
    la $a0, str_sort	# Load address of sorted scores message
    syscall		# Print the message
    la $a0, sorted	# Load address of sorted array
    move $a1, $s0	# Set array length parameter
    jal printArray	# Call printArray function

# Function: get_drop
# Description: Gets and validates the number of scores to drop
# 1. Prompt user for number of scores to drop
# 2. Read integer input
# 3. Validate input is between 0 and n-1
# 4. If invalid, ask again

# Register usage:
# $v0 - System call code and input value
# $s3 - Stored number of scores to drop
# Parameters:
# $s0 - Total number of scores
# Returns:
# $s3 - Number of scores to drop
get_drop:
    li $v0, 4			# System call code for print_string
    la $a0, prompt_drop		# Load address of drop prompt
    syscall			# Print the prompt
    li $v0, 5			# System call code for read_int
    syscall			# Read integer from user
    move $s3, $v0		# Store number of scores to drop in $s3
    blt $s3, 0, get_drop	# If drop count < 0, ask again
    beq $s3, $s0, all_dropped	# If dropping all scores, show message
    bge $s3, $s0, get_drop	# If drop count >= total scores, ask again

# Description: Calculates and prints the average of remaining score
# 1. Calculate number of scores to keep (n - drop)
# 2. Call calcSum to get sum of kept scores
# 3. Divide sum by number of kept scores
# 4. Print average

# Register usage:
# $a0 - Array address parameter and string address
# $a1 - Number of scores to keep
# $t0 - Sum of kept scores
# $t1 - Average (quotient)
# $t4 - Saved copy of number of scores to keep
# $v0 - System call code and return value from calcSum
# Parameters:
# $s0 - Total number of scores
# $s2 - Base address of sorted array
# $s3 - Number of scores to drop
    sub $a1, $s0, $s3      # $a1 = number of scores to keep
    move $t4, $a1          # Save number of scores to keep in $t4
    la $a0, sorted         # Load address of sorted array
    jal calcSum            # Calculate sum of kept scores
    move $a1, $t4          # Restore number of scores to keep
    move $t0, $v0          # $t0 = sum of kept scores
    div $t0, $a1           # Divide sum by number of kept scores
    mflo $t1               # $t1 = quotient (average)

    li $v0, 4              # System call code for print_string
    la $a0, str_avg        # Load address of average message
    syscall                # Print the message
    li $v0, 1              # System call code for print_int
    move $a0, $t1          # Load average to print
    syscall                # Print the average
    li $v0, 4              # System call code for print_string
    la $a0, newline        # Load address of newline
    syscall                # Print newline
    li $v0, 4              # System call code for print_string
    la $a0, final_msg      # Load address of final message
    syscall                # Print final message
    j end                  # Jump to end

# Function: all_dropped
# Description: Handles the case where all scores are dropped
# 1. Print message indicating all scores were dropped
# 2. Print final message
# Register usage:
# $a0 - String address
# $v0 - System call code
all_dropped:
    li $v0, 4              # System call code for print_string
    la $a0, drop_msg       # Load address of all dropped message
    syscall                # Print the message
    li $v0, 4              # System call code for print_string
    la $a0, final_msg      # Load address of final message
    syscall                # Print final message

# Function: end
# Description: Cleans up and exits the program
# 1. Restore return address
# 2. Deallocate stack space
# 3. Exit program

# Register usage:
# $ra - Return address
# $v0 - System call code
end:
    lw $ra, 0($sp)         # Restore return address
    addi $sp, $sp, 4       # Deallocate stack space
    li $v0, 10             # System call code for exit
    syscall     
    
# Function: printArray
# Description: Prints all elements of an array with spaces between them
# 1. For each element in the array:
# a. Load the element value
# b. Print the value
# c. Print a space
# 2. Print a newline at the end

# Register usage:
# $t0 - Loop counter
# $t1 - Byte offset for current element
# $t2 - Address of current element
# $t3 - Value of current element
# Parameters:
# $a0 - Base address of the array
# $a1 - Number of elements in the array
# Stack usage:
# 0($sp) - Return address
# 4($sp) - Array address
# 8($sp) - Array length
printArray:
    addi $sp, $sp, -12     # Allocate stack space for 3 words
    sw $ra, 0($sp)         # Save return address
    sw $a0, 4($sp)         # Save array address
    sw $a1, 8($sp)         # Save array length
    li $t0, 0              # Initialize counter
pr_loop:
    lw $a1, 8($sp)         # Reload array length
    beq $t0, $a1, pr_done  # If counter == length, it's done
    lw $a0, 4($sp)         # Reload array address
    sll $t1, $t0, 2        # $t1 = counter * 4 (byte offset)
    add $t2, $a0, $t1      # $t2 = address of array[counter]
    lw $t3, 0($t2)         # $t3 = array[counter]
    move $a0, $t3          # Set value to print
    li $v0, 1              # System call code for print_int
    syscall                # Print the integer
    li $v0, 4              # System call code for print_string
    la $a0, space          # Load address of space
    syscall                # Print space
    addi $t0, $t0, 1       # Increment counter
    j pr_loop              # Continue loop
pr_done:
    li $v0, 4              # System call code for print_string
    la $a0, newline        # Load address of newline
    syscall                # Print newline
    lw $ra, 0($sp)         # Restore return address
    addi $sp, $sp, 12      # Deallocate stack space
    jr $ra                 # Return to caller

# Function: calcSum
# Description: Recursively calculates the sum of the first n elements in an array
# Base case: If n <= 0, return 0
# Recursive case: Return array[n-1] + calcSum(array, n-1)

# Stack usage:
#   0($sp) - Return address
#   4($sp) - Array address
#   8($sp) - Original n value
#   12($sp) - n-1 value for recursive call
# Parameters:
# $a0 - Base address of the array
# $a1 - Number of elements to sum (n)
# Returns:
# $v0 - Sum of the first n elements
calcSum:
    addi $sp, $sp, -16     # Allocate stack space for 4 words
    sw $ra, 0($sp)         # Save return address
    sw $a0, 4($sp)         # Save array address
    sw $a1, 8($sp)         # Save number of elements
    blez $a1, cs_base      # If n <= 0, go to base case
    addi $a1, $a1, -1      # Decrement n
    sw $a1, 12($sp)        # Save n-1
    jal calcSum            # Recursive call to sum first n-1 elements
    lw $a0, 4($sp)         # Reload array address
    lw $a1, 12($sp)        # Reload n-1
    sll $t0, $a1, 2        # $t0 = (n-1) * 4 (byte offset) 
    add $t1, $a0, $t0      # $t1 = address of array[n-1]
    lw $t2, 0($t1)         # $t2 = array[n-1]
    add $v0, $v0, $t2      # Add array[n-1] to sum
    j cs_done              # Jump to done
cs_base:
    li $v0, 0              # Base case: return 0
cs_done:
    lw $ra, 0($sp)         # Restore return address
    addi $sp, $sp, 16      # Deallocate stack space
    jr $ra                 # Return to caller
