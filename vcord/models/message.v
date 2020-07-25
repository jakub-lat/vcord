module models

import vcord.session

pub struct MessageOpts {
pub:
	embd    &Embed [json:"embed"] = voidptr(0)
	tts     bool
}

pub enum MessageFlags {
	crossposted
	is_crospost
	suppress_embeds
	source_message_deleted
	urgent
}

pub struct Message {
pub:
	id					string
	channel_id			string
	guild_id			string
	author				User
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
mut:
	ctx 				&session.Ctx [skip]
pub mut:
	member				GuildMember
	guild 				Guild [skip]
	channel				Channel [skip]
}

pub fn (mut m Message) inject(g &Guild) {
	m.guild = g
	chn := m.guild.get_channel(m.channel_id) or {
		m.ctx.logger.error('channel not found')
		return
	}
	m.channel = chn
}