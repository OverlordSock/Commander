extends Node

# Array to store combat events
var combat_events : Array[CombatEvent] = []
# Array to store one reference variable for every enemy that engages or is engaged in combat
var enemies : Array[Enemy] = []
# Array to store events related to a particular enemy, overwritten per enemy processed for memory efficiency
var enemy_events : Array[CombatEvent] = []

# Function to record combat events
func recordEvent(event : CombatEvent):
	combat_events.append(event)
	# Checking if the attacker or victim is an enemy
	if event.attacker is Enemy:
		# Checking if the enemy is not recorded in the enemies array
		if not event.attacker in enemies:
			# Adding the enemy to the enemies array
			enemies.append(event.attacker)
	elif event.victim is Enemy:
		if not event.victim in enemies:
			enemies.append(event.victim)

# Filter function to return all combat events related to a given enemy
func getEnemyEvents(enemy: Node) -> Array[CombatEvent]:
	# Empty the events list
	enemy_events.clear()
	# Iterate though all events
	for event in combat_events:
		# Append event to return array if the attacker or victim was an enemy
		if event.attacker == enemy or event.victim == enemy:
			enemy_events.append(event)
	# Return the enemy_events array, may be empty if enemy was not involved in combat
	return enemy_events

# Function to check events for every enemy with recorded combat and generate a performance report for each enemy
func generatePerformanceReports():
	for enemy in enemies:
		# Get all of the events for this enemy, skip this enemy if no events are returned
		var events = getEnemyEvents(enemy)
		if events.size() == 0:
			continue
		# Variables for events where enemy was the attacker
		var damageDealtToPlayer = 0
		var friendlyFireIncidents = 0
		# Variables for events where enemy was the victim
		var damageTakenFromPlayer = 0
		var playerPistolEventCount = 0
		var playerSMGEventCount = 0
		var playerShotgunEventCount = 0
		var mostUsedPlayerGun = "None"
		
		# Loop through returned events
		for event in events:
			# If the enemy was the attacker
			if event.attacker == enemy:
				# Record damage to player if victim was the player, or record a friendly fire incident otherwise
				if event.victim is Player:
					damageDealtToPlayer += event.damage
				else:
					friendlyFireIncidents += 1
			# If the enemy was the victim
			elif event.victim == enemy:
				# If the attacker was the player, record the damage and determine which weapon was used
				if event.attacker is Player:
					damageTakenFromPlayer += event.damage
					# Determine which weapon was used
					if event.damage == 20:
						playerPistolEventCount += 1
					elif event.damage == 5:
						playerSMGEventCount += 1
					elif event.damage == 7:
						playerShotgunEventCount += 1
		
		# All events checked, generate performance report for this enemy
		# Determine which weapon the player primarily used to kill this enemy
		if damageTakenFromPlayer != 0:
			if playerPistolEventCount > playerSMGEventCount and playerPistolEventCount > playerShotgunEventCount:
				mostUsedPlayerGun = "Pistol"
			elif playerSMGEventCount > playerPistolEventCount and playerSMGEventCount > playerShotgunEventCount:
				mostUsedPlayerGun = "SMG"
			elif playerShotgunEventCount > playerPistolEventCount and playerShotgunEventCount > playerSMGEventCount:
				mostUsedPlayerGun = "Shotgun"
			# In case of a tie, indicate that a variety of weapons was used
			else:
				mostUsedPlayerGun = "Variety"
		
		# Create a performance report from the event data
		var performance : PerformanceReport = PerformanceReport.new(
			enemy,
			damageDealtToPlayer,
			friendlyFireIncidents,
			damageTakenFromPlayer,
			mostUsedPlayerGun
		)
		# Send report for this enemy to the commander
		Commander.report(performance)
