extends CharacterBody2D

enum PlayerState{
	IDLE,
	JUMP
}

const JUMP_DURATION := 0.2
const FALL_DURATION := 1.0
const INIT_DURATION := 2.0

@onready var animated_sprite = $AnimatedSprite2D
@onready var collision_shape = $CollisionShape2D

var state:= PlayerState.IDLE:
	set(new_s):
		if new_s != state:
			state = new_s
			match new_s:
				PlayerState.IDLE:
					collision_shape.position.y = 4.5
				PlayerState.JUMP:
					collision_shape.position.y = -0.5

func setup():
	set_player_position()
	GameManager.player_move_failed.connect(_on_player_move_failed)
	GameManager.player_position_changed.connect(_on_player_position_changed)
	GameManager.player_fallen.connect(_on_player_fallen)
	GameManager.player_initialized.connect(_on_player_initialized)

func _ready() -> void:
	animated_sprite.animation = "idle"
	animated_sprite.play()

func set_state(s: PlayerState) -> void:
	if s != state:
		state = s
		match s:
			PlayerState.IDLE:
				animated_sprite.play("idle")
			PlayerState.JUMP:
				animated_sprite.play("jump")

func set_player_position() -> void:
	position = get_global_cell_position(GameManager.player_position)

func get_global_cell_position(cell: Vector2i) -> Vector2:
	return cell*16 + Vector2i(8,2)

func _on_player_position_changed() -> void:
	animated_sprite.flip_h = GameManager.player_flip
	set_state(PlayerState.JUMP)
	await move(get_global_cell_position(GameManager.player_position))
	set_state(PlayerState.IDLE)
	set_player_position()

func _on_player_move_failed(next_cell: Vector2i) -> void:
	var next_pos := get_global_cell_position(next_cell)
	set_state(PlayerState.JUMP)
	await fail(next_pos)
	set_state(PlayerState.IDLE)

func _on_player_fallen(next_pos: Vector2i) -> void:
	set_state(PlayerState.JUMP)
	await move(get_global_cell_position(next_pos))
	set_state(PlayerState.IDLE)
	await fall()
	GameManager.init_player_position()
	
func _on_player_initialized() -> void:
	animated_sprite.flip_h = GameManager.player_flip
	set_player_position()
	animated_sprite.rotation_degrees = 0
	await init_player()
	
func move(next_position: Vector2) -> void:
	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	tween.tween_property(self,"position",next_position,JUMP_DURATION)
	await tween.finished

func fail(next_pos: Vector2) -> void:
	var player_pos := get_global_cell_position(GameManager.player_position)
	var mid_pos := (next_pos + player_pos) / 2
	
	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	tween.tween_property(self,"position",mid_pos,JUMP_DURATION/2)
	tween.tween_property(self,"position",player_pos,JUMP_DURATION/2)
	await tween.finished

func fall() -> void:
	var tween = create_tween()
	tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)
	tween.set_parallel()
	tween.tween_property(animated_sprite,"rotation_degrees",360,FALL_DURATION)
	tween.tween_property(animated_sprite,"scale",Vector2(0,0),FALL_DURATION)
	await tween.finished

func init_player() -> void:
	var tween = create_tween()
	tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
	tween.tween_property(animated_sprite,"scale",Vector2(1,1),INIT_DURATION)
	await tween.finished
