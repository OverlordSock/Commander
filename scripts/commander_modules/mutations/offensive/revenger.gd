extends Mutation
class_name Revenger

func _init() -> void:
	self.mutationName = "Revenger"
	self.mutationDescription = "Causes the enemy to explode on death"
	self.mutationType = "Offensive"

func apply(enemy : Enemy):
	enemy.explodeOnDeath = true
