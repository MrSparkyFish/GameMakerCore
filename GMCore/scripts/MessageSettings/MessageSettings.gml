/** MessageSettings: Represents Config settings that determine how the Message class formats strings.
 * @arg {String} _messageFormat The format string to use. Accepts placeholders {message}, {time}, and {subject}
 * @arg {String} _timeFormat The format string to use. Accepts placeholders {Y}, {M}, {D}, {h}, {m}, and {s}
 * @return {Struct.MessageSettings} */
function MessageSettings(_messageFormat = undefined, _timeFormat = undefined) constructor {
	timeFormat = _timeFormat ?? "{3}:{4}:{5}";
	messageFormat = _messageFormat ?? "[{2}]: {0}";
}