extends LineEdit


func save():
	var data = {
		Globals.PATH: self.get_path(),
		Globals.DATA: {"text": self.text}
	}
	return data

func load(data):
	self.text = data["text"]
