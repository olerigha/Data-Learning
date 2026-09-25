import pandas as pd
import numpy as np

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
# print(multiply_list("1 2 3 4"))
    

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
# print(count_common_chars("green red"))

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

# print(sum_divisible_by_k(5,2))

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

# Test Cases for F4
# print( highest_common_factor(8,6))


# F5
# return minimum of the list data

# def get_minimum(list):
#     return min(list)

def get_minimum(list):

    if not list:
        return None
    
    small = list[0]

    for n in list:
        if n < small:
            small = n
    
    return small


# Test Cases for F5
# print(get_minimum([3, 1, 4, 1, 5, 9, 2, 6]))

# F6
# accepts three arguments, a dataframe, old column name and the new column name. In the function, update the column name from old to the new and return the modified dataframe

def rename_col(df,old_name,new_name):
    df = df.rename(columns={old_name: new_name})
    return df

# F7
# accepts a series and returns the standard deviation of that series

def standard_deviation(series):
    return series.std()

# F8

def correlation_sum(a):
    numbers = [int(x) for x in a.split()]

    if len(numbers) != 9:
        return 0

    df = pd.DataFrame(np.array(numbers).reshape(3, 3))

    return round(df.corr().values.sum(), 1)

print(correlation_sum("1 2 3 4 5 6 7 8 9"))
print(correlation_sum("1 2 3 4 5 6"))
print(correlation_sum("1 2 3 45 5 6 7 10 9"))