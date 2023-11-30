extends Control

const RANDOM_BUTTON_NAME := "Random"
const CAMPAIGN_SCENE := preload("res://scenes/campaign.tscn") as PackedScene
const CHARACTER_OPTION := preload("res://gui/character_option.tscn") as PackedScene
const CARD_OBJECT := preload("res://gui/card.tscn") as PackedScene

var _selected_character: String = ""

@onready var _character_button_list := $Contents/Characters as Control
@onready var _character_info_button := $Contents/ShowCharacterInfo as Button
@onready var _start_button := $Start as Button
@onready var _border := $Border as Control
@onready var _name_input := $Contents/LineEdit as LineEdit
@onready var _character_info_modal := $Modal as Modal


func _ready() -> void:
	var char_button_group := ButtonGroup.new()
	char_button_group.pressed.connect(_select_character)
	for child in _border.get_children():
		var line := child as ColorRect
		line.color = Color(0, 0, 0, 0)
	for child in _character_button_list.get_children():
		_character_button_list.remove_child(child)
		child.queue_free()
	for character in Globals.user_progress.available_characters:
		var option := CHARACTER_OPTION.instantiate() as CharacterOptionButton
		option.name = character
		var char_data := load_character(character)
		if not char_data:
			continue
		option.character_name = char_data.name
		option.texture = char_data.portrait
		option.colour = char_data.colour
		option.button_group = char_button_group
		_character_button_list.add_child(option)
	for i in 1:
		var option := CHARACTER_OPTION.instantiate() as CharacterOptionButton
		option.name = RANDOM_BUTTON_NAME
		option.character_name = "Random"
		option.texture = null
		option.text = "?"
		option.colour = Color(1.0, 1.0, 1.0)
		option.button_group = char_button_group
		_character_button_list.add_child(option)


func _back() -> void:
	SceneTransition.transition_to_packed(load("res://scenes/title.tscn") as PackedScene, "wipe_right")


func load_character(char_name: String) -> CharacterData:
	var path := "characters/%s.tres" % char_name.to_lower()
	return ModResourceLoader.load(path) as CharacterData


func _start() -> void:
	if _selected_character == RANDOM_BUTTON_NAME:
		var n := _character_button_list.get_child_count() - 1
		var i := randi_range(0, n)
		_selected_character = _character_button_list.get_child(i).name
	var character := load_character(_selected_character)
	var campaign := CampaignProgress.new()
	campaign.player_name = _name_input.text
	campaign.character = character
	var scene := CAMPAIGN_SCENE.instantiate() as Campaign
	scene.progress = campaign
	SceneTransition.transition_to_scene(scene)


func _select_character(char_button: Button) -> void:
	_selected_character = char_button.name
	_character_info_button.disabled = (_selected_character == RANDOM_BUTTON_NAME)
	var colour := char_button.get("theme_override_styles/normal").bg_color as Color
	_border.get("theme_override_styles/panel").border_color = colour
	for child in _border.get_children():
		var line := child as ColorRect
		line.color = colour
	_refresh_enabled()


func _name_changed(_new_name: String) -> void:
	_refresh_enabled()


func _refresh_enabled() -> void:
	var char_chosen := _selected_character != ""
	var valid_name := not _name_input.text.is_empty()
	_start_button.disabled = not (char_chosen and valid_name)


func _show_character_info() -> void:
	var card_list := $Modal/CharacterInfo/ScrollContainer/HFlowContainer as Control
	for child in card_list.get_children():
		card_list.remove_child(child)
		child.queue_free()
	var char_data := load_character(_selected_character)
	for card_data in char_data.deck:
		var card := CARD_OBJECT.instantiate() as CardGui
		card.data = card_data
		card.disabled = true
		card_list.add_child(card)
	_character_info_modal.show_menu("CharacterInfo")
	# Show list of cards
