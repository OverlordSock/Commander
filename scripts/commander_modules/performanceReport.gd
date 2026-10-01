extends Node
class_name PerformanceReport

# Performance report fields
var enemy : Node
var damageDealtToPlayer : int
var friendlyFireIncidents : int
var damageTakenFromPlayer : int
var mostUsedPlayerGun : String

# Constructor for performance report
func _init(
# Which enemy this report is for
enemy : Node,
# How much damage this enemy dealt to the player
damageDealtToPlayer : int,
# How many friendly fire incidents this enemy was responsible for, e.g. how many times it shot another enemy
friendlyFireIncidents : int,
# How much damage the enemy took from the player (less than their total health means another enemy hit them)
damageTakenFromPlayer : int,
# Which gun the player primarily used to damage the enemy
mostUsedPlayerGun : String
) -> void:
	# Set fields
	self.enemy = enemy
	self.damageDealtToPlayer = damageDealtToPlayer
	self.friendlyFireIncidents = friendlyFireIncidents
	self.damageTakenFromPlayer = damageTakenFromPlayer
	self.mostUsedPlayerGun = mostUsedPlayerGun
