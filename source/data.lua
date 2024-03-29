local data = {}

function data.isGoodInteger(field, min)
	if type(field) ~= "number" or field < min or math.floor(field) ~= field then
		return false
	end

	return true
end

function data.isGoodDivisibleInteger(field, min, div)
	if not data.isGoodInteger(field, min) then
		return false
	end

	if field % div ~= 0 then
		return false
	end

	return true
end

return data