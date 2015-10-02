local re = require 're'

local m_hex = re.compile [[ '-'? '0x' %x+ ]]

return {
	apply = function(self, patterns)
		patterns.NUMBER = m_hex + patterns.NUMBER
	end
}
