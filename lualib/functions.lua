math.atan2 = math.atan
-- local GlobolPrint = print
-- function print(...)
--     GlobolPrint(...)
--     GlobolPrint (debug.traceback())
-- end

-- 打印出tbl的所有(key, value)

-- 该函数主要功能是自动计算缩进层次打印出table内容

local tab_indent_count = 0

function printf(...)
    print(string.format(...))
end

function printt(tbl)
    if (tbl == nil) then
        print ("Error, in LuaUtil.lua file. You must pass \"table name\" and \"table`s data\" to print_table function.")
        return
    end
    local tabs = ""
    for i = 1, tab_indent_count do
        tabs = tabs .. "    "
    end
    local param_type = type(tbl)
    if param_type == "table" then
        for k, v in pairs(tbl) do
            -- 如果value还是一个table，则递归打印其内容
            if (type(v) == "table") then
                print (string.format("T %s.%s", tabs, k))
                -- 子table加一个tab缩进
                tab_indent_count = tab_indent_count + 1
                printt (v)
                -- table结束，则退回一个缩进
                tab_indent_count = tab_indent_count - 1
            elseif (type(v) == "number") then
                print (string.format("N %s.%s: %d", tabs, k, v))
            elseif (type(v) == "string") then
                print (string.format("S %s.%s: \"%s\"", tabs, k, v))
            elseif (type(v) == "boolean") then
                print (string.format("B %s.%s: %s", tabs, k, tostring(v)))
            elseif (type(v) == "nil") then
                print (string.format("N %s.%s: nil", tabs, k))
            elseif (type(v) == "function") then
                print (string.format("N %s.%s: function: %s", tabs, k, v))
            else
                print (string.format("%s%s=%s: unexpected type value? type is %s", tabs, k, v, type(v)))
            end
        end
    end
end

function tonum(v, base)
    return tonumber(v, base) or 0
end

function toint(v)
    return math.round(tonum(v))
end

function tobool(v)
    return (v ~= nil and v ~= false)
end

function totable(v)
    if type(v) ~= "table" then v = {} end
    return v
end

function isset(arr, key)
    local t = type(arr)
    return (t == "table" or t == "userdata") and arr[key] ~= nil
end

function clone(object)
    local lookup_table = {}
    local function _copy(object)
        if type(object) ~= "table" then
            return object
        elseif lookup_table[object] then
            return lookup_table[object]
        end
        local new_table = {}
        lookup_table[object] = new_table
        for key, value in pairs(object) do
            new_table[_copy(key)] = _copy(value)
        end
        return setmetatable(new_table, getmetatable(object))
    end
    return _copy(object)
end

function copy(object)
    if not object then return object end
	 local new = {}
	 for k, v in pairs(object) do
		local t = type(v)
		if t == "table" then
			new[k] = copy(v)
		elseif t == "userdata" then
			new[k] = copy(v)
		else
			new[k] = v
		end
	 end
    return new
end

function class(classname, super)
    local cls

	if super then
		cls = {}
		setmetatable(cls, {__index = super})
		cls.super = super
	else
		cls = {ctor = function() end}
	end

	cls.__cname = classname
	cls.__ctype = 2 -- lua
	cls.__index = cls

	function cls.new(...)
		local instance = setmetatable({}, cls)
		instance.class = cls
		instance:ctor(...)
		return instance
	end

   return cls
end

function iskindof(obj, className)
    local t = type(obj)

    if t == "table" then
        local mt = getmetatable(obj)
        while mt and mt.__index do
            if mt.__index.__cname == className then
                return true
            end
            mt = mt.super
        end
        return false

    elseif t == "userdata" then

    else
        return false
    end
end

