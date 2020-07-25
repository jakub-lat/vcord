module models

import json
import vcord.session
import vcord.rest

pub struct User {
pub:
	id				string
	username		string
	discriminator	string
	avatar			string = ""
	bot				bool = false
	system			bool = false
	mfa_enabled		bool = false
	locale			string = ""
	verified		bool = false
	email			string = ""
	flags			int = 0
	premium_type	int = 0
	public_flags	int = 0
}

pub fn (u &User) mention() string {
	return '<@$u.id>'
}

pub fn (u &User) tag() string {
	return '$u.username#$u.discriminator'
}

struct GuildMember {
mut:
	ctx 			&session.Ctx [skip]
pub:
	nick			string
	roles			[]string
	joined_at		string
	premium_since	string
	deaf			bool
	mute			bool
pub mut:
	guild_id		string
	user 			User
}

fn (mut m GuildMember) inject(ctx &session.Ctx) {
	m.ctx = ctx
}

pub fn get_user(ctx &session.Ctx, id string) ?User {
	r := rest.get(ctx, 'users/$id') or {return none}
	u := json.decode(User, r.text) or {return none}
	return u
}