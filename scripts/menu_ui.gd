extends CanvasLayer
class_name MenuUI

@onready var world : World = get_tree().current_scene
var background : ColorRect

var enemyStats : Array[EnemyStats] = []

# Using the ready function to populate the enemyStats list with all of the enemyStat displays
func _ready() -> void:
	background = world.get_node("UIBackground")
	for node in self.get_children():
		if node is EnemyStats:
			enemyStats.append(node)

#Function to fade the menu out
func fadeOut():
	# Start the background at fully transparent
	background.modulate.a = 0.0
	background.show()
	# Create a tween
	var tween: Tween = create_tween()
	# Animate the 'modulate:a' property to 1.0 (fully opaque)
	tween.tween_property(background, "modulate:a", 1.0, 1.0)\
		.set_trans(Tween.TRANS_CUBIC)\
		.set_ease(Tween.EASE_OUT)

#Function to fade the menu in
func fadeIn():
	# Start the background at fully opaque
	background.modulate.a = 1.0
	background.show()
	# Create a tween
	var tween: Tween = create_tween()
	# Animate the 'modulate:a' property to 0.0 (fully transparent)
	tween.tween_property(background, "modulate:a", 0.0, 1.0)\
		.set_trans(Tween.TRANS_CUBIC)\
		.set_ease(Tween.EASE_OUT)

# Function to bring up the end of level UI
func endLevel(enemies : Array[Enemy], win : bool):
	fadeOut()
	if win:
		$Victory.visible = true
	else:
		$Defeat.visible = true
	# For each enemy
	for i in enemies.size():
		# Fill an enemyStats block
		enemyStats[i].fill(enemies[i].mutations, enemies[i].enemyID)
	$ContinueButton.visible = true

# Function to display the description of a mutation
func setDesc(description : String):
	$MutationDescription.text = description

# Function to start the game when the play button is pressed
func _on_play_button_pressed() -> void:
	$PlayButton.visible = false
	fadeIn()

# Function to restart the level when the restart button is pressed
func _on_restart_button_pressed() -> void:
	world.resetLevel()

func _on_continue_button_pressed() -> void:
	# Hide previous menu
	$Victory.visible = false
	$Defeat.visible = false
	$ContinueButton.visible = false
	# Show end menu
	$Title.visible = true
	$Description.visible = true
	$RedInfo.visible = true
	$GreenInfo.visible = true
	$EnemyStats1.visible = true
	$EnemyStats2.visible = true
	$EnemyStats3.visible = true
	$EnemyStats4.visible = true
	$EnemyStats5.visible = true
	$MutationDescription.visible = true
	$RestartButton.visible = true
