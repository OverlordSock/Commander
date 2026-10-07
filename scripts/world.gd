extends Node2D
class_name World

# Script to control level ending and level resetting

var enemyCount: int
var enemies : Array[Enemy] = []
@onready var menu : MenuUI = $MenuUI

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# The ready function needs to prepare the enemies and give them their mutationBundles from the Commander
	prepEnemies()
	$MenuUI.visible = true

# Function to decrease enemy count and check if all enemies have died, called by enemies on death
func enemyDeath():
	if enemyCount > 1:
		enemyCount -= 1
	else:
		endLevel(true)

# Function to prepare enemies for level, separated from _ready() because it needs to be called at certain times
func prepEnemies():
	# Get all enemies in level
	for child in get_children():
		if child is Enemy:
			enemies.append(child)
	# Update enemy count
	enemyCount = enemies.size()
	
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
func endLevel(win : bool):
	CombatTracker.generatePerformanceReports()
	menu.visible = true
	menu.endLevel(enemies, win)

# Function to reset the level
func resetLevel():
	# Tell the Commander to prepare the reports arrays for the next level
	Commander.shuffleReports()
	CombatTracker.refresh()
	# Reset the scene tree, reloading the level and all non-global objects and scripts
	get_tree().reload_current_scene()
	# This is deferred, so will only occur when all code in this method is finished executing, which is why we cannot 
	# manage the things that need to persist into the next level here (mutations), instead that must be managed by
	# the global Commander script
