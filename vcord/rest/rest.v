module rest

import net.http
import json

import vcord.session

pub fn delete_message(ctx &session.Ctx, cid string, mid string) ?http.Response {
	return delete(ctx, "channels/${cid}/messages/${mid}")
}

pub struct RestBan {
	reason				string
	delete_message_days int	[json:'delete-message-days']
}
pub fn ban_member(ctx &session.Ctx, gid string, uid string, b RestBan) ?http.Response {
	return put(ctx, "guilds/${gid}/bans/${uid}", json.encode(b))
}

pub fn get(ctx &session.Ctx, p string) ?http.Response {
	return req(ctx, "get", p, "")
}

pub fn post(ctx &session.Ctx, p string, data string) ?http.Response {
	return req(ctx, "post", p, data)
}

pub fn delete(ctx &session.Ctx, p string) ?http.Response {
	return req(ctx, "delete", p, "")
}

pub fn put(ctx &session.Ctx, p string, data string) ?http.Response {
	return req(ctx, "put", p, "")
}

pub fn req(ctx &session.Ctx, method string, p string, data string) ?http.Response {
	headers := {
		"authorization": "Bot $ctx.token",
		"content-type": 'application/json'
	}
	res := http.fetch("https://discordapp.com/api/v6/$p", http.FetchConfig{
		method: method,
		headers: headers,
		data: data
	})?

	if res.status_code < 200 || res.status_code >= 300 {
		ctx.logger.error('api responded with status code $res.status_code')
		ctx.logger.error(res.text)
	}

	return res
}