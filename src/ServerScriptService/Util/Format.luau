--!strict
-- ReplicatedStorage/Shared/Utils/Format
local Format = {}

local SUFFIXES = { "", "K", "M", "B", "T", "Qa", "Qi" }

-- 1520 -> "1.5K", 3000000 -> "3M"
function Format.abbreviate(n: number): string
	if math.abs(n) < 1000 then
		return tostring(math.floor(n))
	end
	local tier = math.min(math.floor(math.log10(math.abs(n)) / 3), #SUFFIXES - 1)
	local scaled = string.format("%.1f", n / 10 ^ (tier * 3))
	scaled = scaled:gsub("%.0$", "")
	return scaled .. SUFFIXES[tier + 1]
end

-- 1234567 -> "1,234,567"
function Format.commas(n: number): string
	local s = tostring(math.floor(n))
	local withCommas = s:reverse():gsub("(%d%d%d)", "%1,"):reverse()
	return (withCommas:gsub("^(-?),", "%1"))
end

-- 125 -> "2:05"
function Format.clock(seconds: number): string
	local s = math.max(0, math.floor(seconds))
	return string.format("%d:%02d", s // 60, s % 60)
end

return Format