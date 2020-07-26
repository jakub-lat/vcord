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
	c cmds.Client
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
	
	mut cmd := cmds.new<Bot>(mut client, cmds.Config{
		prefix: 'v!'
	})
	
	client.connect()
}


[command:"ping"]
[description:"pong"]
fn (b Bot) ping(ctx cmds.Ctx) {
	ctx.channel.send('Pong!', models.MessageOpts{})
}