package.path = package.path .. ";../?.lua"
luaunit = require('luaunit')
modScripts = ''

function GetVersion()
    return 3756
end

local OtherArmyResultStrings = {
    --TODO add localization tags and update strings when integrating with FAF
    victory  =   ' has won this game! ',      -- <LOC usersync_0001>
    defeat   =    'has been defeated by',    -- <LOC usersync_0002>
    draw     = '   has drawn with   ',          -- <LOC usersync_0003>
    gameOver = 'Game Over.',              -- <LOC usersync_0004>
}

local MyArmyResultStrings = {
    --TODO add localization tags and update strings when integrating with FAF
    victory =    " You have won this game! ",    -- <LOC GAMERESULT_0000>
    defeat  =     "You have been defeated by",  -- <LOC GAMERESULT_0001>
    draw    = "    You have draw with   ",         -- <LOC GAMERESULT_0002>
    replay  = "Replay Finished.",           -- <LOC GAMERESULT_0003>
}

gameresult = require('../modules/gameresultnew')

--mock function
function AnnounceDraw(armyID, message, killerId)
    luaunit.assert_equals(1, armyID)
end

--mock function
function GetFocusArmy()
    return 1
end

--mock function
function LOC(string)
    return string
end


local ResultStrings = {}
ResultStrings.OtherArmy = OtherArmyResultStrings
ResultStrings.MyArmy = MyArmyResultStrings

local Announces = {}
Announces.AnnounceDeath        = AnnounceDeath
Announces.AnnounceDeathUnknown = AnnounceDeathUnknown
Announces.AnnounceDraw         = AnnounceDraw
Announces.AnnounceVictory      = AnnounceVictory


-- prepare sync

local events = { }
local acuDestroyed = { }
events.ACUDestroyed = acuDestroyed

-- sync the event
table.insert(acuDestroyed, {
    Timestamp = 123,
    InstigatorArmy = 2,
    KilledArmy = 1
})
table.insert(acuDestroyed, {
    Timestamp = 234,
    InstigatorArmy = 3,
    KilledArmy = 2
})
table.insert(acuDestroyed, {
    Timestamp = 234,
    InstigatorArmy = 10,
    KilledArmy = 11
})
table.insert(acuDestroyed, {
    Timestamp = 234,
    InstigatorArmy = 11,
    KilledArmy = 10
})




-- Test is run here
-- first assert function

function testCheckIfVictoryExits()
    local AnnounceDeathCalled = false
    local AnnounceDrawCalled = false
    function AnnounceDeath(armyID, message, killerId)
        AnnounceDeathCalled = true
    end
    function AnnounceDraw(armyID, message, killerId)
        AnnounceDrawCalled = true
    end

    DoGameResultNew(1, 'victory', events, ResultStrings, Announces)
    luaunit.assert_false(AnnounceDeathCalled)
    luaunit.assert_false(AnnounceDrawCalled)
    
end


function testCheckDefeat()
    local AnnounceDeathCalled = false
    function AnnounceDeath(armyID, message, killerId)
        AnnounceDeathCalled = true
        luaunit.assert_equals(1, armyID)
        luaunit.assert_equals(2, killerId)
    end
    Announces.AnnounceDeath = AnnounceDeath

    DoGameResultNew(1, 'defeat', events, ResultStrings, Announces)

    luaunit.assert_true(AnnounceDeathCalled)
end

function testCheckDefeat2()
    local AnnounceDeathCalled = false
    function AnnounceDeath(armyID, message, killerId)
        AnnounceDeathCalled = true
        luaunit.assert_equals(2, armyID)
        luaunit.assert_equals(3, killerId)
    end
    Announces.AnnounceDeath = AnnounceDeath

    DoGameResultNew(2, 'defeat', events, ResultStrings, Announces)

    luaunit.assert_true(AnnounceDeathCalled)
end

function testCheckDraw()
    -- reset this
    Resetdrawnotified()
    local AnnounceDeathCalled = false
    local AnnounceDrawCalled = false
    function AnnounceDeath(armyID, message, killerId)
        AnnounceDeathCalled = true
    end
    Announces.AnnounceDeath = AnnounceDeath
    function AnnounceDraw(armyID, message, killerId)
        AnnounceDrawCalled = true
    end
    Announces.AnnounceDraw = AnnounceDraw

    DoGameResultNew(10, 'defeat', events, ResultStrings, Announces)

    luaunit.assert_false(AnnounceDeathCalled)
    luaunit.assert_true(AnnounceDrawCalled) 
end

function testCheckDrawOnlyOnce()
    -- reset this
    Resetdrawnotified()
    local AnnounceDeathCalled = false
    local AnnounceDrawCalled = false
    function AnnounceDeath(armyID, message, killerId)
        AnnounceDeathCalled = true
    end
    Announces.AnnounceDeath = AnnounceDeath
    function AnnounceDraw(armyID, message, killerId)
        AnnounceDrawCalled = true
    end
    Announces.AnnounceDraw = AnnounceDraw
    
    DoGameResultNew(10, 'defeat', events, ResultStrings, Announces)

    luaunit.assert_false(AnnounceDeathCalled)
    luaunit.assert_true(AnnounceDrawCalled)

    AnnounceDrawCalled = false

    DoGameResultNew(11, 'defeat', events, ResultStrings, Announces)
    luaunit.assert_false(AnnounceDeathCalled)
    luaunit.assert_false(AnnounceDrawCalled)
end



function testCheckNoKillSyncedThereforeSuicide()
    -- reset these
    acuDestroyed = {} 
    events.ACUDestroyed = acuDestroyed
    Resetdrawnotified()
    local AnnounceDeathCalled = false
    local AnnounceDrawCalled = false
    function AnnounceDeath(armyID, message, killerId)
        AnnounceDeathCalled = true
        luaunit.assert_equals(armyID, killerId)
        luaunit.assertEquals(' killed by suicide ', message)
    end
    Announces.AnnounceDeath = AnnounceDeath
    function AnnounceDraw(armyID, message, killerId)
        AnnounceDrawCalled = true
    end
    Announces.AnnounceDraw = AnnounceDraw

    DoGameResultNew(1, 'defeat', events, ResultStrings, Announces)


    luaunit.assert_true(AnnounceDeathCalled)
    luaunit.assert_false(AnnounceDrawCalled)

end









os.exit( luaunit.LuaUnit.run() )