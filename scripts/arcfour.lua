rc4 = {}

function rc4.encrypt(plaintext, key)
  sb.logWarn("ItemUtils: RC4 module is deprecated, please upgrade your encryption!")
  if type(plaintext) == "table" then
    plaintext = table.tostring(plaintext)
  end
  if type(plaintext) ~= "string" then
    sb.logError("RC4: Data passed was not string or table!")
    return
  end
  enc_state = rc4.new(key)
  enc_state:generate(3072)
  encrypted = enc_state:cipher(plaintext)
  return encrypted
end

function rc4.decrypt(encrypted, is_table, key)
  sb.logWarn("ItemUtils: RC4 module is deprecated, please upgrade your encryption!")
  dec_state = rc4.new(key)
  dec_state:generate(3072)
  plaintext = dec_state:cipher(encrypted)
  local success
  if is_table then
    local func = load("return "..plaintext)
    if not func then
      sb.logError("ARCFOUR: Failed to decrypt data; wrong encryption key or unknown failure!")
      return
    end
    result = func()
    if type(result) ~= "table" then
      sb.logError("ARCFOUR: Failed to decrypt data; table result expected, %s result instead!", type(result))
      return
    end
    return result
  end
  return plaintext
end

function table.val_to_str(v)
  if "string" == type(v) then
    v = string.gsub(v, "\n", "\\n")
    if string.match(string.gsub(v, "[^'\"]", ""), '^"+$') then
      return "'".. v .."'"
    end
    return '"'..string.gsub(v, '"', '\\"')..'"'
  else
    return "table" == type(v) and table.tostring(v) or tostring(v)
  end
end

function table.key_to_str(k)
  if "string" == type(k) and string.match(k, "^[_%a][_%a%d]*$") then
    return k
  else
    return "["..table.val_to_str(k).."]"
  end
end

function table.tostring(tbl)
  local result, done = {}, {}
  for k, v in ipairs(tbl) do
    table.insert(result, table.val_to_str(v))
    done[k] = true
  end
  for k, v in pairs(tbl) do
    if not done[k] then
      table.insert(result, table.key_to_str(k).."="..table.val_to_str(v))
    end
  end
  return "{"..table.concat(result, ",").."}"
end

-- encoding
function hexlify(data)
  local final = ""
  for i = 1,data:len() do
    byte = string.format("%02X", string.byte(string.sub(data, i)))
    final = final..byte
  end
  return final
end

-- decoding
function unhexlify(data)
  local final = ""
  for i = 1,data:len(),2 do
    final = final..string.char(tonumber(string.sub(data, i, i+1), 16))
  end
  return final
end

-- ARCFOUR implementation in pure Lua
-- Copyright 2008 Rob Kendrick <rjek@rjek.com>
-- Distributed under the MIT licence

local function generate(self, count)
	local S, i, j = self.S, self.i, self.j
	local o = { }
	local char = string.char
	
	for z = 1, count do
		i = (i + 1) % 256
		j = (j + S[i]) % 256
		S[i], S[j] = S[j], S[i]
		o[z] = char(S[(S[i] + S[j]) % 256])
	end
	
	self.i, self.j = i, j
	return table.concat(o)
end

local function cipher(self, plaintext)
	local pad = generate(self, #plaintext)
	local r = { }
	local byte = string.byte
	local char = string.char
	
	for i = 1, #plaintext do
    r[i] = char(byte(plaintext, i) ~ byte(pad, i))
	end
	
	return table.concat(r)
end

local function schedule(self, key)
	local S = self.S
	local j, kz = 0, #key
	local byte = string.byte
	
	for i = 0, 255 do
		j = (j + S[i] + byte(key, (i % kz) + 1)) % 256;
		S[i], S[j] = S[j], S[i]
	end
end

function rc4.new(key)
	local S = { }
	local r = {
		S = S, i = 0, j = 0,
		generate = generate,
		cipher = cipher,
		schedule = schedule	
	}
	
	for i = 0, 255 do
		S[i] = i
	end
	
	if key then
		r:schedule(key)
	end
	
	return r	
end
