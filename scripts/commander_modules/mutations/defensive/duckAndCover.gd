extends Mutation
class_name DuckAndCover

func _init() -> void:
	self.mutationName = "Duck And Cover"
	self.mutationDescription = "Gives the enemy a high chance to seek cover on taking damage"
	self.mutationType = "Defensive"

func apply(enemy : Enemy):
	enemy.duckAndCover = true
