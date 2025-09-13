# Write the code for your lab 1 here.  Read the specs carefully.  
# Function name must be exactly as provided.  
# Names of variables and parameters can be whatever you wish it to be
#
# To test, run the following command :
#     python test_lab1.py
#
# Author: Shubham Dharmendrabhai Kandoi
# Student Number: 144838232
# Date: 18-05-2025

# Function 1
def wins_rock_scissors_paper(player, opponent):
    player = player.lower()
    opponent = opponent.lower()

    if player == opponent:
        return False
    if (player == "rock" and opponent == "scissors") or \
       (player == "paper" and opponent == "rock") or \
       (player == "scissors" and opponent == "paper"):
        return True
    return False

# Function 2
def factorial(n):
    result = 1
    for i in range(2, n + 1):
        result *= i
    return result


# Function 3
def fibonacci(n):
    if n == 0:
        return 0
    elif n == 1:
        return 1

    a, b = 0, 1
    for _ in range(2, n + 1):
        a, b = b, a + b
    return b

#Function 4
def sum_to_goal(numbers, goal):
    seen = set()
    for num in numbers:
        complement = goal - num
        if complement in seen:
            return num * complement
        seen.add(num)
    return 0

# Class 1

class UpCounter:
    def __init__(self, step=1):
        self.step = step
        self.value = 0

    def count(self):
        return self.value

    def update(self):
        self.value += self.step
        

# Class 2

class DownCounter(UpCounter):
    def update(self):
        self.value -= self.step








    
