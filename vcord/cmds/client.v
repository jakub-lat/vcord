module cmds

import vcord
import vcord.models

struct Command {
	name string
	description string
	method_name string
}

struct Client {
pub mut:
	commands map[string]Command
	client &vcord.Client
	config Config
	bot voidptr
}

pub struct Config {
	prefix string
}

struct Ctx {
pub:
	channel &models.Channel
}

pub fn new<T>(mut client vcord.Client, config Config) Client {
	mut c := &Client{
		client: client
		config: config
		bot: &T{}
	}

	client.on(c, 'message', on_message)

	$for method in T.methods {
		mut name := ''
		mut desc := ''
		for attr in method.attrs {
			if attr.starts_with('command:') {
				name = attr.replace('command:', '')
			} else if(attr.starts_with('description:')) {
				desc = attr.replace('description:', '')
			}
		}
		if name != '' {
			println('found command: $name')
			cmd := Command{
				name: name
				description: desc
				method_name: method.name
				handler: method
			}
			/*if name !in c.commands {
				c.commands[name] = []Command{}
			}*/
			c.commands[name] = cmd
		}
	}
	return c
}

fn on_message(c &Client, msg &models.Message, _ voidptr) {
	prefix := c.config.prefix
	if msg.content.starts_with(prefix) {
		raw_args := msg.content.to_lower().substr(prefix.len, msg.content.len).split(' ')
		cmd_name := raw_args[0]
		mut args := []string{}
		if args.len > 0 {
			args = raw_args[1..]
		}
		if cmd_name in c.commands {
			println('invoking command $cmd_name')
			cmd := c.commands[cmd_name]
			method_name := cmd.method_name
			ctx := Ctx{
				channel: msg.channel
			}
			c.bot.$method_name(ctx)
		}
	}
}