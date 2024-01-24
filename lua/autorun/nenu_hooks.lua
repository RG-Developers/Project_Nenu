AddCSLuaFile()

if not _print then
	_print = print
end

local realm = "client"
if SERVER then
	realm = "server"
end

function print(...)
	RunConsoleCommand("__transfer_to_menu_please_god_dont_use_this_command_i_beg_you", "runhook", "Print", realm, ...)
	_print(...)
end