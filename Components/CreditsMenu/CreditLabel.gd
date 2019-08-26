extends RichTextLabel

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

onready var credits = preload("Credits.gd").new().credits

# Called when the node enters the scene tree for the first time.
func _ready():
	# text = str(credits)
	connect("meta_clicked", self, "link_clicked")
	var res_text = ""
	for credit in credits:
		res_text += "[url="+credit.Link+"]"+credit.Title+"[/url]\n"
		res_text += "	Creator: [url="+credit.Creator_Link+"]"+credit.Creator+"[/url]\n"
		if credit.has("Creator_2"):
			res_text += "	Creator: [url="+credit.Creator_2_Link+"]"+credit.Creator_2+"[/url]\n"
		res_text += "	License: [url="+credit.License_Link+"]"+credit.License+"[/url]\n"
		if credit.Modified:
			res_text += "	Is Modified\n\n"
		else:
			res_text += "	Is not Modified\n\n"
	set_bbcode(res_text)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
func link_clicked(link):
	print("link clicked:"+link)
	OS.shell_open(link)

func sort_credits_by_title(a,b):
	# if a.Title
	pass