
local ffi = require 'ffi'

local audio = {}

audio.loaders = {}

function audio.load(path)
	for i, loader in ipairs(audio.loaders) do
		local attempt = loader(path)
		if attempt ~= nil then
			return attempt
		end
	end
	return nil
end

local default_loaders = {
	require 'radish.audio.loaders.dumb';	
}
for i, loader in ipairs(default_loaders) do
	if loader then
		audio.loaders[#audio.loaders + 1] = loader
	end
end

return audio
