module vcord

import json

pub struct Client {
pub:
	token string
mut:
	gw Gateway [skip]
	guilds map[string]Guild
	unavaliable_guilds map[string]UnavailableGuild
	evt EventEmitter [skip]
	logger &Logger [skip]
}

pub struct Config {
	token	string
	log_level LogLevel
}

pub fn client(c Config) &Client {
	mut l := new_logger(c.log_level)
	mut d := &Client {
		gw: gateway(c, mut l)
		token: c.token
		logger: l
	}
	d.evt = new_event_emitter(d)

	d.gw.events.subscriber.subscribe_method('on_dispatch', dispatch, d)
	d.gw.events.subscriber.subscribe_method('on_ready', ready, d)
	return d
}

fn ready(mut c Client, _ Gateway, packet &DiscordPacket) {
	r := decode_ready_packet(packet.d) or { return }
	for g in r.guilds {
		c.unavaliable_guilds[g.id] = g
	}
	c.evt.emit('ready', &r)
	c.logger.info('bot ready')
}

fn dispatch(mut c Client, g Gateway, packet &DiscordPacket) {
	event := packet.event.to_lower()
	match event {
		'ready' {
			ready(mut c, g, packet)
		}
		'message_create' {
			mut msg := json.decode(Message, packet.d) or { return }
			msg.member.user = msg.author
			msg.inject(c)
			c.evt.emit('message', &msg)
		}
		'guild_create' {
			mut guild := json.decode(Guild, packet.d) or { return }
			guild.inject(c)
			c.guilds[guild.id] = guild
			if guild.id in c.unavaliable_guilds {
				c.unavaliable_guilds.delete(guild.id)
				println('guild available: $guild.name - $guild.channels.len channels')
			} else {
				c.evt.emit(event, &c.guilds[guild.id])
			}
		}
		else {
			c.evt.emit(event, &packet)
		}
	}
}

pub fn (c &Client) connect() {
	c.gw.connect()
}

pub fn (mut c Client) on(receiver voidptr, name string, handler fn(voidptr, voidptr, voidptr)) {
	c.evt.subscribe(receiver, name, handler)
}

pub fn (c &Client) get_guild(id string) ?&Guild {
	if id in c.guilds {
		return &c.guilds[id]
	}
	return none
}