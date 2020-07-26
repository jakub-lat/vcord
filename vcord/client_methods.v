module vcord

import json
import vcord.models
import vcord.rest

pub fn (c &Client) get_user(id string) ?models.User {
	r := rest.get(c.ctx, 'users/$id')?
	u := json.decode(models.User, r)?
	return u
}