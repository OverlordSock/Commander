extends Sprite2D

# Sparks object preloaded to spark on impact
const SPARKS = preload("res://scenes/sparks.tscn")
# Raycast for terrain collision detection
@onready var shapeCast = $ShapeCast2D
var bulletOrigin: Node

const SPEED = 500
var damage = 20

# Move bullet in the initial direction per frame
func _process(delta: float) -> void:
	# Remove bullet if it hits a wall, the shapeCast is set to only detect collision with the terrain map
	if shapeCast.is_colliding():
		SpawnSparks()
		queue_free()
	else:
		# Move bullet
		position += transform.x * SPEED * delta
	

# Remove the bullet instance if it leaves the screen
func _on_visible_on_screen_enabler_2d_screen_exited() -> void:
	queue_free()

# Handles hitting other Area2D nodes (like Hitboxes)
func _on_area_2d_area_entered(area: Area2D) -> void:
	if area is Hitbox:
		area.Hit(damage, bulletOrigin) # Call the specific Hit function
	SpawnSparks() # Impact sparks
	queue_free() # Always destroy the bullet on impact

# Leave behind impact sparks when a bullet hits something
func SpawnSparks():
	# By spawning impact sparks this way instead of having an emitter built into the bullet,
	# we can have the sparks emit after the bullet has been removed from the scene
	# New GPU particles instance, add to world
	var sparks_instance = SPARKS.instantiate()
	get_tree().root.add_child(sparks_instance)
	# Set particle emitter position and rotation to match bullet
	sparks_instance.global_position = global_position
	sparks_instance.rotation = rotation
	# Particle emitter activation
	sparks_instance.Sparks()
