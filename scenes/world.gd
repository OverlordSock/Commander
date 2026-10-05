extends Node2D

# Script to control level ending and level resetting

var enemyCount: int

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# The ready function needs to prepare the enemies and give them their mutationBundles from the Commander
	prepEnemies()

# Function to decrease enemy count and check if all enemies have died, called by enemies on death
func enemyDeath():
	if enemyCount != 0:
		enemyCount -= 1
	else:
		endLevel()

# Function to prepare enemies for level, separated from _ready() because it needs to be called at certain times
func prepEnemies():
	# Get all enemies in level
	var enemies : Array[Enemy] = []
	for child in get_children():
		if child is Enemy:
			enemies.append(child)
	# Update enemy count
	var enemyCount = enemies.size()
	# Reassign mutations to enemies
	if !Commander.getBundles().is_empty() and enemies.size() < 0:
		reassignMutations(enemies)

# Function to reassign mutations to enemies
func reassignMutations(enemies : Array[Enemy]):
	for bundle in Commander.getBundles():
		for enemy in enemies:
			if bundle.enemyID == enemy.enemyID:
				enemy.mutations = bundle.mutations
				# Break early, match found
				break

# Function to end the level and display Commander decisions
func endLevel():
	# TODO
	pass

# Function to reset the level
func resetLevel():
	# Tell the Commander to prepare the reports arrays for the next level
	Commander.shuffleReports()
	# Reset the scene tree, reloading the level and all non-global objects and scripts
	get_tree().reload_current_scene()
	# This is deferred, so will only occur when all code in this method is finished executing, which is why we cannot 
	# manage the things that need to persist into the next level here (mutations), instead that must be managed by
	# the global Commander script