function import(moduleName, currentModuleName)
    local currentModuleNameParts
    local moduleFullName = moduleName
    local offset = 1

    while true do
        if string.byte(moduleName, offset) ~= 46 then -- .
            moduleFullName = string.sub(moduleName, offset)
            if currentModuleNameParts and #currentModuleNameParts > 0 then
                moduleFullName = table.concat(currentModuleNameParts, ".") .. "." .. moduleFullName
            end
            break
        end
        offset = offset + 1

        if not currentModuleNameParts then
            if not currentModuleName then
                local n,v = debug.getlocal(3, 1)
                currentModuleName = v
            end

            currentModuleNameParts = string.split(currentModuleName, ".")
        end
        table.remove(currentModuleNameParts, #currentModuleNameParts)
    end

    return require(moduleFullName)
end

function handler(target, method)
    return function(...)
        return method(target, ...)
    end
end

function math.round(num)
    return math.floor(num + 0.5)
end

local __randomseed = tostring(os.time()):reverse():sub(1, 6)
math.randomseed(__randomseed)
function math.rand(...)
    return math.random(...)
end

local mathatan = math.atan2 or math.atan
local mathpi = math.pi
function math.atan2(dy, dx)
    local angle = mathatan(dy, dx)
    if angle < 0 then
        angle = angle + 2 * mathpi
    end
    return angle
end

function io.exists(path)
    local file = io.open(path, "r")
    if file then
        io.close(file)
        return true
    end
    return false
end

function io.readfile(path)
    local file = io.open(path, "r")
    if file then
        local content = file:read("*a")
        io.close(file)
        return content
    end
    return nil
end

function io.writefile(path, content, mode)
    mode = mode or "w+b"
    local file = io.open(path, mode)
    if file then
        if file:write(content) == nil then return false end
        io.close(file)
        return true
    else
        return false
    end
end

function io.pathinfo(path)
    local pos = string.len(path)
    local extpos = pos + 1
    while pos > 0 do
        local b = string.byte(path, pos)
        if b == 46 then -- 46 = char "."
            extpos = pos
        elseif b == 47 then -- 47 = char "/"
            break
        end
        pos = pos - 1
    end

    local dirname = string.sub(path, 1, pos)
    local filename = string.sub(path, pos + 1)
    extpos = extpos - pos
    local basename = string.sub(filename, 1, extpos - 1)
    local extname = string.sub(filename, extpos)
    return {
        dirname = dirname,
        filename = filename,
        basename = basename,
        extname = extname
    }
end

function io.filesize(path)
    local size = false
    local file = io.open(path, "r")
    if file then
        local current = file:seek()
        size = file:seek("end")
        file:seek("set", current)
        io.close(file)
    end
    return size
end

function table.nums(t)
    local count = 0
    for k, v in pairs(t) do
        count = count + 1
    end
    return count
end

function table.empty(t)
    return _G.next(t) == nil
end

function table.keys(t)
    local keys = {}
    for k, v in pairs(t) do
        keys[#keys + 1] = k
    end
    return keys
end

function table.values(t)
    local values = {}
    for k, v in pairs(t) do
        values[#values + 1] = v
    end
    return values
end

-- k v翻转
function table.valueToKey(t)
    local keys = {}
    for k,v in pairs(t) do
        if type(v) == "table" or type(v) == "function" then
            return nil
        end
        keys[v] = k
    end
    return keys
end

function table.merge(dest, src)
    for k, v in pairs(src) do
        dest[k] = v
    end
end

function table.mergeNumberArray(dest, src)
    for k, v in pairs(src) do
        dest[#dest + 1] = v
    end
end

function table.length(tbl)
    local length = 0
    for _, v in pairs(tbl) do
        length = length + 1
    end
    return length
end

--[[--

insert list.

**Usage:**

    local dest = {1, 2, 3}
    local src  = {4, 5, 6}
    table.insertto(dest, src)
    -- dest = {1, 2, 3, 4, 5, 6}
	dest = {1, 2, 3}
	table.insertto(dest, src, 5)
    -- dest = {1, 2, 3, nil, 4, 5, 6}


@param table dest
@param table src
@param table begin insert position for dest
]]
function table.insertto(dest, src, begin)
	begin = tonumber(begin)
	if begin == nil then
		begin = #dest + 1
	end

	local len = #src
	for i = 0, len - 1 do
		dest[i + begin] = src[i + 1]
	end
end

--[[
search target index at list.

@param table list
@param * target
@param int from idx, default 1
@param bool useNaxN, the len use table.maxn(true) or #(false) default:false
@param return index of target at list, if not return -1
]]
function table.indexof(list, target, from, useMaxN)
	local len = (useMaxN and #list) or table.maxn(list)
	if from == nil then
		from = 1
	end
	for i = from, len do
		if list[i] == target then
			return i
		end
	end
	return -1
end

function table.indexofKey(list, key, value, from, useMaxN)
	local len = (useMaxN and #list) or table.maxn(list)
	if from == nil then
		from = 1
	end
	local item = nil
	for i = from, len do
		item = list[i]
		if item ~= nil and item[key] == value then
			return i
		end
	end
	return -1
end

function table.removeItem(t, item, removeAll)
    for i = #t, 1, -1 do
        if t[i] == item then
            table.remove(t, i)
            if not removeAll then break end
        end
    end
end

function table.removeAll(t)
    for i = #t, 1, -1 do
        table.remove(t, i)
    end
end


function table.map(t, fun)
    for k,v in pairs(t) do
        t[k] = fun(v, k)
    end
end

function table.walk(t, fun)
    for k,v in pairs(t) do
        fun(v, k)
    end
end

function table.filter(t, fun)
    for k,v in pairs(t) do
        if not fun(v, k) then
            t[k] = nil
        end
    end
end

function table.find(t, item)
    return table.keyOfItem(t, item) ~= nil
end

function table.unique(t)
    local r = {}
    local n = {}
    for i = #t, 1, -1 do
        local v = t[i]
        if not r[v] then
            r[v] = true
            n[#n + 1] = v
        end
    end
    return n
end

function table.keyOfItem(t, item)
    for k,v in pairs(t) do
        if v == item then return k end
    end
    return nil
end

function table.renameKey(t, old, new)
    assert(t[old], string.format("key of %s dose not exist!", old))
    t[new] = t[old]
    t[old] = nil
end

--二分查找
function table.bsearch(elements, x, field, low, high)
    local meta = getmetatable(elements)
    low = low or 1
    high = high or (meta and meta.__len(elements) or #elements)
    if low > high then
        return -1, low, high
    end

    local mid = math.ceil((low + high) / 2)
    local element = elements[mid]
    local value = field and element[field] or element

    if x == value then
        while mid > 1 do
            local prev = elements[mid - 1]
            value = field and prev[field] or prev
            if x ~= value then
                break
            end
            mid = mid - 1
            element = prev
        end
        return mid
    end

    if x < value then
        return table.bsearch(elements, x, field, low, mid - 1)
    end

    if x > value then
        return table.bsearch(elements, x, field, mid + 1, high)
    end
end

function table.lowerBound(elements, x, field)
    local first = 0
    local mid, half
    local len = #elements
    while len > 0 do
        half = math.floor(len / 2)
        mid = first + half
        local element = elements[mid + 1]
        local value = field and element[field] or element
        if value < x then
            first = mid + 1
            len = len - half - 1
        else
            len = half
        end
    end
    return first + 1
end

function table.upperBound(elements, x, field)
    local first = 0
    local mid, half
    local len = #elements - 1
    while len > 0 do
        half = math.floor(len / 2)
        mid = first + half
        local element = elements[mid + 1]
        local value = field and element[field] or element
        if value > x then
            len = half
        else
            first = mid + 1
            len = len - half - 1
        end
    end
    return first + 1
end

function string.htmlspecialchars(input)
    for k, v in pairs(string._htmlspecialchars_set) do
        input = string.gsub(input, k, v)
    end
    return input
end
string._htmlspecialchars_set = {}
string._htmlspecialchars_set["&"] = "&amp;"
string._htmlspecialchars_set["\""] = "&quot;"
string._htmlspecialchars_set["'"] = "&#039;"
string._htmlspecialchars_set["<"] = "&lt;"
string._htmlspecialchars_set[">"] = "&gt;"

function string.htmlspecialcharsDecode(input)
    for k, v in pairs(string._htmlspecialchars_set) do
        input = string.gsub(input, v, k)
    end
    return input
end

function string.nl2br(input)
    return string.gsub(input, "\n", "<br />")
end

function string.text2html(input)
    input = string.gsub(input, "\t", "    ")
    input = string.htmlspecialchars(input)
    input = string.gsub(input, " ", "&nbsp;")
    input = string.nl2br(input)
    return input
end

function string.split(str, delimiter)
    str = tostring(str)
    delimiter = tostring(delimiter)
    if (delimiter=='') then return false end
    local pos,arr = 0, {}
    -- for each divider found
    for st,sp in function() return string.find(str, delimiter, pos, true) end do
        table.insert(arr, string.sub(str, pos, st - 1))
        pos = sp + 1
    end
    table.insert(arr, string.sub(str, pos))
    return arr
end

function string.ltrim(str)
    return string.gsub(str, "^[ \t\n\r]+", "")
end

function string.rtrim(str)
    return string.gsub(str, "[ \t\n\r]+$", "")
end

function string.trim(str)
    str = string.gsub(str, "^[ \t\n\r]+", "")
    return string.gsub(str, "[ \t\n\r]+$", "")
end

function string.ucfirst(str)
    return string.upper(string.sub(str, 1, 1)) .. string.sub(str, 2)
end

local function urlencodeChar(char)
    return "%" .. string.format("%02X", string.byte(c))
end

function string.urlencode(str)
    -- convert line endings
    str = string.gsub(tostring(str), "\n", "\r\n")
    -- escape all characters but alphanumeric, '.' and '-'
    str = string.gsub(str, "([^%w%.%- ])", urlencodeChar)
    -- convert spaces to "+" symbols
    return string.gsub(str, " ", "+")
end

function string.urldecode(str)
    str = string.gsub (str, "+", " ")
    str = string.gsub (str, "%%(%x%x)", function(h) return string.char(tonum(h,16)) end)
    str = string.gsub (str, "\r\n", "\n")
    return str
end

function string.utf8len(str)
    local len  = #str
    local left = len
    local cnt  = 0
    local arr  = {0, 0xc0, 0xe0, 0xf0, 0xf8, 0xfc}
    while left ~= 0 do
        local tmp = string.byte(str, -left)
        local i   = #arr
        while arr[i] do
            if tmp >= arr[i] then
                left = left - i
                break
            end
            i = i - 1
        end
        cnt = cnt + 1
    end
    return cnt
end

function string.utf8sub(str, start, last)
	if start > last then
		return ""
	end
    local len  = #str
    local left = len
    local cnt  = 0
	local startByte = len + 1
    local arr  = {0, 0xc0, 0xe0, 0xf0, 0xf8, 0xfc}
    while left ~= 0 do
        local tmp = string.byte(str, -left)
        local i   = #arr
        while arr[i] do
            if tmp >= arr[i] then
                left = left - i
                break
            end
            i = i - 1
        end
        cnt = cnt + 1
		if cnt == start then
			startByte = len - (left + i) + 1
		end
		if cnt == last then
			return string.sub(str, startByte, len - left)
		end
    end
	return string.sub(str, startByte, len)
end

function string.formatNumberThousands(num)
    local formatted = tostring(tonum(num))
    local k
    while true do
        formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
        if k == 0 then break end
    end
    return formatted
end


--[[
    从字符串创建表
]]
function table.fromString(str)
    local func = load(str)
    assert(func, string.format("chunk is invalid:%s", str))
    return func()
end

--[[
    配置文件代理对象
]]
local __confnext = function(t, k)
    local nextk, v = next(t, k)
    if v then
        return nextk, table.fromString(v)
    end
    return nextk
end
proxyConfig = proxyConfig
if not proxyConfig then
	proxyConfig = function(origin)
		local new = setmetatable({}, {
		__index = function(t, k)
					if not k then
						return
					end
				local data = origin[k]
					if not data then
						return
					end
				return table.fromString(data)
		end,
      __len = function(t)
        return #origin
      end,
		__pairs = function(t)
			return __confnext, origin, nil
		end
		})
		return new
	end
end

--[[
    压测模式下id转换函数
    @param roleId 当前玩家角色ID
    @param id 自增ID 范围 1 ~ 2 ^ 12 - 1
    @results 返回最终的实际的ID
]]
local __MAX_ID = 2 ^ 12 - 1
function covertToTestModeId(roleId, id)
    local id = (roleId << 12) + (id & __MAX_ID)
    return id
end

-- 树形打印一个table
function tableToString(root)
    if root == nil then
        return "nil"
    end
    local cache = {  [root] = "." }
    local function _dump(t,space,name)
        local temp = {}
        for k,v in pairs(t) do
            local key = tostring(k)
            if cache[v] then
                table.insert(temp,"+" .. key .. " {" .. cache[v].."}")
            elseif type(v) == "table" then
                local new_key = name .. "." .. key
                cache[v] = new_key
                table.insert(temp,"+" .. key .. _dump(v,space .. (next(t,k) and "|" or " " ).. string.rep(" ",#key),new_key))
            else
                table.insert(temp,"+" .. key .. " [" .. tostring(v).."]")
            end
        end
        return table.concat(temp,"\n"..space)
    end
    return (_dump(root, "",""))
end


local function dump_value_(v)
    if type(v) == "string" then
        v = "\"" .. v .. "\""
    end
    return tostring(v)
end

function dump(value, desciption, nesting, notPrint)
    if type(nesting) ~= "number" then nesting = 5 end

    local lookupTable = {}
    local result = {}

    local traceback = string.split(debug.traceback("", 2), "\n")
    if not notPrint then 
        print("dump from: " .. string.trim(traceback[3]))
    end

    local function dump_(value, desciption, indent, nest, keylen)
        desciption = desciption or "<var>"
        local spc = ""
        if type(keylen) == "number" then
            spc = string.rep(" ", keylen - string.len(dump_value_(desciption)))
        end
        if type(value) ~= "table" then
            result[#result +1 ] = string.format("%s%s%s = %s", indent, dump_value_(desciption), spc, dump_value_(value))
        elseif lookupTable[tostring(value)] then
            result[#result +1 ] = string.format("%s%s%s = *REF*", indent, dump_value_(desciption), spc)
        else
            lookupTable[tostring(value)] = true
            if nest > nesting then
                result[#result +1 ] = string.format("%s%s = *MAX NESTING*", indent, dump_value_(desciption))
            else
                result[#result +1 ] = string.format("%s%s = {", indent, dump_value_(desciption))
                local indent2 = indent.."    "
                local keys = {}
                local keylen = 0
                local values = {}
                for k, v in pairs(value) do
                    keys[#keys + 1] = k
                    local vk = dump_value_(k)
                    local vkl = string.len(vk)
                    if vkl > keylen then keylen = vkl end
                    values[k] = v
                end
                table.sort(keys, function(a, b)
                    if type(a) == "number" and type(b) == "number" then
                        return a < b
                    else
                        return tostring(a) < tostring(b)
                    end
                end)
                for i, k in ipairs(keys) do
                    dump_(values[k], k, indent2, nest + 1, keylen)
                end
                result[#result +1] = string.format("%s}", indent)
            end
        end
    end
    dump_(value, desciption, "- ", 1)

    local str = ""
    for i, line in ipairs(result) do
        if not notPrint then 
            print(line)
        end
        str = str..(line or "").."\n"
    end
    return str
end

function dumpString(value, desciption, nesting)
    return dump(value, desciption, nesting, true)
end

function debugInfo(...)
    -- local DEBUG = true
    if DEBUG then
        print(...)
    end
end


-- 获取一个月的总天数 参数可选 指定某月的天数
function getMonWithAllDay(Mon)
    Mon = (Mon and tostring(Mon)) or os.date("%m")
    return os.date("%d",
        os.time({
            year = os.date("%Y"),
            month = Mon + 1,
            day=0}))
end

--[[
    计算两点连线与X轴正向夹角弧度
    @param  originPoint 连线出发点
    @param  targetPoint 目标点
]]
function angleBetweenPoints(originX, originY, targetX, targetY)
    return math.atan2(targetY - originY, targetX - originX)
end