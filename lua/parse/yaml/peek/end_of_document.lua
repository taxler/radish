
local re = require 're'

return re.compile([[

	!. / &(%BOM / ('...' !%S))

]], {
	BOM = require 'parse.match.utf8.bom'
		+ require 'parse.match.utf16le.bom' + require 'parse.match.utf16be.bom'
		+ require 'parse.match.utf32le.bom' + require 'parse.match.utf32be.bom';
})
