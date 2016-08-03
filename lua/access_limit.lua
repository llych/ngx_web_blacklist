ngx.req.read_body()
local IP = ngx.req.get_headers()["X-Real-IP"]
if IP == nil then
	IP = ngx.req.get_headers()["x_forwarded_for"]
end
if IP == nil then
	IP = ngx.var.remote_addr
end
local shared_blacklist_ip = ngx.shared.shared_blacklist_ip

local  ip,value = shared_blacklist_ip:get(IP)
if ip ~= nil then
	-- ngx.say(IP)
	ngx.exit(ngx.HTTP_FORBIDDEN)
end