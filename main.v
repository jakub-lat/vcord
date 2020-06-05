module main

import vcord
import discord.models

fn main () {
	mut c := vcord.client(&vcord.Config{
		token: ''
	})

	c.on('on_ready', on_ready)
	c.on('on_message_create', message)
	c.connect()
}

fn on_ready(packet &vcord.DiscordPacket) {
	println("Bot is ready.")
}

fn message(msg &models.Message) {
	println(msg)
}