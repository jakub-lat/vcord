module vcord

import net.websocket
import eventbus
import time

import vcord.config
import vcord.utils

pub struct Gateway {
	gateway				string
pub:
	token				string
pub mut:
	events				&eventbus.EventBus
	op_events			&eventbus.EventBus
	session_id			string
	shard &Shard
mut:
	ws					&websocket.Client
	logger				&utils.Logger
	sequence			int
	heartbeat_interval	int
	last_heartbeat		u64
}

pub fn new_gateway(s &Shard, c config.Config, mut l utils.Logger) &Gateway {
	url := 'wss://gateway.discord.gg:443/?encoding=json&v=6'
	mut d := &Gateway {
		gateway: url
		token: c.token
		ws: websocket.new(url)
		events: eventbus.new()
		op_events: eventbus.new()
		logger: l,
		shard: s
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

pub fn (mut d Gateway) connect() {
	d.ws.connect()
	go d.ws.listen()
}

fn (mut d Gateway) init_heartbeat() {
	for true {
		time.sleep_ms(1)
		if time.now().unix - d.last_heartbeat > d.heartbeat_interval {
			heartbeat := HeartbeatPacket {
				op: Op.heartbeat
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

fn on_open(mut d Gateway, ws &websocket.Client, _ voidptr) {
	d.shard.status = ShardStatus.connected
	d.logger.info('Shard #$d.shard.id was created')
}

fn on_message(mut d Gateway, msg &websocket.Message, ws &websocket.Client) {
	match msg.opcode {
		.text_frame {
			packet := decode_packet(string(byteptr(msg.payload))) or {
				d.logger.error('cannot decode packet: \n$err')
				return
			}
			d.sequence = packet.sequence
			match packet.op {
				.dispatch { d.op_events.publish('on_dispatch', ws, &packet) }
				.hello { d.op_events.publish('on_hello', ws, &packet) }
				else {}
			}
		}
		else {
			d.logger.warn('unhandled opcode')
		}
	}
}

fn on_hello(mut d Gateway, packet &DiscordPacket, ws &websocket.Client) {
	hello_data := decode_hello_packet(packet.d) or {
		d.logger.warn('cannot decode packet:')
		d.logger.warn(err)
		return
	}
	d.heartbeat_interval = hello_data.heartbeat_interval/1000
	d.last_heartbeat = time.now().unix
	identify_packet := IdentifyPacket{
		token: d.token,
		properties: IdentifyPacketProperties{
			os: 'linux',
			browser: 'vcord',
			device: 'vcord'
		},
		shard: [d.shard.id, d.shard.manager.config.sharding.shards_count],
		guild_subscriptions: true
	}
	encoded := identify_packet.encode()
	d.ws.write(encoded.str, encoded.len, .text_frame)
	go d.init_heartbeat()
}

fn on_ready(mut d Gateway, packet &DiscordPacket, ws &websocket.Client) {

}

fn on_dispatch(mut d Gateway, packet &DiscordPacket, ws &websocket.Client) {
	event := packet.event.to_lower()
	if event == 'ready' {
		ready_packet := decode_ready_packet(packet.d) or { return }
		d.session_id = ready_packet.session_id
	}
	d.events.publish('on_dispatch', d, packet)
}

fn on_close(mut d Gateway, ws &websocket.Client, _ voidptr) {
	d.logger.info('websocket closed')
	d.shard.status = ShardStatus.disconnected
}

fn on_error(mut d Gateway, ws &websocket.Client, err &string) {
	d.logger.error('websocket error:')
	d.logger.error(err)
	d.shard.status = ShardStatus.disconnected
}
