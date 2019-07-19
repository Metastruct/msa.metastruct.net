include("sourcenet/incoming.lua")
local cache = {}

local function steamidfromaddr(addr)
	local cached = cache[addr]

	if not cached then
		for k, v in next, player.GetHumans() do
			if v:IPAddress() == addr then
				cached = v:SteamID()
				cache[addr] = cached
			end
		end
	end

	return cached
end

do
--	return PrintTable(steamidfromaddr(me:IPAddress()))
end

local warned

FilterIncomingMessage(net_StringCmd, function(netchan, read, write)
	local cmd = read:ReadString()
	local sid = steamidfromaddr(netchan:GetAddress():ToString())

	if not sid then
		if not warned then
			warned = true
			print("net_StringCmd", netchan, netchan:GetAddress():ToString(), "sent cmd", cmd, "but no player object?")
		end

		return
	end

	if hook.Call("ExecuteStringCommand", nil, sid, cmd) == true then return end
	write:WriteUInt(net_StringCmd, NET_MESSAGE_BITS)
	write:WriteString(cmd)
end)