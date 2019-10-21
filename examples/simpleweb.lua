local skynet = require "skynet"
local socket = require "skynet.socket"
local httpd = require "http.httpd"
local sockethelper = require "http.sockethelper"
local urllib = require "http.url"
local http_ctrl = require "http.http_ctrl"
local cjson = require "cjson"
local cjson2 = cjson.new()
cjson2.encode_sparse_array(true)
require "functions"
require "errorCode"

local table = table
local string = string


local json = require("json")

local mode, protocol = ...
protocol = protocol or "http"

if mode == "agent" then

local function response(id, ...)
	local ok, err = httpd.write_response(sockethelper.writefunc(id), ...)
	if not ok then
		-- if err == sockethelper.socket_error , that means socket closed.
		skynet.error(string.format("fd = %d, %s", id, err))
	end
end


local SSLCTX_SERVER = nil
local function gen_interface(protocol, fd)
	if protocol == "http" then
		return {
			init = nil,
			close = nil,
			read = sockethelper.readfunc(fd),
			write = sockethelper.writefunc(fd),
		}
	elseif protocol == "https" then
		local tls = require "http.tlshelper"
		if not SSLCTX_SERVER then
			SSLCTX_SERVER = tls.newctx()
			-- gen cert and key
			-- openssl req -x509 -newkey rsa:2048 -days 3650 -nodes -keyout server-key.pem -out server-cert.pem
			local certfile = skynet.getenv("certfile") or "./server-cert.pem"
			local keyfile = skynet.getenv("keyfile") or "./server-key.pem"
			print(certfile, keyfile)
			SSLCTX_SERVER:set_cert(certfile, keyfile)
		end
		local tls_ctx = tls.newtls("server", SSLCTX_SERVER)
		return {
			init = tls.init_responsefunc(fd, tls_ctx),
			close = tls.closefunc(tls_ctx),
			read = tls.readfunc(fd, tls_ctx),
			write = tls.writefunc(fd, tls_ctx),
		}
	else
		error(string.format("Invalid protocol: %s", protocol))
	end
end

local function checkParams(requestParams)
	if requestParams['secretKey'] ~= nil then
		-- if requestParams['secretKey'] ~= secretKey then
		-- 	return 3
		-- end
	else
		-- return 2
	end
	if requestParams['serverId'] == nil then
		-- return 4
	end
	if requestParams['module'] == nil then
		return 5
	end
	if requestParams['method'] == nil then
		return 6
	end
	return 0
end

skynet.start(function()
	skynet.dispatch("lua", function (_,_,id)
		socket.start(id)
		-- local interface = gen_interface(protocol, id)
		-- if interface.init then
		-- 	interface.init()
		-- end
		-- limit request body size to 8192 (you can pass nil to unlimit)
		local code, url, method, header, body = httpd.read_request(sockethelper.readfunc(id), 8192)
		if code then
			if code ~= 200 then
				response(id, code)
			else
				local tmp = {}
				-- if header.host then
				-- 	table.insert(tmp, string.format("host: %s", header.host))
				-- end
				-- local path, query = urllib.parse(url)
				-- if body then
				-- 	local b = urllib.parse_query(body)
				-- 	for k, v in pairs(b) do
				-- 		table.insert(tmp, string.format("body-query: %s= %s", k,v))
				-- 	end
				-- end
				-- table.insert(tmp, string.format("path: %s", path))
				-- if query then
				-- 	local q = urllib.parse_query(query)
				-- 	for k, v in pairs(q) do
				-- 		table.insert(tmp, string.format("query: %s= %s", k,v))
				-- 	end
				-- end
				-- table.insert(tmp, "-----header----")
				-- for k,v in pairs(header) do
				-- 	table.insert(tmp, string.format("%s = %s",k,v))
				-- end
				-- table.insert(tmp, "-----body----\n" .. body)
				local requestParams = urllib.parse_query(body)
				if method ~= 'POST' then
					tmp.data = {}
					tmp.errorCode = 1
					response(id, 200, cjson2.encode(tmp))
				else
					if checkParams(requestParams) ~= 0 then
						tmp.data = {}
						tmp.errorCode = 2
						response(id, 200, cjson2.encode(tmp))
					else
						local module = requestParams.module
						local method = requestParams.method
						local params = cjson2.decode(requestParams.param)
						dump(params[1])
						dump(params[2])
						local ec, result = http_ctrl.doCmd(module, method, 
							params[1],
							params[2],
							params[3],
							params[4],
							params[5],
							params[6],
							params[7],
							params[8],
							params[9],
							params[10]
						)
						local jsonData = {
							errorCode = ec,
							data = result
						}
						response(id, 200, cjson2.encode(jsonData))
					end
				end
			end
		else
			if url == sockethelper.socket_error then
				skynet.error("socket closed")
			else
				skynet.error(url)
			end
		end
		socket.close(id)
		skynet.error("socket closed: ", id)
		-- if interface.close then
		-- 	interface.close()
		-- end
	end)
end)

else

skynet.start(function()
	local agent = {}
	local protocol = "http"
	for i= 1, 20 do
		agent[i] = skynet.newservice(SERVICE_NAME, "agent", protocol)
	end
	local balance = 1
	local id = socket.listen("0.0.0.0", 8001)
	skynet.error(string.format("Listen web port 8001 protocol:%s", protocol))
	socket.start(id , function(id, addr)
		skynet.error(string.format("%s connected, pass it to agent :%08x", addr, agent[balance]))
		skynet.send(agent[balance], "lua", id)
		balance = balance + 1
		if balance > #agent then
			balance = 1
		end
	end)
end)

end