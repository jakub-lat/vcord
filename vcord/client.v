module vcord

import json
import eventbus
import vcord.utils
import vcord.config
import vcord.models
import vcord.session

pub struct Client {
pub:
	token string
mut:
	gw Gateway [skip]
	guilds map[string]models.Guild
	unavaliable_guilds map[string]models.UnavailableGuild
	eb &eventbus.EventBus [skip]
	logger &utils.Logger [skip]
	ctx &session.Ctx [skip]
}

pub fn client(c config.Config) &Client {
	mut l := utils.new_logger(c.log_level)
	mut d := &Client {
		gw: new_gateway(c, mut l)
		token: c.token
		logger: l
		ctx: &session.Ctx{
			token: c.token
			logger: l
		}
		eb: eventbus.new()
	}

	d.gw.events.subscriber.subscribe_method('on_dispatch', dispatch, d)
	d.gw.events.subscriber.subscribe_method('on_ready', ready, d)
	return d
}

fn ready(mut c Client, _ &Gateway, packet &DiscordPacket) {
	r := decode_ready_packet(packet.d) or { return }
	for g in r.guilds {	
		c.unavaliable_guilds[g.id] = g
	}
	c.eb.publish('ready', c, &r)
	c.logger.info('bot ready')
}

fn dispatch(mut c Client, packet &DiscordPacket, g &Gateway) {
	event := packet.event.to_lower()
	match event {
		'ready' {
			ready(mut c, g, packet)
		}
		'message_create' {
			mut msg := json.decode(models.Message, packet.d) or { return }
			msg.member.user = msg.author
			guild := c.get_guild(msg.guild_id) or {
				c.logger.error('guild not available')
				return
			}
			msg.inject(c.ctx, guild)
			c.eb.publish('message', c, &msg)
		}
		'guild_create' {
			mut guild := json.decode(models.Guild, packet.d) or { return }
			guild.inject(c.ctx)
			c.guilds[guild.id] = guild
			if guild.id in c.unavaliable_guilds {
				c.unavaliable_guilds.delete(guild.id)
			} else {
				c.eb.publish(event, c, &c.guilds[guild.id])
			}
		}
		else {
			c.eb.publish(event, c, &packet)
		}
	}
}

pub fn (mut c Client) connect() {
	c.gw.connect()
}

pub fn (mut c Client) on(receiver voidptr, name string, handler fn(voidptr, voidptr, voidptr)) {
	c.eb.subscriber.subscribe_method(name, handler, receiver)
}

pub fn (c Client) get_guild(id string) ?&models.Guild {
	if id in c.guilds {
		return &c.guilds[id]
	}
	return none
}