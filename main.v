module main

import vcord

struct Bot {
	prefix string
}

fn main () {
	mut c := vcord.client(&vcord.Config{
		token: '<TOKEN>'
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

fn on_message(mut b Bot, c &vcord.Client, msg &vcord.Message) {
	println('received msg [main] - chn: $msg.channel.id')
	if msg.content.starts_with(b.prefix) {
		raw_args := msg.content.to_lower().substr(b.prefix.len, msg.content.len).split(' ')
		cmd := raw_args[0]
		mut args := []string{}
		if args.len > 0 {
			args = raw_args[1..]
		}
		match cmd {
			'ping' {
				println('sending message to $msg.channel.id - $msg.channel.name')
				msg.channel.send('Pong!', vcord.MessageOpts{})
			}
			'user' {
				mut u := &msg.member
				println(u.user.tag())
				msg.channel.send('', vcord.MessageOpts{
					embd: &vcord.Embed{
						title: 'User info: ${u.user.tag()}'
						fields: [
							vcord.EmbedField{
								name: 'Nickname'
								value: u.nick
							}
						]
					}
				})
			}
			else {
				msg.channel.send('no', vcord.MessageOpts{})
			}
		}
	}
}