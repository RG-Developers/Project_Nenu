print("+------------------+")
print("|   PROJECT NENU   |")
print("|      v 1.0       |")
print("|     BY RG DEV    |")
print("+------------------+")

animationSpeed = 1

makeMenuButton = include("utils/button.lua")
makePopup = include("utils/popup.lua")

concommand.Add("lua_run_menu", function(_, _, _, code)
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

include("errors.lua")
include("loading.lua")
include("mainmenu.lua")
include("workshop.lua")
