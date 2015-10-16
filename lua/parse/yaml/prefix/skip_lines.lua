
local m = require 'lpeg'

return require 'parse.yaml.match.skip_lines' * m.Cp()
