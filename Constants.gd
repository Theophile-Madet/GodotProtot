extends Node


const provoker_scene := preload("res://Rageborn/Attacks/Provoker/Provoker.tscn")
func make_provoker() -> Provoker:
	return provoker_scene.instance() as Provoker
	
const scorn_scene := preload("res://Rageborn/Attacks/Scorn/Scorn.tscn")
func make_scorn() -> Scorn:
	return scorn_scene.instance() as Scorn
	
const laser_scene := preload("res://Rageborn/Attacks/Laser/Laser.tscn")
func make_laser() -> Laser:
	return laser_scene.instance() as Laser

const bloodcry_scene := preload("res://Rageborn/Attacks/BloodCry/BloodCry.tscn")
func make_bloodcry() -> BloodCry:
	return bloodcry_scene.instance() as BloodCry
