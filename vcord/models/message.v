module models

import vcord

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
	c 					&Client [skip]
pub mut:
	member				GuildMember
	guild 				Guild [skip]
	channel				Channel [skip]
}

fn (mut m Message) inject(mut c vcord.Client) {
	m.c = c
	g := m.c.get_guild(m.guild_id) or {
		c.logger.error('guild not available')
		return
	}
	m.guild = g
	chn := m.guild.get_channel(m.channel_id) or {
		c.logger.error('channel not found')
		return
	}
	m.channel = chn
}