module models

import json
import vcord

struct Channel {
pub:
	id string
	name string
mut:
	c &Client [skip]
}

fn (mut chn Channel) inject(c &vcord.Client) {
	chn.c = c
}

pub fn (c Channel) send(content string, msg MessageOpts) {
	print('channel:')
	println(json.encode(c))
	c.c.send_message(c.id, content, msg)
}