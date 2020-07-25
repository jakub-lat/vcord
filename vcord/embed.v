module vcord

pub struct EmbedFooter {
pub:
	text			string
	icon_url		string
	proxy_icon_url	string
}
pub struct EmbedImage {
pub:
	url			string
	proxy_url	string
	height		int
	width		int
}
pub struct EmbedProvider {
pub:
	name	string
	url		string
}
pub struct EmbedAuthor {
pub:
	name			string
	url				string
	icon_url		string
	proxy_icon_url	string
}
pub struct EmbedField {
pub:
	name	string
	value	string
	inline	bool
}
pub struct Embed {
pub:
	title		string = ""
	typ			string [json:"type"]
	description	string
	url			string
	timestamp	string
	color		int
	footer		EmbedFooter
	image		EmbedImage
	thumbnail	EmbedImage
	video		EmbedImage
	provider	EmbedProvider
	author		EmbedAuthor
	fields		[]EmbedField
}