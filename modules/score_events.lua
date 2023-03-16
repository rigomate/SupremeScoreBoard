local modPath = '/mods/SupremeScoreBoard/'
local modScripts  = modPath..'modules/'
local str  = import(modScripts..'ext.strings.lua')
local log  = import(modScripts..'ext.logging.lua')
local UIUtil = import('/lua/ui/uiutil.lua')

CurrentEvents = {}
function UpdateEvents(newEvents)
    log.Trace('updating')
    CurrentEvents = newEvents
    log.Trace(CurrentEvents.ACUDestroyed[1].KilledArmy)
    log.Trace(CurrentEvents.ACUDestroyed[1].InstigatorArmy)
end