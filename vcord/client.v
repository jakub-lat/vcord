module vcord

import hassclient as hc
import eventbus

struct Client {
	eb eventbus.EventBus
	ws hc.HassConection
}

pub fn create_client() Client {
	return Client{
		eb: eventbus.new()
		ws: hc.new_connection(hc.ConnectionConfig {
			hass_uri: "https://gateway.discord.gg/?v=6&encoding=json",
			log_level: log.Level.debug,
			token: ''
		})
	}
}