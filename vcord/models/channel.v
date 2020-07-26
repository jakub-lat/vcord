module models

import json
import vcord.session
import vcord.rest

struct Channel {
pub:
	id string
	name string
mut:
	ctx &session.Ctx [skip]
}

fn (mut chn Channel) inject(ctx &session.Ctx) {
	chn.ctx = ctx
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

pub fn (c &Channel) send(content string, msg MessageOpts) ?Message {
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
	r := rest.post(c.ctx, "channels/$c.id/messages", s) or {
		return error('request error')
	}
	res := json.decode(Message, r) or { return error('failed to parse') }
	return res
}