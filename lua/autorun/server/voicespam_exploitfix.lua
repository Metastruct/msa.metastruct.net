--
-- Exploit fix provided by Python1320 of Metastruct Security Agency - http://msa.metastruct.net/
--
-- Blocks voice spam by hooking into BroadcastVoiceData function of the engine
-- The exploit uses a spam of zero byte voice messages that are most likely out of spec
-- Potentially higher byte message sizes might be used, but this is yet to be patched by this code.
--
-- Stay tuned for an improved version!
--
-- If you like what we do please donate at https://paypal.me/pR4uskPx or report a bug we can investigate!

local Tag = 'voicespamfix'

require 'vlog'
--[[
Source:
svn://svn.metastruct.net/gbins 
username anon
password anon
folder vlog
]]

-- Add your custom kick/ban here!
local function punish(pl, maybewrong)
	if hook.Run("OnVoiceSpam",pl,maybewrong)~=true then
		print(tostring(pl) .. ' is exploiting voice ' .. (maybewrong and "maybewrong" or ""))
		pl:Kick"voice exploit"
	end
end

-- how many messages observed per frame of this message type
local framemsgcounts = {}
_G.delme_framemsgcounts = framemsgcounts

-- maximum voice message per player per frame
local max = 15
local framemsgcounts = setmetatable({}, {})

-- when was player last spamming in tick counts
local lastspams = setmetatable({}, {
	__index = function(_, pl)
		local ret = 0
		_[pl] = ret

		return ret
	end
})

_G.delme_lastspams = lastspams

local now = 0
local voicespammed1, voicespammed2 = {}, {}

hook.Add('BroadcastVoiceData', Tag, function(userid, len)
	if now - lastspams[userid] < 1 then
		lastspams[userid] = now

		return true
	end

	if len == 0 then
		local framemsgcount = framemsgcounts[userid]

		if not framemsgcount then
			framemsgcount = 0
		end

		if framemsgcount > max then
			--max=framemsgcount
			if not voicespammed1[userid] then
				voicespammed1[userid] = true
				local pl = Entity(userid + 1)
				punish(pl, false)
			end

			lastspams[userid] = now

			return true
		end

		framemsgcount = framemsgcount + 1
		framemsgcounts[userid] = framemsgcount
	else
		-- TODO
	end
end)

hook.Add("Tick", Tag, function()
	now = (now + 1) % (2 ^ 50)

	for k, framemsgcount in next, framemsgcounts do
		framemsgcounts[k] = 0
	end
end)