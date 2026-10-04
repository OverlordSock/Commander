extends Node
class_name Mutation

# Name and description of mutation (for reporting)
var mutationName : String = "Mutation"
var mutationDescription : String = "Basic mutation"
var mutationType : String
var successful : bool

# Superclass for mutations, none have shared fields as each mutation affects different statistics
# Apply method will apply the mutation to the enemy, but will be overriden by each mutation subclass
func apply(enemy: Enemy):
	pass
