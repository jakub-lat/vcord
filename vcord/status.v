module vcord

pub enum ActivityTypes {
	game
	streaming
	listening
	custom
}
pub struct ActivityTimestamps {
pub:
	start	int
	end		int
}
pub struct ActivityEmoji {
pub:
	name		string
	id			string
	animated 	bool
}
pub struct ActivityParty {
pub:
	id		string
	size	[]int
}
pub struct ActivityAssets {
pub:
	large_image	string
	large_text	string
	small_image	string
	small_text	string
}
pub struct ActivitySecrets {
pub:
	join		string
	spectate	string
	match_str	string [json:"match"]
}
pub struct Activity {
pub:
	name			string
	typ				ActivityTypes [json:"type"]
	url				string
	created_at 		int
	timestamps		ActivityTimestamps
	application_id	string
	details			string
	state			string
	emoji			ActivityEmoji
	party			ActivityParty
	assets			ActivityAssets
	secrets			ActivitySecrets
	flags			int
}

struct Status {
pub:
	since	int
	game	Activity
	status	string
	afk		bool
}