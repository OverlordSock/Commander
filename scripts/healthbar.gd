extends ProgressBar

@onready var timer = $Timer
@onready var damage_bar = $DamageBar

# Variable to smoothly decrease the damagebar value to match the healthbar
var damageBarSmooth

# Health property with attached SET command
var _health = 0 : set = _set_health

# Healthbar initialisation, to be called from player or enemy script
func init_health(health):
	# Set healthbar initial value and max value to given health value
	_health = health
	max_value = _health
	value = _health
	
	# Set damage bar to match healthbar
	damage_bar.max_value = _health
	damage_bar.value = _health
	
	# Set up damage bar smoothing
	damageBarSmooth = health

# Function called when _health is changed
func _set_health(new_health):
	# Get previous health to check if change is health lost or gained
	var prev_health = _health
	# Set _health to match new_health, capped at the max health value
	_health = min(max_value, new_health)
	value = _health
	
	# If health is less than before change, change is health lost
	if _health < prev_health:
		# Start the timer to reduce the damage bar after a delay
		timer.start()
	else:
		# Change is health gained, no need for timer
		damage_bar.value = _health

# Match damage bar to healthbar after delay
func _on_timer_timeout() -> void:
	# Tween to smooth the damageBar reduction, this is visual flair
	var tween = create_tween()
	# Interpolate damageBarHealth to _health over 0.5 seconds
	tween.tween_property(self, "damageBarSmooth", _health, 0.3)\
		.set_trans(Tween.TRANS_QUAD)\
		.set_ease(Tween.EASE_IN)
		# Transition and ease in to make the reduction accelerate towards the target value

# Match the damage_bar value to the smoothing value per frame
func _process(delta: float) -> void:
	damage_bar.value = damageBarSmooth
	# Remove healthbar if smoothing value reaches 0
	# This causes the healthbar to be removed once the smoothing has finished,
	# instead of being removed as soon as the health is reduced to 0
	if damageBarSmooth <= 0:
		queue_free()
