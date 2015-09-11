
local ffi = require 'ffi'

local audio = {}

audio.loaders = {}

function audio.load(path)
	local failures
	for i, loader in ipairs(audio.loaders) do
		local attempt, message = loader(path)
		if attempt ~= nil then
			return attempt
		else
			failures = failures or {}
			failures[#failures+1] = message
		end
	end
	return nil, failures and table.concat(failures, '\n') or 'failed to read audio data'
end

local default_loaders = {
	require 'radish.audio.loaders.ogg_vorbis';
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
