extends CharacterBody2D
class_name Enemy

@export var enemyID : int

# Onready variables to refer to nodes once they are instantiated
@onready var anim_tree = $AnimationTree
@onready var player = $"../Player"

# Enemy weapon settings, adds custom dropdown box to the enemy settings to choose one of 3 weapons for the enemy
@onready var weapon = $Gun
@export_group("Weapon Settings")
@export_enum("Pistol", "SMG", "Shotgun") var selectedWeapon : String  = "Pistol"
@onready var attackType : String = selectedWeapon + "_Attack"
var weaponRange = 0
var canShoot = false
var reloading = false
var magSize = 1

# Enemy stat variables
@onready var healthbar = $Healthbar
@onready var damageTimer = $DamageCooldown
@onready var collision = $Collision
@onready var hitbox = $Hitbox
var movementSpeed = 150.0
var enemyHealth = 100
var invuln = false
var dead = false

# Player detection
@onready var vision = $LineOfSight
@onready var navigator = $NavigationAgent2D
@onready var navTimer = $IdleMovementTimeout
var playerDetected = false
var playerVisible = false
var detectionRange = 1500
var damagedByPlayer = false
var navigationDirection = Vector2.ZERO
var playerLastPosition = Vector2.ZERO
var homePosition = Vector2.ZERO

# Mutation variables
var mutations : Array[Mutation] = []
var goodFriend = false # Avoids friendly fire when true

# Initialise the enemy variables on enemy instantiation
func _ready() -> void:
	# Mutations init
	if !mutations.is_empty():
		for mutation : Mutation in mutations:
			mutation.apply(self)
	# Home position init
	homePosition = global_position
	# Healthbar init
	healthbar.init_health(enemyHealth)
	# Weapon type init
	weapon._attackType = attackType
	weapon.SwitchWeapon(selectedWeapon)
	# Weapon target and range init
	weapon.aimTarget = player
	if selectedWeapon == "Pistol":
		weaponRange = 1000
		# init magSize * intended magSize to let Dakka Dakka Dakka apply properly, will make the init magSize 2
		# so * 2 mag instead of * 1
		magSize = magSize * 7
		# Initialise magCount, the actual count of bullets in the magazine
		weapon.magSize = magSize
	elif selectedWeapon == "SMG":
		weaponRange = 750
		magSize = magSize * 15
		weapon.magSize = magSize
	elif selectedWeapon == "Shotgun":
		weaponRange = 500
		magSize = magSize * 2
		weapon.magSize = magSize

# Called every frame
func _process(delta: float) -> void:
	if !dead: # Stops checks if enemy is dead
		# Check if distance between enemy and player is within enemy detection range
		if global_position.distance_to(player.global_position) <= detectionRange:
			# Player within detection range, check for line of sight to player
			playerDetected = true
			vision.target_position = to_local(player.global_position)
			if vision.is_colliding():
				# If line of sight collides with player
				if vision.get_collider() is Player:
					# Player is visible, set the last known position of the player
					playerVisible = true
					playerLastPosition = player.global_position
					canShoot = true
				# If line of sight collides with an enemy, and the player was just visible, meaning that another 
				# enemy is blocking line of sight to the player
				# If the enemy is a Good Friend, block this action
				elif vision.get_collider() is Enemy and playerVisible and !goodFriend :
					# Enemy can still shoot, potentially causing friendly fire
					canShoot = true
				else:
					playerVisible = false
					canShoot = false
		# If the player is outside of detection range and has not damaged the enemy, the enemy cannot detect the player
		elif !damagedByPlayer:
			playerDetected = false
		# Aim at the player if player is detected by the enemy
		if playerVisible:
			weapon.aimAtPlayer = true
		else:
			weapon.aimAtPlayer = false

# Enemy movement controlled here
func _physics_process(delta: float) -> void:
	# If the enemy can see the player, update their movement goal to the player position
	if playerVisible:
		navigator.target_position = playerLastPosition
		if canShoot and !reloading and !dead:
			Shoot()
	# If the enemy cannot see the player and has not reached the player's last known position, move toward it
	elif !playerVisible and !navigator.is_target_reached():
		# Set navigation direction to next navigation point
		navigationDirection = to_local(navigator.get_next_path_position()).normalized()
		Navigate()
	# If the enemy cannot see the player and is not yet returning home
	else:
		# Stop moving
		navigationDirection = Vector2.ZERO
		Navigate()

# Tell the enemy navigation agent to return to the enemy home position if the player has not been seen for 3 seconds
func _on_idle_movement_timeout_timeout() -> void:
	# TODO fix enemy idle movement
	# navigator.target_position = homePosition
	pass

# Function to update player velocity and play the appropriate animation and apply animation direction
func Navigate():
	velocity = navigationDirection * movementSpeed
	if velocity == Vector2.ZERO:
		# Play idle animation if the enemy is not moving
		anim_tree.get("parameters/playback").travel("Idle")
	else:
		# If the enemy is moving, play the walk animation and set the BlendSpace direction to match the movement
		# This makes sure the enemy is facing the direction of the movement
		anim_tree.get("parameters/playback").travel("Walk")
		anim_tree.set("parameters/Idle/BlendSpace2D/blend_position", navigationDirection)
		anim_tree.set("parameters/Walk/BlendSpace2D/blend_position", navigationDirection)
		anim_tree.set("parameters/Hurt/BlendSpace2D/blend_position", navigationDirection)
		anim_tree.set("parameters/Death/BlendSpace2D/blend_position", navigationDirection)
	move_and_slide()

# Function to handle dealing damage to the enemy, called from the bullet script
# Includes damageOrigin to detect if the enemy was shot by a player or damaged by friendly fire
func takeDamage(damageValue, damageOrigin):
	# If the enemy is not invulnerable (damage cooldown)
	if !invuln and !dead:
		# Make the enemy aware of the player if not already, using damageOrigin check so that enemies cannot become
		# aware of the player as a result of being hit by friendly fire.
		if !damagedByPlayer and damageOrigin is Player:
			damagedByPlayer = true
			weapon.aimAtPlayer = true
		# Set the enemy as invulnerable (damage cooldown)
		var invuln = true
		# Update the enemy health value and the healthbar
		enemyHealth -= damageValue
		healthbar._health = enemyHealth
		# Play the hurt animation and start the damage cooldown timer
		anim_tree.get("parameters/playback").travel("Hurt")
		damageTimer.start()
		# Add a record of the damage to the damage records array
		CombatTracker.recordEvent(CombatEvent.new(damageOrigin, self, damageValue, Time.get_ticks_msec()))
		if enemyHealth <= 0:
			Die()

# Function for enemy shooting
func Shoot():
	# Bullets remaining
	if weapon.magSize > 0:
		# Shoot and remove 1 bullet
		weapon.Shoot()
	# No bullets remaining, reload
	else:
		reloading = true
		$ReloadTimer.start()

# Damage cooldown timer finishes
func _on_damage_cooldown_timeout() -> void:
	# Remove the damage cooldown to allow the enemy to be damaged again
	invuln = false

# Called when health reaches 0
func Die():
	# Set dead flag to stop damage method calls
	dead = true
	# Play death animation
	anim_tree.get("parameters/playback").travel("Death")
	# Remove weapon
	weapon.queue_free()
	# Disable collision and stop hitbox monitoring to stop bullets from registering hits to the enemy
	collision.set_deferred("disabled", true)
	hitbox.set_deferred("monitorable", false)
	hitbox.set_deferred("monitoring", false)

func _on_reload_timer_timeout() -> void:
	if !dead:
		weapon.reload(magSize)
		reloading = false
