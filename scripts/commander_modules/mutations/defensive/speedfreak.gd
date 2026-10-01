extends Mutation
class_name SpeedFreak

func _init() -> void:
	self.mutationName = "Speed Freak"
	self.mutationDescription = "Doubles enemy movement speed"
	self.mutationType = "Defensive"

func apply(enemy : Enemy):
	enemy.movementSpeed = enemy.movementSpeed * 2
