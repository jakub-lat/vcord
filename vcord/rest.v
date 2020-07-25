module vcord

import net.http
//import discord
import json

pub struct MessageOpts {
	embd    &Embed [json:"embed"] = voidptr(0)
	tts     bool
}
struct RestMessage {
	content string
	tts bool = false
}
struct RestMessageEmbed {
	content	string
	embd    Embed [json:"embed"]
	tts bool = false
}
pub fn (c &Client) send_message(cid string, content string, msg MessageOpts) ?Message {
	println('sending message to $cid')
	mut s := ""
	if msg.embd == voidptr(0) {
		s = json.encode(RestMessage{
			content: content
			tts: msg.tts
		})
		println(s)
	} else {
		s = json.encode(RestMessageEmbed{
			content: content
			embd: msg.embd
			tts: msg.tts
		})
		println(s)
	}
	r := c.post("channels/${cid}/messages", s) or {
		return error('request error')
	}
	res := json.decode(Message, r.text) or { return error('failed to parse') }
	return res
} 
pub fn (c &Client) delete_message(cid string, mid string) ?http.Response {
	return c.delete("channels/${cid}/messages/${mid}")
}

pub struct RestBan {
	reason				string
	delete_message_days int	[json:'delete-message-days']
}
pub fn (c &Client) ban_member(gid string, uid string, b RestBan) ?http.Response {
	return c.put("guilds/${gid}/bans/${uid}", json.encode(b))
}

pub fn (c &Client) get_user(id string) ?User {
	r := c.get('users/$id') or {return none}
	u := json.decode(User, r.text) or {return none}
	return u
}

fn (c &Client) get(p string) ?http.Response {
	headers := {
		"authorization": "Bot $c.token",
		"content-type": "application/json"
	}

	res := http.fetch("https://discordapp.com/api/v6/$p", http.FetchConfig{
		method: "get",
		headers: headers
	})?

	if res.status_code < 200 || res.status_code >= 300 {
		c.logger.error('api responded with status code $res.status_code')
		c.logger.error(res.text)
	}
	
	return res
}

fn (c &Client) post(p string, data string) ?http.Response {
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

fn (c &Client) delete(p string) ?http.Response {
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

fn (c &Client) put(p string, data string) ?http.Response {
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