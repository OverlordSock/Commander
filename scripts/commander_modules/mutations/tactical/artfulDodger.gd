extends Mutation
class_name ArtfulDodger

func _init() -> void:
	self.mutationName = "Artful Dodger"
	self.mutationDescription = "Causes the enemy to dodge if they are targeted by another enemy"
	self.mutationType = "Tactical"

func apply(enemy : Enemy):
	enemy.dodger = true
