local function init_menu()

	animationSpeed = 1

	makeMenuButton = include("./menu/utils/button.lua")
	makePopup = include("./menu/utils/popup.lua")

	concommand.Add("__transfer_to_menu_please_god_dont_use_this_command_i_beg_you", function(_, cmd, args)
		if args[1] == "runhook" then
			hook.Run(args[2], unpack(args, 3))
		end
	end)

	if not _print then
		_print = print
	end
	function print(...)
		hook.Run("Print", "menu", ...)
		_print(...)
	end

	function log(f, str)
		if not file.Exists("project_nenu/logs/"..f..".txt", "DATA") then
			file.CreateDir("project_nenu/logs")
			file.Write("project_nenu/logs/"..f..".txt", "Project Nenu \""..f.."\" log file\n\n")
		end
		file.Append("project_nenu/logs/"..f..".txt", str.."\n")
	end

	concommand.Add("lua_run_menu", function(_, _, _, code)
		MsgC(Color(255, 255, 255), ">"..code.."\n")
		local _ = CompileString(code, "<string>")
		if _ then _() end
	end)

	function table.shallow_copy(t)
	  local t2 = {}
	  for k,v in pairs(t) do
	    t2[k] = v
	  end
	  return t2
	end

	function GetAddons()
		local addons = engine.GetAddons()
		local jainf = file.Read("project_nenu/info/addonsinfo.json", "DATA")
		local ainfo = util.JSONToTable(jainf)
		local return_addons = {}
		for lid=1,#addons,1 do
			local addon = table.shallow_copy(addons[lid])
			local ainf = ainfo[tonumber(addon.wsid)]
			if ainf == nil or ainf == {} then
				ainf = {}
				ainf.enabled = false
			end
			addon.enabled = ainf.enabled
			addon.lid = lid
			return_addons[lid] = addon
		end
		return return_addons
	end
	function SaveAddonsStatuses(addons)
		local jainf = {}
		for _,a in pairs(addons) do
			if a.enabled == nil then a.enabled = false end
			jainf[a.wsid] = {}
			jainf[a.wsid].enabled = a.enabled
		end
		if not file.Exists("project_nenu", "DATA") or not file.Exists("project_nenu/info", "DATA") then
			file.CreateDir("project_nenu/info")
		end
		file.Write("project_nenu/info/addonsinfo.json", util.TableToJSON(jainf))
	end

	function GetFavServers()
		local fsinf = file.Read("project_nenu/info/favservers.json", "DATA")
		local fsinfo = util.JSONToTable(fsinf)
		return fsinfo
	end
	function SaveFavServers(fservers)
		if not file.Exists("project_nenu", "DATA") or not file.Exists("project_nenu/info", "DATA") then
			file.CreateDir("project_nenu/info")
		end
		file.Write("project_nenu/info/favservers.json", util.TableToJSON(fservers))
	end

	if not file.Exists("project_nenu/info/addonsinfo.json", "DATA") or not file.Exists("project_nenu", "DATA") or not file.Exists("project_nenu/info", "DATA") then
		file.CreateDir("project_nenu/info")
		file.Write("project_nenu/info/addonsinfo.json", "{}")
	end

	if not file.Exists("project_nenu/info/favservers.json", "DATA") or not file.Exists("project_nenu", "DATA") or not file.Exists("project_nenu/info", "DATA") then
		file.CreateDir("project_nenu/info")
		file.Write("project_nenu/info/favservers.json", "{}")
	end

	include("./menu/errors.lua")
	include("./menu/loading.lua")
	include("./menu/mainmenu.lua")
	include("./menu/workshop.lua")

	print("+------------------+")
	print("|   PROJECT NENU   |")
	print("|      v 1.0       |")
	print("|     BY RG DEV    |")
	print("+------------------+")
end

local function reloadmenu()
	concommand.Remove("lua_run_menu")
	if pnlStartGameMenu then pnlStartGameMenu = nil end
	if pnlConnectMenu then pnlConnectMenu = nil end
	if pnlAddonsMenu then pnlAddonsMenu = nil end
	if pnlMainMenu then pnlMainMenu:Remove() pnlMainMenu = nil end
	if GetLoadingPanel() then GetLoadingPanel():Remove() end
	animationSpeed = nil
	makeMenuButton = nil
	makePopup = nil
	GetAddons = nil
	SaveAddonsStatuses = nil
	table.shallow_copy = nil
	GetFavServers = nil
	SaveFavServers = nil
	log = nil

	init_menu()
end

concommand.Add("reload_menu", reloadmenu)

surface.CreateFont("DermaMedium", {
	font = "Roboto",
	size = 24,
	weight = 500
})

init_menu()