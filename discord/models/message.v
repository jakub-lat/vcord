module models

struct Message {
	id					string
	channel_id			string
	guild_id			string
	content				string
	author				User
	timestamp			string
	mentions			[]User
}