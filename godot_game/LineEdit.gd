extends LineEdit


func save():
	return {"text": self.text}

# data recieved is exact same as that given in save()
func load(data):
	self.text = data["text"]
