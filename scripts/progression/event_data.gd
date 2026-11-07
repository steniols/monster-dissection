class_name EventData
extends Resource
## Evento narrativo do mapa ("Mistério").

@export var id: StringName
@export var title: String = ""
@export_multiline var text: String = ""
@export var art_motif: StringName = &"notes"
@export var accent: Color = Color("#AE8B52")
@export var choices: Array[EventChoice] = []
