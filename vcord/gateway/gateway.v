module gateway

import net.websocket
import eventbus
import time

import vcord.config
import vcord.utils
import vcord.models

pub struct Gateway {
	gateway				string
pub:
	token				string
pub mut:
	events				&eventbus.EventBus
	op_events			&eventbus.EventBus
	session_id			string
mut:
	ws					&websocket.Client
	logger				&utils.Logger
	sequence			int
	heartbeat_interval	int
	last_heartbeat		u64
}

pub fn new_gateway(c config.Config, mut l utils.Logger) &Gateway {
	url := 'wss://gateway.discord.gg:443/?encoding=json&v=6'
	mut d := &Gateway {
		gateway: url
		token: c.token
		ws: websocket.new(url)
		events: eventbus.new()
		op_events: eventbus.new()
		logger: l
	}

	d.ws.subscriber.subscribe_method('on_open', on_open, d)
	d.ws.subscriber.subscribe_method('on_message', on_message, d)
	d.ws.subscriber.subscribe_method('on_error', on_error, d)
	d.ws.subscriber.subscribe_method('on_close', on_close, d)

	d.op_events.subscriber.subscribe_method('on_hello', on_hello, d)
	d.op_events.subscriber.subscribe_method('on_dispatch', on_dispatch, d)

	d.events.subscriber.subscribe_method('on_ready', on_ready, d)

	return d
}

pub fn (mut d Gateway) connect () {
	d.logger.info('connecting...')
	d.ws.connect()
	go d.ws.listen()
	for true {
		time.sleep_ms(1)
		if time.now().unix - d.last_heartbeat > d.heartbeat_interval {
			heartbeat := models.HeartbeatPacket {
				op: models.Op.heartbeat
				d: d.sequence
			}.encode()
			d.logger.debug('HEARTBEAT $heartbeat')
			d.ws.write(heartbeat.str, heartbeat.len, .text_frame)
			d.last_heartbeat = time.now().unix
		}
	}
}

pub fn (mut d Gateway) on(name string, handler eventbus.EventHandlerFn) {
	d.events.subscriber.subscribe(name, handler)
}

pub fn (mut d Gateway) on_method(name string, handler eventbus.EventHandlerFn, receiver voidptr) {
	d.events.subscriber.subscribe_method(name, handler, receiver)
}

fn on_open(mut d Gateway, ws websocket.Client, _ voidptr) {
	d.logger.info('websocket opened')
}

fn on_message(mut d Gateway, ws websocket.Client, msg &websocket.Message) {
	match msg.opcode {
		.text_frame {
			packet := models.decode_packet(string(byteptr(msg.payload))) or {
				d.logger.error('cannot decode packet: \n$err')
				return
			}
			d.sequence = packet.sequence
			match packet.op {
				.dispatch { d.op_events.publish('on_dispatch', &ws, &packet) }
				.hello { d.op_events.publish('on_hello', &ws, &packet) }
				else {}
			}
		}
		else {
			d.logger.warn('unhandled opcode')
		}
	}
}

fn on_hello(mut d Gateway, ws websocket.Client, packet &models.DiscordPacket) {
	hello_data := models.decode_hello_packet(packet.d) or {
		d.logger.warn('cannot decode packet:')
		d.logger.warn(err)
		return
	}
	d.heartbeat_interval = hello_data.heartbeat_interval/1000
	d.last_heartbeat = time.now().unix
	identify_packet := models.IdentifyPacket{
		token: d.token,
		properties: models.IdentifyPacketProperties{
			os: 'linux',
			browser: 'vcord',
			device: 'vcord'
		},
		shard: [0,1],
		guild_subscriptions: true
	}
	encoded := identify_packet.encode()
	d.ws.write(encoded.str, encoded.len, .text_frame)
	
}

fn on_ready(mut d Gateway, ws websocket.Client, packet &models.DiscordPacket) {
	
}

fn on_dispatch(mut d Gateway, ws websocket.Client, packet &models.DiscordPacket) {	
	event := packet.event.to_lower()
	if event == 'ready' {
		ready_packet := models.decode_ready_packet(packet.d) or { return }
		d.session_id = ready_packet.session_id
	}
	d.events.publish('on_dispatch', d, packet)
}

fn on_close(mut d Gateway, ws websocket.Client, _ voidptr) {
	d.logger.info('websocket closed')
}

fn on_error(mut d Gateway, ws websocket.Client, err string) {
	d.logger.error('websocket error:')
	d.logger.error(err)
}
