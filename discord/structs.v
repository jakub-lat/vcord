module discord

// ======================================= //
//    Hey, fyi, a lot of this has to be    //
//     commented out to compile due to     //
//     optionals being limited to 400b     //
//     this will be fixed in the future    //
// ======================================= //
//    In the future i plan to move all     //
//     of these structs into their own     //
//    files based on their relationship    //
// ======================================= //



pub struct User {
pub:
	id				string
	username		string
	discriminator	string
	avatar			string = ""
	bot				bool = false
	system			bool = false
	mfa_enabled		bool = false
	locale			string = ""
	verified		bool = false
	email			string = ""
	flags			int = 0
	premium_type	int = 0
	public_flags	int = 0
}

pub struct GuildMember {
pub:
	nick			string
	roles			[]string
	joined_at		string
	premium_since	string
	deaf			bool
	mute			bool
}

pub struct ChannelMention {
pub:
	id			string
	guild_id	string
	typ			int [json:"type"]
	name		string
}

pub struct Attachment {
pub:
	id			string
	filename	string
	size		int
	url			string
	proxy_url	string
	height		int
	width		int
}



pub struct Emoji {
pub:
	id				string
	name			string
	roles			[]string
	//user			User
	require_colons	bool
	managed			bool
	animated		bool
	available		bool
}
pub struct Reaction {
pub:
	count	int
	me		bool
	emoji	Emoji
}

pub enum MessageTypes {
	default_message
	recipient_add
	recipient_remove
	call
	channel_name_change
	channel_icon_change
	channel_pinned_message
	guild_member_join
	user_premium_guild_subscription
	user_premium_guild_subscription_tier_1
	user_premium_guild_subscription_tier_2
	user_premium_guild_subscription_tier_3
	channel_follow_add
	guild_discovery_disqualified
	guild_discovery_requalifie
}
pub enum MessageFlags {
	crossposted
	is_crospost
	suppress_embeds
	source_message_deleted
	urgent
}
pub enum MessageActivityType {
	join
	spectate
	listen
	join_request
}
pub struct MessageActivity {
pub:
	typ			MessageActivityType [json:"type"]
	party_id	string
}
pub struct MessageApplication {
pub:
	id			string
	cover_image	string
	description	string
	icon		string
	name		string
}
pub struct MessageReference {
pub:
	message_id	string
	channel_id	string
	guild_id	string
}
pub struct Message {
pub:
	id					string
	channel_id			string
	guild_id			string
	author				User
	member				GuildMember
	content				string
	timestamp			string
	edited_timestamp	string	
	tts					bool
	mention_everyone	bool	
	mentions			[]User
	//mention_roles		[]string
	//mention_channels	[]ChannelMention
	//attachments			[]Attachment
	//embeds				[]Embed
	//reactions			[]Reaction
	nonce				string
	pinned				bool
	webhook_id			string
	typ					int [json:"type"]				
	//activity			MessageActivity
	//application			MessageApplication
	//message_reference	MessageReference
	flags				MessageFlags
}

pub struct UnavailableGuild {
pub:
	id			string
	unavailable	bool
}