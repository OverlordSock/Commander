extends GPUParticles2D

#Start sparks timeout
func Sparks():
	# Method to change emitter settings while live
	set_deferred("emitting", true)
	# Start the timer that removes the sparks
	$Timer.start()

func _on_timer_timeout() -> void:
	# Remove the sparks
	queue_free()
