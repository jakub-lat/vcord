module vcord

pub struct Role {
	permissions int
	color int
pub:
	id string
	position int
	name string
	mentionable bool
	managed bool
	hoist bool
}

pub fn (r &Role) perms() Perms {
	return parse_perms(r.permissions)
}

pub fn(r &Role) color() Color {
	return parse_color(r.color)
}