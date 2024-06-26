extends CharacterBody3D

const SPEED = 4.0
const JUMP_VELOCITY = 17

var playerData

var direction
var Sprite
var parentNode
var opponent

var inputUp
var inputDown
var inputRight
var inputLeft
var crouching

var leftRaycast
var rightRaycast

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready():
	parentNode = get_parent()
	Sprite = get_node("AnimatedSprite3D")
	
	leftRaycast = get_node("LeftRayCast")
	rightRaycast = get_node("RightRayCast")
	
	playerData = parentNode.get_parent()
	
	playerData.connect("sendDataScript",_get_player_data)
	
	# maybe make this a list of enums in the future in global player because
	# this is going to become a mess once more controls are added..
	
	# i need make this a class cause this is kinda bad
	
	if(parentNode.name == "playerOneContainer"):
		get_tree().call_group("Players","_player_loaded",0)
		Sprite.set_modulate(Color(0.75,1.0,1.0,1.0))
		inputUp = "player_one_move_up"
		inputDown = "player_one_move_down"
		inputRight = "player_one_move_right"
		inputLeft = "player_one_move_left"

		
	else:
		get_tree().call_group("Players","_player_loaded",1)
		Sprite.set_modulate(Color(1.0,0.75,0.75,1.0))
		inputUp = "player_two_move_up"
		inputDown = "player_two_move_down"
		inputRight = "player_two_move_right"
		inputLeft = "player_two_move_left"
		Sprite.flip_h = true
		
func _get_player_data(data):
	if parentNode.name == "playerOneContainer":
		opponent = data.playerTwo
		print("playerOne assigned")
	if parentNode.name == "playerTwoContainer":
		opponent = data.playerOne
		print("playerTwo assigned")
	
		
func flip_player():
	if opponent:
		Sprite.flip_h = global_position.z - opponent.global_position.z < 0 
	
func _physics_process(delta):
	
	if Input.is_action_pressed(inputDown):
		crouching = true
	else:
		crouching = false
	
	if not is_on_floor():
		velocity.y -= gravity * delta
		Sprite.play("jump")

	if Input.is_action_just_pressed(inputUp) and is_on_floor():
		velocity.y = JUMP_VELOCITY

	if is_on_floor():
		if Input.is_action_pressed(inputLeft) or Input.is_action_pressed(inputRight):
			if Input.is_action_pressed(inputLeft):
				if not leftRaycast.is_colliding():
					direction = Vector3(0,0,1)
				else:
					direction = Vector3(0,0,0)
			if Input.is_action_pressed(inputRight):
				if not rightRaycast.is_colliding():
					direction = Vector3(0,0,-1)
				else:
					direction = Vector3(0,0,0)
		else:
			direction = Vector3.ZERO
		
		if direction:
			velocity.z = direction.z * SPEED
			if is_on_floor():
				Sprite.play("run")
			
		else:
			velocity.z = move_toward(velocity.z, 0, SPEED)
			if is_on_floor():
				Sprite.play("idle")
	
	flip_player()
	move_and_slide()
