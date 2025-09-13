# Lab 2


### function 1:

Analyze the following function with respect to number

```python
def function1(number):
	total=0;

	for i in range(0,number):
		x = (i+1)
		total+=(x*x)

	return total
```

### function 2:

Analyze the following function with respect to number

```python
def function2(number):
	return  ((number)*(number+1)*(2*number + 1))/6

```

### function 3:

Analyze the following with respect to the length of the list.  Note that the function call len() which returns the length of the list is constant (O(1)) with respect to the length of the list.
```python

def function3(list):
	for i in range (0,len(list)-1):
		for j in range(0,len(list)-1-i):
			if(list[j]>list[j+1]):
				tmp=list[j]
				list[j]=list[j+1]
				list[j+1]=tmp

```
### function 4:

Analyze the following function with respect to number

```python
def function4(number):
	total=1
	for i in range(1 to number):
		total=total*(i+1)
	return total
```


## In class portion


### Group members
List the members of your group member below:

	* FirstName LastName
		 ex. Samuel Vimes
	* ...


1. What do the functions do?



2. **WITHOUT DOING AN ANALYSIS** (so by gut feeling alone), rank your 3 functions individually... does your group's rankings match?



3. Run lab2timing.py.  Does the timing validate your ranking?  Any surprises?


4. Analyze at least one of the 3 functions ( one(), two() or three() ):




5. Run lab2timing.py with increasing values of the amount of data (increase by 1000 each time).  Is there a pattern? (Note: ensure that you are using the same "machine" as you change the data size.  Ideally a local computer to avoid inconsistencies).  Does the timing reflect what you expect based on your analysis?



