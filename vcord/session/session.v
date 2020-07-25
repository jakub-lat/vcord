module session

import vcord.utils

pub struct Ctx {
pub:
	token string
	logger &utils.Logger
}