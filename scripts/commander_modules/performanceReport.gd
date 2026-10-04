extends Node
class_name PerformanceReport

# Performance report fields
var enemy : Node
var damageDealtToPlayer : int
var friendlyFireIncidents : int
var damageTakenFromPlayer : int
var mostUsedPlayerGun : String
var enemyID : int

# Constructor for performance report
func _init(
# Node reference to the enemy
enemy : Node,
# How much damage this enemy dealt to the player
damageDealtToPlayer : int,
# How many friendly fire incidents this enemy was responsible for, e.g. how many times it shot another enemy
friendlyFireIncidents : int,
# How much damage the enemy took from the player (less than their total health means another enemy hit them)
damageTakenFromPlayer : int,
# Which gun the player primarily used to damage the enemy
mostUsedPlayerGun : String,
# A persistent identifier for this enemy
enemyID: int
) -> void:
	# Set fields
	self.enemy = enemy
	self.damageDealtToPlayer = damageDealtToPlayer
	self.friendlyFireIncidents = friendlyFireIncidents
	self.damageTakenFromPlayer = damageTakenFromPlayer
	self.mostUsedPlayerGun = mostUsedPlayerGun
	self.enemyID = enemyID
