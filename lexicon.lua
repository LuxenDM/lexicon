--[[
[modreg]
API=3
id=lexicon
version=1.0.0
name=Lexicon Translation Library
author=Luxen
website=<tbd>
path=lexicon.lua

[metadata]
description=Core file for Lexicon
owner=lexicon|1.0.0
type=lua
created=2026-4-10
]]--

local re_path = lib.get_path() or "plugins/Lexicon/"
local re_ver = lib.plugin_read_str(re_path .. "lexicon.lua", nil, "modreg", "version")
local re_standalone = (re_path == "plugins/Lexicon/") and "YES" or "NO"

local cp = function(msg, v)
	lib.log_error("[lexicon] " .. tostring(msg), v or 1, "resound", re_ver)
end

cp("Resound " .. re_ver .. " is operating out of " .. re_path)



local config, public, private

config = {
	precache = "NO",
}

public = {
	CCD1 = true,
	commands = {},
	manifest = {
		"main.lua",
		"lexicon.lua",
		
		"assets/",
		"lang/",
		"modules/",
		"tools/",
	},
	get_config_list = function()
		local ret = {}
		for id in pairs(config) do
			table.insert(ret, id)
		end
		return ret
	end,
	get_config = function(cfg)
		return config[cfg]
	end,
	set_config = function(cfg, val)
		if config[cfg] then
			config[cfg] = tostring(val)
		end
	end,
	save_config = function()
		for k, v in pairs(config) do
			gkini.WriteString("Lexicon", k, v)
		end
	end,
	load_config = function()
		for k, v in pairs(config) do
			config[k] = gkini.ReadString("Lexicon", k, v)
		end
	end,
}

public.load_config()

private = {
	path = re_path,
	version = re_ver,
	standalone = re_standalone,
	cp = cp,
	
	load_module = function(file_path)
		local valid_file_path = lib.find_file(private.path .. "modules/" .. file_path)
		if valid_file_path then
			cp("executing module " .. valid_file_path)
			
			local file_f, err = loadfile(valid_file_path)
			
			if file_f then
				file_f(public, private, config)
			else
				error("failed to load required module " .. file_path .. ": " .. err)
			end
		else
			error("failed to find required module " .. file_path)
		end
	end,
	
	lstr = function(index, default_str)
		return default_str
	end,
}

private.update_class = function()
	local class = {
		description = private.lstr(1, "Lexicon is a dictionary-style translation library. "),
	}
	
	class.smart_config = {
		title = private.lstr(2, "Lexicon"),
		cb = function(id, val)
			if config[id] then
				config[id] = val
				gkini.WriteString("Lexicon", id, val)
			end
		end,
		spacer = {
			type = "spacer",
		},
	}
	
	for k, v in pairs(class) do
		public[k] = v
	end
	
	lib.set_class("lexicon", private.version, public)
end

private.load_module("registry.lua")
private.load_module("interface.lua")

update_class()