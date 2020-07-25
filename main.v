module main

import os
import json

import vcord
import vcord.models
import vcord.config

struct Bot {
	prefix string
}

struct Config {token string}

fn main () {

	conf_file := os.read_file('./config.json') or {
		println('config.json not found!')
		return
	}
	conf := json.decode(Config, conf_file) or {
		println('error while decoding config.json: $err')
		return
	}

	mut c := vcord.client(&config.Config{
		token: conf.token
		log_level: .info
	})
	mut bot := Bot{
		prefix: 'v!'
	}
	c.on(bot, 'message', on_message)
	c.on(bot, 'ready', on_ready)
	c.connect()
}

fn on_ready(mut b Bot, c &vcord.Client, _ voidptr) {
	println('Bot is ready!')
}

fn on_message(mut b Bot, c &vcord.Client, msg &models.Message) {
	if msg.content.starts_with(b.prefix) {
		raw_args := msg.content.to_lower().substr(b.prefix.len, msg.content.len).split(' ')
		cmd := raw_args[0]
		mut args := []string{}
		if args.len > 0 {
			args = raw_args[1..]
		}
		match cmd {
			'ping' {
				println('channel: $msg.channel.id')
				msg.channel.send('Pong!', models.MessageOpts{})
			}
			'user' {
				mut u := &msg.member
				println(u.user.tag())
				msg.channel.send('', models.MessageOpts{
					embd: &models.Embed{
						title: 'User info: ${u.user.tag()}'
						fields: [
							models.EmbedField{
								name: 'Nickname'
								value: u.nick
							}
						]
					}
				})
			}
			else {
				msg.channel.send('no', models.MessageOpts{})
			}
		}
	}
}