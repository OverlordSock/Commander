extends Node
class_name MutationBundle

# This class holds a list of mutations for an enemy to allow the enemy's mutation list to persist when
# the level is reset, as all non-global scripts and objects are reset.
var enemyID : int
var mutations : Array[Mutation]

# Initialise mutation bundle
func _init(enemyID : int, enemyMutations : Array[Mutation]) -> void:
	self.enemyID = enemyID
	self.mutations = enemyMutations
