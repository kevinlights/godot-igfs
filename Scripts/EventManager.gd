extends Node

var listeners = {}

func _ready():
    pass

# void listen(string event, funcref callback)
# adds a function reference to the list of listeners for the given named event
func listen(event, callback):
    if not listeners.has(event):
        listeners[event] = []
    listeners[event].append(callback)

# void ignore(string event, funcref callback)
# removes a function reference from the list of listeners for the given named event
func ignore(event, callback):
    if listeners.has(event):
        if listeners[event].find(callback) != -1:
            listeners[event].erase(callback)

# void raise(string event, object args)
# calls each callback in the list of callbacks in listeners for the given named event, passing args to each
func emit(event, args):
    if listeners.has(event):
        for callback in listeners[event]:
            # print(listeners)
            callback.call_func(args)
