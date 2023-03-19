local modPath = '/mods/SupremeScoreBoard2/'
local modScripts  = modPath..'modules/'
local str  = import(modScripts..'ext.strings.lua')
local log  = import(modScripts..'ext.logging.lua')
local UIUtil = import('/lua/ui/uiutil.lua')

CurrentEvents = {}
function UpdateEvents(newEvents)
    CurrentEvents = newEvents
end