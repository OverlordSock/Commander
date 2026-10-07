extends Control
class_name EnemyStats

# Text fields
@onready var id = $enemyID
@onready var offensive = $OffensiveLabel/offensiveTitle
@onready var defensive = $DefensiveLabel/defensiveTitle
@onready var tactical = $TacticalLabel/tacticalTitle
@onready var ui = self.get_parent()

# Mutations
var offensiveMut : Mutation = null
var defensiveMut : Mutation = null
var tacticalMut : Mutation = null

# Function to update text boxes with info
func fill(mutations : Array[Mutation], enemyID : int):
	$enemyID.text = "Enemy " + str(enemyID)
	# Loop through mutation list and cache mutations for description switching, update text fields
	for mutation in mutations:
		if mutation.mutationType == "Offensive":
			# Cache mutation
			offensiveMut = mutation
			# Update text field
			offensive.text = mutation.mutationName
			# Change text color depending on success of mutation
			if mutation.successful:
				$OffensiveLabel.add_theme_color_override("font_color", Color.GREEN)
			else:
				$OffensiveLabel.add_theme_color_override("font_color", Color.RED)
		elif mutation.mutationType == "Defensive":
			defensiveMut = mutation
			defensive.text = mutation.mutationName
			if mutation.successful:
				$DefensiveLabel.add_theme_color_override("font_color", Color.GREEN)
			else:
				$DefensiveLabel.add_theme_color_override("font_color", Color.RED)
		elif mutation.mutationType == "Tactical":
			tacticalMut = mutation
			tactical.text = mutation.mutationName
			if mutation.successful:
				$TacticalLabel.add_theme_color_override("font_color", Color.GREEN)
			else:
				$TacticalLabel.add_theme_color_override("font_color", Color.RED)

# Function to update the UI description field, called by button signals below
func changeDescription(mutationDesc : String):
	ui.setDesc(mutationDesc)

func _on_offensive_title_pressed() -> void:
	changeDescription(offensiveMut.mutationDescription)

func _on_defensive_title_pressed() -> void:
	changeDescription(defensiveMut.mutationDescription)

func _on_tactical_title_pressed() -> void:
	changeDescription(tacticalMut.mutationDescription)
