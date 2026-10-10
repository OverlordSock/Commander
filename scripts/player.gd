extends CharacterBody2D
class_name Player

# Onready variables to refer to nodes once they are instantiated
@onready var anim_tree = $AnimationTree
@onready var weapon = $Gun
@onready var healthbar = $Healthbar
@onready var damageTimer = $DamageCooldown
@onready var collision = $Collision
@onready var hitbox = $Hitbox
@onready var world : World = self.get_parent()

# Player stat variables
const SPEED = 300.0
var selectedWeapon = "Pistol"
var playerHealth = 500
var invuln = false
var dead = false

# Initialise the player healthbar on player instantiation
func _ready() -> void:
	healthbar.init_health(playerHealth)

# Called every frame
func _process(delta: float) -> void:
	# Attack if the player is pressing the shoot key, works for single presses and holding the key down
	if Input.is_action_pressed("shoot") and !dead:
		weapon.Shoot()

# Function to handle dealing damage to the player, called from the bullet script
# The damage origin here is used to stop the player from taking damage from their own bullets (edge case)
func takeDamage(damageValue, damageOrigin):
	# If the player is not invulnerable (damage cooldown), is not dead, and the bullet came from an enemy
	if !invuln and !dead and damageOrigin is Enemy:
		# Set the player as invulnerable (damage cooldown)
		var invuln = true
		# Update the player health value and the healthbar
		playerHealth = playerHealth - damageValue
		healthbar._health = playerHealth
		# Play the hurt animation and start the damage cooldown timer
		anim_tree.get("parameters/playback").travel("Hurt")
		damageTimer.start()
		# When player is damaged, add a hit record to the enemy's hit_record array so that the enemy can report
		# successfully damaging the player to the Commander module
		CombatTracker.recordEvent(CombatEvent.new(damageOrigin, self, damageValue, Time.get_ticks_msec()))
		if playerHealth <= 0:
			Die()

# Damage cooldown timer finishes
func _on_damage_cooldown_timeout() -> void:
	# Remove the damage cooldown to allow the player to be damaged again
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
	# End the level with win = false
	world.endLevel(false)

# Handles any key presses
func _unhandled_input(event: InputEvent) -> void:
	if dead:
		# Stop weapon changes after death
		pass
	# Selecting a new weapon
	#elif Input.is_action_just_pressed("select_sword"):
		## Set the selected weapon and attack type to match the key pressed
		#selectedWeapon = "Sword"
		#weapon._attackType = "Sword_Attack"
		## Switch to the new weapon
		#weapon.SwitchWeapon(selectedWeapon)
	elif Input.is_action_just_pressed("select_pistol"):
		selectedWeapon = "Pistol"
		weapon._attackType = "Pistol_Attack"
		weapon.SwitchWeapon(selectedWeapon)
	elif Input.is_action_just_pressed("select_smg"):
		selectedWeapon = "SMG"
		weapon._attackType = "SMG_Attack"
		weapon.SwitchWeapon(selectedWeapon)
	elif Input.is_action_just_pressed("select_shotgun"):
		selectedWeapon = "Shotgun"
		weapon._attackType = "Shotgun_Attack"
		weapon.SwitchWeapon(selectedWeapon)

# Called every frame, used to control physics objects
func _physics_process(delta: float) -> void:
	# Check if player has died before allowing movement
	if !dead:
		# Get player x and y movement direction
		# get_action_strength returns 0 if pressed and 1 if not pressed
		# If right is pressed and left is not, x axis direction is 1 - 0, positive x axis direction, vice versa
		# If down is pressed and up is not, y axis direction is 1 - 0, positive y axis direction, vice versa
		# NOTE: in Godot, y axis is reversed, so downwards movement is positive y axis direction
		# If both axis inputs are pressed, axis direction is 1 - 1, no direction, so no movement
		var input_vector_x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
		var input_vector_y = Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
		
		# Get direction combination from x axis direction and y axis direction
		var move_dir = Vector2(input_vector_x, input_vector_y)
		
		# Movement velocity is set in the movement direction at the speed of the player
		# .normalised() makes sure the player moves at an adjusted speed if moving on both the x and y axis
		# otherwise the player would move at an increased speed if moving diagonally
		velocity = SPEED * move_dir.normalized()
		
		if move_dir == Vector2.ZERO:
			# Play idle animation if the player is not moving
			anim_tree.get("parameters/playback").travel("Idle")
		else:
			# If the player is moving, play the walk animation and set the BlendSpace direction to match the movement
			# This makes sure the player is facing the direction of the movement
			anim_tree.get("parameters/playback").travel("Walk")
			anim_tree.set("parameters/Idle/BlendSpace2D/blend_position", move_dir)
			anim_tree.set("parameters/Walk/BlendSpace2D/blend_position", move_dir)
			anim_tree.set("parameters/Hurt/BlendSpace2D/blend_position", move_dir)
			anim_tree.set("parameters/Death/BlendSpace2D/blend_position", move_dir)
		
		move_and_slide()
