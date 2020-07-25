module vcord

import net.http
import json

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
	mut s := ""
	if msg.embd == voidptr(0) {
		s = json.encode(RestMessage{
			content: content
			tts: msg.tts
		})
	} else {
		s = json.encode(RestMessageEmbed{
			content: content
			embd: msg.embd
			tts: msg.tts
		})
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
	return c.req("get", p, "")
}

fn (c &Client) post(p string, data string) ?http.Response {
	return c.req("post", p, data)
}

fn (c &Client) delete(p string) ?http.Response {
	return c.req("delete", p, "")
}

fn (c &Client) put(p string, data string) ?http.Response {
	return c.req("put", p, "")
}

fn (c &Client) req(method string, p string, data string) ?http.Response {
	headers := {
		"authorization": "Bot $c.token",
		"content-type": 'application/json'
	}
	res := http.fetch("https://discordapp.com/api/v6/$p", http.FetchConfig{
		method: method,
		headers: headers,
		data: data
	})?

	if res.status_code < 200 || res.status_code >= 300 {
		c.logger.error('api responded with status code $res.status_code')
		c.logger.error(res.text)
	}

	return res
}