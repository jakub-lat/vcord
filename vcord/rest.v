module vcord
import net.http
import discord
import json

pub struct RestMessage {
	content	string
	m_embed	discord.Embed [json:"embed"]
}
pub fn (c Client) send_message(cid string, m RestMessage) ?http.Response {
	return c.post("channels/${cid}/messages", json.encode(m))
} 
pub fn (c Client) delete_message(cid string, mid string) ?http.Response {
	return c.delete("channels/${cid}/messages/${mid}")
}

pub struct RestBan {
	reason				string
	delete_message_days int	[json:'delete-message-days']
}
pub fn (c Client) ban_member(gid string, uid string, b RestBan) ?http.Response {
	return c.put("guilds/${gid}/bans/${uid}", json.encode(b))
}

fn (c Client) post(p string, data string) ?http.Response {
	headers := {
		"authorization": "Bot $c.token",
		"content-type": "application/json"
	}

	res := http.fetch("https://discordapp.com/api/v6/$p", http.FetchConfig{
		method: "post",
		headers: headers,
		data: data
	})?
	return res
}

fn (c Client) delete(p string) ?http.Response {
	headers := {
		"authorization": "Bot $c.token",
		"content-type": 'application/json'
	}

	res := http.fetch("https://discordapp.com/api/v6/$p", http.FetchConfig{
		method: "delete",
		headers: headers
	})?
	return res
}

fn (c Client) put(p string, data string) ?http.Response {
	headers := {
		"authorization": "Bot $c.token",
		"content-type": 'application/json'
	}

	res := http.fetch("https://discordapp.com/api/v6/$p", http.FetchConfig{
		method: "put",
		headers: headers,
		data: data
	})?
	return res
}