extends Mutation
class_name DakkaDakkaDakka

func _init() -> void:
	self.mutationName = "Dakka Dakka Dakka"
	self.mutationDescription = "Doubles the enemy magazine size"
	self.mutationType = "Offensive"

func apply(enemy : Enemy):
	enemy.magSize = enemy.magSize * 2
