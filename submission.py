# F1
# takes as an input a string of space separated integers that is split and converted to a list
def multiply_list(numbers):
    #split space separated string into a list of integers
    num = [int(x) for x in numbers.split()]

    #if empty list, return 0
    if not num:
        return 0

    #initialize result to 1
    result = 1

    #multiply all numbers in the list
    for n in num:
        result *= n

    return result   

# Test cases for F1

    

# F2
# takes in a string with two words, separated by a single white space. Find the number of unique characters that the strings have in common

# split the input string into two words
def count_common_chars(string):
    str1 , str2 = string.split()

    #Find the unique characters in each word

    unq1 = set(str1)
    unq2 = set(str2)

    return len(unq1 & unq2)

# Test cases for F2


# F3
# finds the sum of the numbers from 1 to N (inclusive) that are divisible by K
 
def sum_divisible_by_k(N,K):

    # Impossible cases
    if K <= 0: 
        return -1

    if N <= 0:
        return -1

    tsum = 0

    # Set Range N inclusive
    for num in range(1, N + 1):
        # %k == 0 is true when a number from 1 to N is divisible by K
        if num % K == 0:
            tsum += num
    return tsum

# Test Cases for F3

print(sum_divisible_by_k(5,2))

# F4
# find the highest common factor of the 2 numbers
# assume both integers are positive and non zero

def highest_common_factor(a,b):
    
    # GCF can't exceed the smaller of the two numbers
    start = min(a,b)

    # Start from the largest possible factor then work down
    for n in range(start, 0, -1):
        if a % n == 0 and b % n == 0:
            return n

print( highest_common_factor(8,6))
