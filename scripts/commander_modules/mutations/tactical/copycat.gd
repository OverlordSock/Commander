extends Mutation
class_name Copycat

var weapon : String

func _init() -> void:
	self.mutationName = "Copycat"
	self.mutationDescription = "Causes to match the player's most used gun"
	self.mutationType = "Tactical"

func apply(enemy : Enemy):
	enemy.selectedWeapon = weapon
	enemy.weapon.SwitchWeapon(enemy.selectedWeapon)
	enemy.attackType = weapon + "_Attack"
