module vcord

import json
import vcord.models

pub enum Op {
	dispatch
	heartbeat
	identify
	presence_update
	voice_state_update
	five_undocumented
	resume
	reconnect
	request_guild_members
	invalid_session
	hello
	heartbeat_ack
}

pub struct DiscordPacket {
pub:
	op 			Op
	sequence	int		[json:s]
	event		string	[json:t]
	d			string	[raw]
}

pub struct HelloPacket {
pub:
	heartbeat_interval int
}
pub fn decode_hello_packet(s string) ?HelloPacket {
	packet := json.decode(HelloPacket, s) or { return error(err) }
	return packet
}

pub struct IdentifyPacketProperties {
pub:
	os		string [json:"\$os"]
	browser string [json:"\$browser"]
	device	string [json:"\$device"]
}
pub struct IdentifyPacket {
pub:
	token 				string
	properties 			IdentifyPacketProperties
	compress			bool = false
	large_threshold		int = 250
	shard				[]u16 = [u16(0), u16(1)]
	presence			models.Status
	guild_subscriptions	bool = true
}
pub struct OutboundIdentifyPacket {
	op 	int
	d	IdentifyPacket
}
pub fn (p IdentifyPacket) encode() string {
	return json.encode(OutboundIdentifyPacket {
		op: int(Op.identify),
		d: p
	})
}

pub struct ReadyPacket {
pub:
	v					int
	private_channels	[]string
	guilds				[]models.UnavailableGuild
	session_id			string
	shard				[]int
}
pub fn decode_ready_packet(s string) ?ReadyPacket {
	packet := json.decode(ReadyPacket, s) or { return error(err) }
	return packet
}

pub struct HeartbeatPacket {
pub:
	op 	int
	d	int
}
pub fn (p HeartbeatPacket) encode() string {
	return json.encode(p)
}

pub fn decode_packet(s string) ?DiscordPacket {
	packet := json.decode(DiscordPacket, s) or { return error(err) }
	return packet
}
