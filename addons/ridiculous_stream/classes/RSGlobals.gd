extends RefCounted
class_name RSGlobals


const local_res_folder = "res://addons/ridiculous_stream/local_res/"
const rs_config_folder = "RidiculousStream/"
const rs_settings_file_name = "settings.json"
const rs_log_folder = "logs/"
const rs_user_folder = "users/"
const rs_obj_folder = "obj/"
const rs_sfx_folder = "sfx/"

const pnl_settings_pack = preload("res://addons/ridiculous_stream/instances/pnl_settings.tscn")
const dock_pack = preload("res://addons/ridiculous_stream/instances/RSDock.tscn")
const wn_settings_pack = preload("res://addons/ridiculous_stream/instances/wn_settings.tscn")
const wn_welcome_pack = preload("res://addons/ridiculous_stream/instances/wn_welcome.tscn")
const param_inspector_pack = preload("res://addons/ridiculous_stream/instances/param_inspector.tscn")

const msg_notif_pack = preload("res://addons/ridiculous_stream/instances/msg_notification.tscn")
const btn_user_pack = preload("res://addons/ridiculous_stream/instances/btn_user.tscn")

const screen_shader_pack = preload("res://addons/ridiculous_stream/games/screen_shaders/RSShaders.tscn")

const physic_scene_pack = preload("res://addons/ridiculous_stream/games/physics_editor/RSPhysics.tscn")
const alert_scene_pack = preload("res://addons/ridiculous_stream/instances/alert_overlay.tscn")
const wheel_of_random_pack = preload("res://addons/ridiculous_stream/games/wheel_random/the_wheel_of_random.tscn")
const lb_body_pack = preload("res://addons/ridiculous_stream/games/physics_editor/obj/lb_rigidbody.tscn")
const laser_scene_pack = preload("res://addons/ridiculous_stream/games/physics_editor/obj/laser_emitter.tscn")

const DEFAULT_RIGID_LABEL_COLOR = "#29c3a6"

var known_users := {}
var first_session_message_username_list : PackedStringArray = []
var physics_space : RSPhysics
var physics_space_rid : RID


const params_can = {
	"img_paths" : ["can.png"],
	"spawn_range" : [3, 5],
	"sfx_paths" : ["sfx_can_01.ogg", "sfx_can_02.ogg", "sfx_can_03.ogg", "sfx_can_04.ogg"],
	"sfx_volume" : -12.0,
	"is_pickable" : true,
	"is_poly_fracture" : false,
	"is_destroy" : true,
	"scale" : [0.3, 0.3],
	"coll_layer" : 4,
	"coll_mask" : 5,
	"destroy_shard_params" : {
		"img_paths" : ["bean_01.png", "bean_02.png"],
		"spawn_range" : [12, 17],
		"sfx_paths" : [],
		"sfx_volume" : 0.0,
		"is_pickable" : false,
		"is_poly_fracture" : false,
		"is_destroy" : false,
		"scale" : [0.5, 0.5],
		"coll_layer" : 2,
		"coll_mask" : 3,
		"destroy_shard_params" : null
	}}
const param_beans = {
	"img_paths" : ["bean_01.png", "bean_02.png"],
	"spawn_range" : [7,14],
	"sfx_paths" : [],
	"sfx_volume" : 0.0,
	"is_pickable" : false,
	"is_poly_fracture" : false,
	"is_destroy" : false,
	"scale" : [0.5, 0.5],
	"coll_layer" : 2,
	"coll_mask" : 3,
	"destroy_shard_params" : {}}





