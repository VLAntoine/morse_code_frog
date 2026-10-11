extends Area2D

enum PlayerState{
	IDLE,
	JUMP
}

const JUMP_DURATION := 0.1 

@onready var animated_sprite = $AnimatedSprite2D

var player_data: PlayerData
var state:= PlayerState.IDLE

func setup(p_data: PlayerData):
	player_data = p_data
	set_player_position()
	player_data.position_changed.connect(_on_position_changed)

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
	position = get_player_position()

func get_player_position() -> Vector2:
	return player_data.cell_position * 16 + Vector2(8,2)

func _on_position_changed() -> void:
	set_state(PlayerState.JUMP)
	await move(get_player_position())
	set_state(PlayerState.IDLE)
	set_player_position()
	
func move(next_position: Vector2) -> void:
	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	tween.tween_property(self,"position",next_position,JUMP_DURATION)
	await tween.finished
