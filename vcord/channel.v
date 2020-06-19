module vcord

struct Channel {
pub:
	id string
	name string
mut:
	c &Client [skip]
}

fn (mut chn Channel) inject(c &Client) {
	chn.c = c
}

pub fn (c &Channel) send(content string, msg MessageOpts) {
	c.c.send_message(c.id, content, msg)
}