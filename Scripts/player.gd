extends CharacterBody2D

var input
@export var speed = 100.0 # за счёт export переменная появляется в инспекторе
@export var gravity = 10

# переменная для прыжка (рекомендуется использовать для этого целое число)
var jump_count = 0
@export var max_jump = 2
@export var jump_force = 500

# переменная дэша
@export var dash_force = 600

# Машина состояний
var current_state = player_states.MOVE
enum player_states {MOVE, SWORD, DEAD, DASH}


func _ready():
	$sword/sword_collider.disabled = true # чтобы коллизия меча была отключена по умолчанию

func _physics_process(delta: float) -> void:
	if player_data.life <= 0:
		current_state = player_states.DEAD
		
	# как только добавим состояние смерти, то эти строчки нужно закомментировать, потому что сцена перезагружается
	#if player_data.life >= 1:
	#	current_state = player_states.MOVE
	
	match current_state:
		player_states.MOVE:
			movement(delta)
		player_states.SWORD:
			sword(delta)
		player_states.DEAD:
			dead()
		player_states.DASH:
			dashing()
		
	
func movement(delta):
	input = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")

	if input != 0:
		if input > 0: # движение вправо
			velocity.x += speed * delta
			velocity.x = clamp(speed, 100.0, speed) # нормализует скорость, до этого персонаж как бы скользил
			$AnimatedSprite2D.scale.x = 1 # поворачивает персонажа по направлению
			$sword/sword_collider.position.x = 18
			$AnimationPlayer.play("run")
		if input < 0: # движение влево
			velocity.x -= speed * delta
			velocity.x = clamp(-speed, 100.0, -speed)
			$AnimatedSprite2D.scale.x = -1
			$sword/sword_collider.position.x = -18 # теперь коллизия меча поворочивается вместе с персонажем
			$AnimationPlayer.play("run")
	if input == 0: # отсутствие двжения
		velocity.x = 0
		$AnimationPlayer.play("idle")
		
	# прыжок
	if is_on_floor(): # обнуляем счётчик прыжков после приземления
		jump_count = 0
		
	if !is_on_floor():
		if velocity.y < 0: # если скорость идёт вверх, проигрывается анимация прыжка
			$AnimationPlayer.play("jump")
		if velocity.y > 0: # если скорость идёт вниз, проигрывается анимация падения
			$AnimationPlayer.play("fall")
	
	# длинный прыжок как в Hollow Knight
	if Input.is_action_just_pressed("ui_accept") && is_on_floor() && jump_count < max_jump: 
		jump_count += 1
		velocity.y -= jump_force # минус означает вверх, т.к в Godot минусовые значения Y идут вверх, а не вниз
		velocity.x = input
		
	# двойной прыжок	
	if !is_on_floor() && Input.is_action_just_pressed("ui_accept") && jump_count < max_jump:
		jump_count += 1
		velocity.y -= jump_force * 1.2
		velocity.x = input
		
	# короткий прыжок
	if !is_on_floor() && Input.is_action_just_released("ui_accept") && jump_count < max_jump: 
		velocity.y = gravity
		velocity.x = input
	else:
		gravity_force()
	
	if Input.is_action_just_pressed("ui_sword"):
		current_state = player_states.SWORD
		
	if Input.is_action_just_pressed("ui_dash"):
		current_state = player_states.DASH
	
	gravity_force()
	move_and_slide()

func gravity_force():
	velocity.y += gravity # добавление гравитации, теперь персонаж может падать

func sword(delta):
	$AnimationPlayer.play("attack")
	# если нужно, чтобы персонаж бил и двигался, то добавляем отдельную функцию
	input_movement(delta)

func dashing():
	if velocity.x > 0:
		velocity.x += dash_force
		$AnimationPlayer.play("dash")
		await get_tree().create_timer(0.2).timeout
		current_state = player_states.MOVE
	elif velocity.x < 0:
		velocity.x -= dash_force
		$AnimationPlayer.play("dash")
		await get_tree().create_timer(0.2).timeout
		current_state = player_states.MOVE
		
	# когда не движемся, то дэшаемся туда, куда смотрит персонаж
	else:
		if $AnimatedSprite2D.scale.x == 1:
			velocity.x += dash_force
			$AnimationPlayer.play("dash")
			await get_tree().create_timer(0.2).timeout
			current_state = player_states.MOVE
		if $AnimatedSprite2D.scale.x == -1:
			velocity.x -= dash_force
			$AnimationPlayer.play("dash")
			await get_tree().create_timer(0.2).timeout
			current_state = player_states.MOVE
	
	move_and_slide()

func dead():
	$AnimationPlayer.play('death')
	velocity.x = 0
	# чтобы во время смерти, не звиснуть в воздухе
	gravity_force()
	move_and_slide()
	
	# после окончания анимации, возрождаемся с четырьмя сердцами
	await $AnimationPlayer.animation_finished
	player_data.life = 4
	player_data.coin = 0
	
	# перезагружаем сцену после смерти
	if get_tree():
		get_tree().reload_current_scene()
	
func input_movement(delta):
	input = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")

	if input != 0:
		if input > 0: # движение вправо
			velocity.x += speed * delta
			velocity.x = clamp(speed, 100.0, speed) # нормализует скорость, до этого персонаж как бы скользил
			$AnimatedSprite2D.scale.x = 1 # поворачивает персонажа по направлению
		if input < 0: # движение влево
			velocity.x -= speed * delta
			velocity.x = clamp(-speed, 100.0, -speed)
			$AnimatedSprite2D.scale.x = -1
	
	if input == 0:
		velocity.x = 0
	
	gravity_force() # теперь можно во время атаки в прыжке, персонаж не зависнет на воздухе
	move_and_slide()
	
	
func reset_sate():
	current_state = player_states.MOVE
