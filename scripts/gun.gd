extends Node2D

# Variables to reference the animations and animation tree
@onready var _gun = $GunType
@onready var _animTree = $AnimationTree
@onready var _gunSFX = $SFX
var _animStateMachine: AnimationNodeStateMachinePlayback

# Export variable to turn on mouse aiming if the parent is a player
@export var player = true
# Variable to control enemy gun idle state
var aimAtPlayer = false
var aimTarget : Player
@onready var gunOrigin = get_parent()

# Weapon SFX preloads
const pistolSFX = preload("res://assets/Sounds/PistolShot.mp3")
const smgSFX = preload("res://assets/Sounds/SMGShot.mp3")
const shotgunSFX = preload("res://assets/Sounds/ShotgunShot.mp3")

# Variables assigning the gun barrel and preloading bullet scene
@onready var _gunBarrel = $Barrel
const BULLET = preload("res://scenes/bullet.tscn")

# Variables to change selected weapon and attack type
var _selectedWeapon = "Pistol"
var _attackType = "Pistol_Attack"

# Ready function activates the animation state machine and gets the playback as soon as the scene is created
# This ensures the animation playback is instantiated before calling methods on it
func _ready() -> void:
	_animTree.active = true
	_animStateMachine = _animTree.get("parameters/playback")

# Processes code every frame
func _process(delta: float) -> void:
	# Code to point weapon at the mouse and flip the sprite if the weapon is pointing left
	if player:
		# If the gun belongs to the player, look at the mouse
		look_at(get_global_mouse_position())
	elif aimAtPlayer:
		# if the gun belongs to an enemy that can see a target, look at the target
		look_at(aimTarget.global_position)
	# Clamp the rotation to a 360 degree range, otherwise rotation increases infinitely as mouse moves
	rotation_degrees = wrap(rotation_degrees, 0, 360)
	# Flip the gun if it is to the left of the player, but do not flip the sword
	if rotation_degrees > 90 and rotation_degrees < 270 and _selectedWeapon != "Sword":
		_gun.flip_v = true
	else:
		_gun.flip_v = false

# Function to switch weapon, called from Player script
func SwitchWeapon(selected: String):
	_selectedWeapon = selected
	_animStateMachine.travel(_selectedWeapon)
	# Switch to correct weapon sound
	if selected == "Pistol":
		_gunSFX.stream = pistolSFX
	elif selected == "SMG":
		_gunSFX.stream = smgSFX
	elif selected == "Shotgun":
		_gunSFX.stream = shotgunSFX

# Function to attack, called from script
func Shoot():
	# Move the gun animation to the matching shooting animation
	_animStateMachine.travel(_attackType)
	
# Function to spawn bullets, called from the GunAnimationPlayer
func SpawnBullet():
	_gunSFX.play(0.0)
	# If the weapon is the shotgun, give it a multi-shot spread pattern
	if _selectedWeapon == "Shotgun":
		# Spread will iterate from -2 to 2, creating a 5 degree spread of bullets centered on the aim
		for spread in range(-2, 3):
			var bullet_instance = BULLET.instantiate()
			# Pass the gunOrigin (parent) to the bullet to determine which character fired the bullet
			bullet_instance.bulletOrigin = gunOrigin
			# Add the bullet as a child of the level so its position isn't tied to the gun/player/enemy movement
			get_tree().root.add_child(bullet_instance)
			# Set damage value of the bullet
			bullet_instance.damage = 7
			# Position the bullet at the gun barrel marker
			bullet_instance.global_position = _gunBarrel.global_position
			# Rotate each of the 5 bullets adding "spread" extra degrees to each bullet to fire in a cone
			bullet_instance.rotation = rotation + deg_to_rad(spread * 3)
	else:
		# Regular gun shot
		var bullet_instance = BULLET.instantiate()
		# Pass the gunOrigin (parent) to the bullet to determine which character fired the bullet
		bullet_instance.bulletOrigin = gunOrigin
		# Add the bullet as a child of the level so its position isn't tied to the gun/player/enemy movement
		get_tree().root.add_child(bullet_instance)
		# Set SMG bullet damage to be lower because SMG has a high fire rate, give the SMG a random extra rotation
		# as the SMG is meant to be less accurate, e.g. random spread pattern per bullet
		if _selectedWeapon == "SMG":
			bullet_instance.damage = 5
			bullet_instance.rotation = rotation + deg_to_rad(randf_range(-8, 8))
		# Set Pistol bullet rotation to gun rotation, no changes to spread as pistol is meant to be highly accurate
		# and fire exactly where the player is aiming
		# Don't need to set pistol bullet damage as the default bullet damage is the pistol damage value
		elif _selectedWeapon == "Pistol":
			bullet_instance.rotation = rotation
		# Position the bullet at the gun barrel marker
		bullet_instance.global_position = _gunBarrel.global_position
