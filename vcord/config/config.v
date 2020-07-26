module config

import vcord.utils

pub struct Config {
pub:
	token	string
	log_level utils.LogLevel
	sharding &ShardingConfig = &ShardingConfig{}
}

pub struct ShardingConfig {
	pub:
		enabled bool = true
		shards_count u16 = 1
}