module x

import discord.models
import viscord
import net.websocket
import json

interface EvtData{}

struct Client {
	token  string
mut: 
	evt    map[string]fn(data EvtData)
	c      &viscord.Connection
}

pub fn (mut c Client) on(e string, handler fn(data EvtData)) {
	c.evt[e] = handler
}

pub fn(mut c Client) connect() {
	c.c.connect()
}

fn ready(c Client)
fn message(c Client, msg models.Message)

fn (c Client) on_ready(mut d viscord.Connection, ws websocket.Client, packet &viscord.DiscordPacket) {
	c.evt['ready'](packet)
}
fn (mut cl Client) on_message(mut c Client, _ viscord.Connection, packet &viscord.DiscordPacket) {
	message := json.decode(models.Message, packet.d) or {
		println('failed to parse message')
		return
	}
	c.evt['message'](message)
}

pub fn create_client(token string) Client {
	mut c := viscord.new_connection(viscord.ConnectionConfig{
		gateway: 'wss://gateway.discord.gg:443/?encoding=json&v=6',
		token: token
	})

	mut client := Client{
		c: c,
		evt: map[string]fn(data EvtData)
	}

	client.on_ready(c, websocket.new(''), &viscord.DiscordPacket{})

	println(client.on_ready)
	//c.subscribe('on_ready', client.on_ready)
	//c.subscribe_method('on_message_create', client.on_message, client)

	return client
}