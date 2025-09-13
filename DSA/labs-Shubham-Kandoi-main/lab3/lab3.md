# Reflection for Lab 3

## Part A: Analysis

### function 1:


```python
def function1(value, number):
	if (number == 0):
		return 1
	elif (number == 1):
		return value
	else:
		return value * function1(value, number-1)
```

### function 2:


```python

def recursive_function2(mystring,a, b):
	if(a >= b ):
		return True
	else:
		if(mystring[a] != mystring[b]):
			return False
		else:
			return recursive_function2(mystring,a+1,b-1)

def function2(mystring):
	return recursive_function2(mystring, 0,len(mystring)-1)

```

### function 3 (optional):


```python
def function3(value, number):
	if (number == 0):
		return 1
	elif (number == 1):
		return value
	else:
		half = number // 2
		result = function3(value, half)
		if (number % 2 == 0):
			return result * result
		else:
			return value * result * result

```

## Part C reflection

Answer the following questions

1. Describe the process of analyzing recursive functions.  How does it differ from from analyzing non-recursive functions?  How is it the same?
2. Described what you learned in the implementation for the linked lists.  What approach did you take?  What bugs did you find most difficult to fix.


