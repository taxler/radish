
local ffi = require 'ffi'

local audio = {}

audio.loaders = {}

function audio.load(path)
	for i, loader in ipairs(audio.loaders) do
		local attempt, message = loader(path)
		if attempt ~= nil then
			return attempt
		else
			--print(message)
		end
	end
	return nil
end

local default_loaders = {
	require 'radish.audio.loaders.dumb';
	require 'radish.audio.loaders.game_music_emu';
	require 'radish.audio.loaders.mpg123'; -- false positives?
}
for i, loader in ipairs(default_loaders) do
	if loader then
		audio.loaders[#audio.loaders + 1] = loader
	end
end

return audio
