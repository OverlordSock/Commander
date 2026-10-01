extends Mutation
class_name BulletSponge

func _init() -> void:
	self.mutationName = "Bullet Sponge"
	self.mutationDescription = "Doubles enemy health"
	self.mutationType = "Defensive"

func apply(enemy : Enemy):
	enemy.enemyHealth = enemy.enemyHealth * 2
