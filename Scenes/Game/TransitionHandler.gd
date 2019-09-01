extends Node

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func transition_helper(start,end,amount,power,callback):
	var transition_results = transition(start,end,amount,power)
	for result in transition_results:
		callback.call_func(result)

func transition(start,end,amount,power):
	var res = []
	for i in range(amount - 1):
		res.append(0)

	res[0] = start

	if start > 0 && start > 1:
		for index in res.size():
			if index != 0:
				res[index] = pow(res[index - 1],1/power)
	elif start > 0 && start < 1:
		for index in res.size():
			if index != 0:
				res[index] = pow(res[index - 1],power)
	elif start < 0 && start < -1:
		for index in res.size():
			if index != 0:
				res[index] = pow(abs(res[index - 1]),1/power) * -1
	elif start < 0 && start > -1:
		for index in res.size():
			if index != 0:
				res[index] = pow(abs(res[index - 1]),power) * -1
	
	
		
	res.append(end)
	return res
