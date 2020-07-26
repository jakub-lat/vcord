module models

import json
import vcord.session
import vcord.rest

struct Guild {
pub:
	id string
	name string
	icon string
	member_count int
mut:
	ctx &session.Ctx [skip]
	channels []Channel
	roles []Role
pub mut:
	members map[string]GuildMember [skip]
}

struct UnavailableGuild {
pub:
	id			string
	unavailable	bool
}

pub fn (mut g Guild) inject(ctx &session.Ctx) {
	g.ctx = ctx
	for i, _ in g.channels {
		g.channels[i].inject(ctx)
	}
}

pub fn (g Guild) get_channel(id string) ?&Channel {
	for chn in g.channels {
		if chn.id == id {
			return &chn
		}
	}
	return none
}

pub fn (g Guild) get_role(id string) ?&Role {
	for r in g.roles {
		if r.id == id {
			return &r
		}
	}
	return none
}

pub fn (mut g Guild) get_member(id string) ?&GuildMember {
	if id in g.members {
		return &g.members[id]
	} else {
		r := rest.get(g.ctx, 'guilds/$g.id/members/$id') or {return none}
		mut member := json.decode(GuildMember, r) or {return none}
		member.guild_id = g.id
		member.inject(g.ctx)
		g.members[member.user.id] = member
		return &member
	}
}

pub fn (mut g Guild) fetch_all_members() {
	r := rest.get(g.ctx, 'guilds/$g.id/members') or {return}
	mut members := json.decode([]GuildMember, r) or {return}
	for i, m in members {
		members[i].guild_id = g.id
		members[i].inject(g.ctx)
		g.members[m.user.id] = m
	}
}