module rest

import net.http

import vcord.session

pub struct RestBan {
	reason				string
	delete_message_days int	[json:'delete-message-days']
}
pub fn get(ctx &session.Ctx, p string) ?string {
	return req(ctx, "get", p, "")
}

pub fn post(ctx &session.Ctx, p string, data string) ?string {
	return req(ctx, "post", p, data)
}

pub fn delete(ctx &session.Ctx, p string) ?string {
	return req(ctx, "delete", p, "")
}

pub fn put(ctx &session.Ctx, p string, data string) ?string {
	return req(ctx, "put", p, "")
}

pub fn req(ctx &session.Ctx, method string, p string, data string) ?string {
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
		return error(res.text)
	}

	return res.text
}