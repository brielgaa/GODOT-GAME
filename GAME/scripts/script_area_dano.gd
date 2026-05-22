extends Area2D

# O _physics_process roda o tempo todo (60 vezes por segundo)
func _physics_process(delta: float) -> void:
	
	# Cria uma lista de tudo o que está a tocar no espinho neste exato momento
	var corpos_tocando = get_overlapping_bodies()
	
	for body in corpos_tocando:
		if body.is_in_group("player"):
			if body.has_method("take_damage"):
				# O espinho grita "TOMA DANO!" sem parar.
				# O script do seu Personagem vai ignorar se estiver invencível (piscando),
				# e vai perder outro coração assim que a invencibilidade acabar!
				body.take_damage()
