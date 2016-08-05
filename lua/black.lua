local methods = {
}

local template = require("resty.template")
local uri_args = ngx.req.get_uri_args()
local shared_ip = ngx.shared.shared_ip
local shared_blacklist_ip = ngx.shared.shared_blacklist_ip
local shared_ip = ngx.shared.shared_ip

function methods.GET()
	-- body
	if uri_args.blacklist then
		template.render("black.html",{uri=ngx.var.uri,postUri="?blacklist"})
	elseif uri_args.put then
		local keys = shared_ip:get_keys()
		for index, key in pairs(keys) do
			local addr,ttl = shared_ip:get(key)
			if ttl == nil then
				ttl = 0
			end
			ttl = tonumber(ttl)

			shared_blacklist_ip:add(key,addr,ttl,ttl)
		end
		ngx.say("成功")
	else
		

		template.render("black.html",{uri=ngx.var.uri}) 
	end
	

end


function methods.POST()
	-- body
	
	ngx.req.read_body()
	local post_args = ngx.req.get_post_args()
	if uri_args.blacklist then
		if (post_args.start) then
		local json = require("cjson")
		local response = {}
		local keys = shared_blacklist_ip:get_keys()
		-- ngx.say(keys)
		for index, key in pairs(keys) do
			local addr,ttl = shared_blacklist_ip:get(key)
			if ttl == nil then
				ttl = 0
			end
			response[index] = {ip=key,addr=addr,time=ttl}
		end
			ngx.say(json.encode(response))
	elseif (post_args.saveType == "add") then
		local success, err, forcible = shared_blacklist_ip:add(tostring(post_args.ip),tostring(post_args.addr),tonumber(post_args.time),tonumber(post_args.time))
		-- local success, err, forcible = shared_ip:set("a","0",1000)
		ngx.say("{\"ip\":\""..post_args.ip.."\"}")
		-- ngx.say("{\"ip\":\"127.0.x\"}")
	elseif (post_args.saveType == "remove") then
		for k,v in string.gmatch(post_args.ips, "(%S+),?") do
			-- ngx.say(k)
			shared_blacklist_ip:delete(k)
		end
		ngx.say("{\"hasError\" : false}")
	elseif (post_args.saveType == "update") then
		shared_blacklist_ip:replace(tostring(post_args.ip),tostring(post_args.addr),tonumber(post_args.time),tonumber(post_args.time))
		ngx.say("{\"hasError\" : false}")
	end


	else
		if (post_args.start) then
			local json = require("cjson")
			local response = {}
			local keys = shared_ip:get_keys()
			-- ngx.say(keys)
			for index, key in pairs(keys) do
				local addr,ttl = shared_ip:get(key)
				if ttl == nil then
					ttl = 0
				end

				response[index] = {ip=key,addr=addr,time=ttl}
				-- ngx.say(key)
				-- ngx.say(index)
			end
			ngx.say(json.encode(response))
		elseif (post_args.saveType == "add") then
			local success, err, forcible = shared_ip:add(tostring(post_args.ip),tostring(post_args.addr),tonumber(post_args.time),tonumber(post_args.time))
			-- local success, err, forcible = shared_ip:set("a","0",1000)
			ngx.say("{\"ip\":\""..post_args.ip.."\"}")
			-- ngx.say("{\"ip\":\"127.0.x\"}")
		elseif (post_args.saveType == "remove") then
			for k,v in string.gmatch(post_args.ips, "(%S+),?") do
				-- ngx.say(k)
				shared_ip:delete(k)
			end
			ngx.say("{\"hasError\" : false}")
		elseif (post_args.saveType == "update") then
			shared_ip:replace(tostring(post_args.ip),tostring(post_args.addr),tonumber(post_args.time),tonumber(post_args.time))
			ngx.say("{\"hasError\" : false}")
		end
	end
end



local method = ngx.req.get_method()

methods[method]()
