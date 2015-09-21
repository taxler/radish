
local m = require 'lpeg'
local re = require 're'

return re.compile([[

	prefix_declaration <- (text_declaration / %NIL) {}
	text_declaration <- '<?xml' {| version_info encoding_decl? standalone_decl? %s* |} '?>'
	version_info <- %s+ 'version' %s* '=' %s* ((['] version_num [']) / (["] version_num ["]))
	version_num <- {:version: '1.' [0-9] :}
	encoding_decl <- %s+ 'encoding' %s* '=' %s* ((['] enc_name [']) / (["] enc_name ["]))
	enc_name <- {:encoding: [A-Za-z] [-A-Za-z0-9._]* :}
	standalone_decl <- %s+ 'standalone' %s* '=' %s* ((['] standalone [']) / (["] standalone ["]))
	standalone <- {:standalone: ('yes' %TRUE) / ('no' %FALSE) :}

	SQ <- "'"
	DQ <- "'"

]], {
	NIL = m.Cc(nil);
	TRUE = m.Cc(true);
	FALSE = m.Cc(false);
})
