class_name Player
extends Node2D

enum {Left = 1, Up = 2, Right = 3, Down = 4}

signal playerStep
signal whatWasHit
signal reachedGoal
signal whatWasInteractedWith

@onready var game_level = get_tree().get_first_node_in_group("gamelevel")
@onready var tile_map = get_tree().get_first_node_in_group("tilemaplayer")
@onready var sprite_2d: Sprite2D = $PlayerSprite
@onready var raycast_2d: RayCast2D = $PlayerEnemyCollisionRaycast

var id: String
var direction: String
var is_moving: bool = false
var facing: int
var raycast_default: Vector2

var nodeSeen

func _ready():
	if facing == null:
		facing = Down
	if facing == Left:
		raycast_default = Vector2.LEFT
	elif facing == Right:
		raycast_default = Vector2.RIGHT
	elif facing == Up:
		raycast_default = Vector2.UP
	elif facing == Down:
		raycast_default = Vector2.DOWN
	raycast_2d.target_position = raycast_default * 32

func _physics_process(_delta):
	if is_moving == false:
		return
	if global_position == sprite_2d.global_position:
		is_moving = false
		return
	# put line below in between the two if statements above?
	sprite_2d.global_position = sprite_2d.global_position.move_toward(global_position, 2)

func _process(_delta):
	spriteFacing(facing)
	if is_moving == true:
		return
	# if Input.is_action_just_pressed("cDash"):
	if Input.is_action_just_pressed("stab"):
		stab(facing)
	elif Input.is_action_just_pressed("left"):
		move(Vector2.LEFT)
		facing = Left
	elif Input.is_action_just_pressed("right"):
		move(Vector2.RIGHT)
		facing = Right
	elif Input.is_action_just_pressed("up"):
		move(Vector2.UP)
		facing = Up
	elif Input.is_action_just_pressed("down"):
		move(Vector2.DOWN)
		facing = Down

func move(direction):
	var current_tile: Vector2i = tile_map.local_to_map(global_position)
	var target_tile: Vector2i = Vector2i(
		current_tile.x + direction.x,
		current_tile.y + direction.y
	)
	
	var tile_data: TileData = tile_map.get_cell_tile_data(target_tile)
	
	# possibly move the "step" variable here, if changing direction but not changing tiles is something I want to count
	
	if tile_data.get_custom_data("solid") == true:
		return
	
	if tile_data.get_custom_data("goal") == true:
		reachedGoal.emit()
	
	raycast_2d.target_position = direction * 32
	raycast_2d.force_raycast_update()
	if raycast_2d.is_colliding():
		return
	
	is_moving = true
	playerStep.emit()
	# print("emitting")
	global_position = tile_map.map_to_local(target_tile)
	sprite_2d.global_position = tile_map.map_to_local(current_tile)

func spriteFacing(looking):
	if looking == Left:
		sprite_2d.texture.region = Rect2(32, 32, 32, 32)
	if looking == Right:
		sprite_2d.texture.region = Rect2(0, 0, 32, 32)
	if looking == Up:
		sprite_2d.texture.region = Rect2(0, 32, 32, 32)
	if looking == Down:
		sprite_2d.texture.region = Rect2(32, 0, 32, 32)

func stab(looking):
	# if player stabs a vending machine or something, it makes a noise
	if raycast_2d.is_colliding():
		var hit: Area2D = raycast_2d.get_collider()
		whatWasHit.emit(hit, looking)
		print("hit something")
		print(str(hit))
	else:
		# player stab animation and sound
		pass

func interact(looking):
	if raycast_2d.is_colliding():
		var interactingWith: Area2D = raycast_2d.get_collider()
		whatWasInteractedWith.emit(interactingWith, looking)
		print("interacted with something")
		print(str(interactingWith))
	else:
		pass

func _level_finished():
	pass

func _is_player_seen(nodeSeen):
	pass
