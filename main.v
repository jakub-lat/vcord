module main

import os
import json

import vcord
import vcord.config
import vcord.models
import vcord.cmds

struct Config {
	token string
}
struct Bot {
	prefix string = 'v!'
}

fn main () {

	conf_file := os.read_file('./config.json') or {
		println('config.json not found!')
		return
	}
	conf := json.decode(Config, conf_file) or {
		println('error while decoding config.json: $err')
		return
	}

	mut client := vcord.client(config.Config{
		token: conf.token
		log_level: .info
	})
	
	bot := Bot{}

	client.on(&bot, 'message', on_message)

	/*mut cmd := cmds.new<Bot>(mut client, cmds.Config{
		prefix: 'v!'
	})*/
	
	client.connect()

	client.stay_connection()
}

fn on_message(b &Bot, msg &models.Message, c &vcord.Client) {
	if msg.content.starts_with(b.prefix) {
		raw_args := msg.content.to_lower().substr(b.prefix.len, msg.content.len).split(' ')
		cmd := raw_args[0]
		mut args := []string{}
		if args.len > 0 {
			args = raw_args[1..]
		}

		match cmd {
			'ping' {
				msg.channel.send('Pong!', models.MessageOpts{})
				msg.delete()
			}
			else {}
		}
	}
}

[command:"ping"]
[description:"pong"]
fn (b Bot) ping(ctx cmds.Ctx) {
	println('pong')
	//ctx.channel.send('Pong!', models.MessageOpts{})
}