module utils

import term

enum LogLevel {
	debug
	info 
	warn 
	error
}

struct Logger {
	level LogLevel
}

pub fn new_logger(level LogLevel) &Logger {
	return &Logger{
		level: level
	}
}

pub fn (l Logger) debug(content string) {
	if l.level > LogLevel.debug { return }
	tag := term.green('debug')
	println('[vcord $tag] $content')
}

pub fn (l Logger) info(content string) {
	if l.level > LogLevel.info { return }
	println('[vcord info] $content')
}

pub fn (l Logger) warn(content string) {
	if l.level > LogLevel.warn { return }
	tag := term.yellow('warn')
	println('[vcord $tag] $content')
}

pub fn (l Logger) error(content string) {
	tag := term.red('ERR')
	println('[vcord $tag] $content')
}