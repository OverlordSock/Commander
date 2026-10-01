extends Mutation
class_name GoodFriend

func _init() -> void:
	self.mutationName = "Good Friend"
	self.mutationDescription = "Causes to cease fire when they target another enemy"
	self.mutationType = "Tactical"

func apply(enemy : Enemy):
	enemy.goodFriend = true
