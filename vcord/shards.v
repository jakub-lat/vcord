module vcord

import vcord.utils
import vcord.config
import time
import eventbus

enum ShardStatus {
	waiting
	connected
	connecting
	reconnecting
	disconnected
}

pub struct Shard {
	pub:
		id u16 = 0

	pub mut:
		gateway &Gateway
		status ShardStatus = ShardStatus.waiting
		manager &ShardingManager
		events	&eventbus.EventBus
}

fn (mut s Shard) spawn() {
	s.gateway = new_gateway(s, s.manager.config, mut s.manager.logger)
	s.gateway.connect()
}

fn new_shard(id u16, manager &ShardingManager) &Shard {
	return &Shard{
		id: id,
		manager: manager
		events: eventbus.new()
	}
}

pub struct ShardingManager {
	mut: logger &utils.Logger
	config config.Config

	pub mut:
		shards []&Shard
		events	&eventbus.EventBus
}

pub fn (mut sm ShardingManager) spawn_shards() {
	mut i := 0
	for i < sm.config.sharding.shards_count {
		mut shard := new_shard(u16(i), sm)
		shard.spawn()
		sm.shards << shard
		if i < sm.config.sharding.shards_count - 1 {
			time.sleep_ms(5000)
		}
		i++
	}
	go sm.check_loop()
}

fn (mut sm ShardingManager) check_loop() {
	for true {
		queue := sm.get_waiting()
		for i, _ in queue {
			mut shard := queue[i]
			shard.status = ShardStatus.reconnecting
			shard.gateway.connect()
			time.sleep_ms(5000)
		}
		time.sleep_ms(5000)
	}
}

fn (mut sm ShardingManager) get_waiting() []&Shard {
	mut shards := []&Shard{}

	for shard in sm.shards {
		if shard.status != ShardStatus.connected && shard.status != ShardStatus.reconnecting && shard.status != ShardStatus.connecting {
			shards << shard
		}
	}

	return shards
}

fn new_manager(logger &utils.Logger, cfg config.Config) &ShardingManager {
	return &ShardingManager{
		logger: logger,
		config: cfg,
		events: eventbus.new()
	}
}