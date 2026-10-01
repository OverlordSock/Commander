extends Mutation
class_name BoomBringer

func _init() -> void:
	self.mutationName = "Boom Bringer"
	self.mutationDescription = "The enemy equips a shotgun with explosive pellets"
	self.mutationType = "Offensive"

func apply(enemy : Enemy):
	enemy.selectedWeapon = "Shotgun"
	enemy.weapon.SwitchWeapon(enemy.selectedWeapon)
	enemy.attackType = "Shotgun_Attack"
	enemy.explosiveRounds = true
