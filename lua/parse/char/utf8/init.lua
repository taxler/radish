
local m = require 'lpeg'

local m_char = m.P(false)

for i, range_set in ipairs(require 'parse.char.utf8.data.contiguous_byte_ranges') do
	local m_sequence = m.P(true)
	for j, range in ipairs(range_set) do
		if string.sub(range,1,1) == string.sub(range,2,2) then
			m_sequence = m_sequence * string.sub(range,1,1)
		else
			m_sequence = m_sequence * m.R(range)
		end
	end
	m_char = m_sequence + m_char
end

return m_char
