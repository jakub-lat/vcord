module models

pub enum Perm {
	create_instant_invite = 1
	kick_members = 2
	ban_members = 4
	administrator = 8
	manage_channels = 16
	manage_guild = 32
}

type Perms int

pub fn parse_perms(i int) Perms {
	return Perms(i)
}