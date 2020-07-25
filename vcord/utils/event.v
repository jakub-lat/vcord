module utils

pub struct Event {
	name string
	receiver voidptr
	handler fn(voidptr, voidptr, voidptr)
}

pub struct EventEmitter {
	mut: events map[string][]Event
	sender voidptr
}

pub fn new_event_emitter(sender voidptr) EventEmitter {
	return EventEmitter{
		events: map[string][]Event
		sender: sender
	}
}

pub fn (mut e EventEmitter) subscribe(receiver voidptr, name string, handler fn(voidptr, voidptr, voidptr)) {
	if e.events[name].len == 0 {
		e.events[name] = []Event{}
	}
	evt := Event{
		name: name
		handler: handler
		receiver: receiver
	}
	e.events[name] << evt
}

pub fn (mut e EventEmitter) emit(name string, data voidptr) {
	handlers := e.events[name]
	for h in handlers {
		h.handler(h.receiver, e.sender, data)
	}
}