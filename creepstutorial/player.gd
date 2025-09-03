extends Area2D
signal hit

@export var speed = 400 # How fast the player moves, px/s
var screen_size # Size of game window

func _ready(): # Used when the player enters the scene tree.
	screen_size = get_viewport_rect().size
	hide() # Hides the player upon the start of the game.
	
func _process(delta): # Runs the whole time.
	var velocity = Vector2.ZERO # Defines player's movement vector, add and subtract to modify the velocity based on player movement direction.
	if Input.is_action_pressed("move_right"):
		velocity.x += 1
	if Input.is_action_pressed("move_left"):
		velocity.x -= 1
	if Input.is_action_pressed("move_down"):
		velocity.y += 1
	if Input.is_action_pressed("move_up"):
		velocity.y -= 1
		
	if velocity.length() > 0: # Moving @ (1,1) = SQRT(2) is faster than simply moving cardinal. Normalizing prevents that.
		velocity = velocity.normalized() * speed
		# Play sprite if moving. Else don't.
		$AnimatedSprite2D.play()
	else:
		$AnimatedSprite2D.stop()
		
	position += velocity * delta # Modify character position based on the velocity, by the system FPS.
	position = position.clamp(Vector2.ZERO, screen_size) # Clamp prevents the character from leaving the screen.
	
	# Choosing animation files to play based on direction of sprite.
	if velocity.x != 0:
		$AnimatedSprite2D.animation = "walk"
		$AnimatedSprite2D.flip_v = false
		$AnimatedSprite2D.flip_h = velocity.x < 0
	elif velocity.y != 0:
		$AnimatedSprite2D.animation = "up"
		$AnimatedSprite2D.flip_v = velocity.y > 0

func _on_body_entered(body: Node2D) -> void:
	hide() # Player disappears after being hit.
	hit.emit()
	# Must be deferred as we can't change physics properties on a physics callback. Makes it so that object collision disappears once it's safe to do so.
	$CollisionShape2D.set_deferred("disabled", true)

# Function resets the player when starting a new game.
func start(pos):
	position = pos
	show()
	$CollisionShape2D.disabled = false
