extends Node
class_name CombatEvent

# Fields for CombatEvent class
var attacker: Node
var victim: Node
var damage: int
var weapon: String
var timestamp: int

# Constructor for CombatEvent, takes an attacker, victim, damage value, and timestamp
func _init(attacker: Node, victim: Node, damage: int, timestamp: int):
	# Attacker is either player or enemy
	self.attacker = attacker
	# Victim is either player or enemy
	self.victim = victim
	self.damage = damage
	# Check damage value to determine what gun type the attack came from
	if(damage == 5):
		self.weapon = "SMG"
	elif(damage == 7):
		self.weapon = "Shotgun"
	else:
		self.weapon = "Pistol"
	# Timestamp as a source of truth for order of events
	self.timestamp = timestamp
