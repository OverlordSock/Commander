extends Area2D

# Class identifier to let bullets and swords reliably detect hitboxes
class_name Hitbox

@onready var parent = get_parent()

# Damage function to pass damage dynamically to parent (either enemy or player)
# By using this function only if the damage is done to a Hitbox class object instead of any collision,
# we avoid calling functions on collision shapes that are not damageable
func Hit(damage, hitByPlayer):
	parent.takeDamage(damage, hitByPlayer)
