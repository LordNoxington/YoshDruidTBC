local Tinkr = ...
local wowex = {}
local Routine = Tinkr.Routine
local Util = Tinkr.Util
local Draw = Tinkr.Util.Draw:New()
local OM = Tinkr.Util.ObjectManager
local lastdebugmsg = ""
local lastdebugtime = 0
_G.DruidSpellQueue = {}
Tinkr:require('scripts.cromulon.libs.Libdraw.Libs.LibStub.LibStub', wowex) --! If you are loading from disk your rotaiton. 
Tinkr:require('scripts.cromulon.libs.Libdraw.LibDraw', wowex) 
Tinkr:require('scripts.cromulon.libs.AceGUI30.AceGUI30', wowex)
Tinkr:require('scripts.wowex.libs.AceAddon30.AceAddon30' , wowex)
Tinkr:require('scripts.wowex.libs.AceConsole30.AceConsole30' , wowex)
Tinkr:require('scripts.wowex.libs.AceDB30.AceDB30' , wowex)
Tinkr:require('scripts.cromulon.system.init' , wowex)
Tinkr:require('scripts.cromulon.system.configs' , wowex)
Tinkr:require('scripts.cromulon.system.storage' , wowex)
Tinkr:require('scripts.cromulon.libs.libCh0tFqRg.libCh0tFqRg' , wowex)
Tinkr:require('scripts.cromulon.libs.libNekSv2Ip.libNekSv2Ip' , wowex)
Tinkr:require('scripts.cromulon.libs.CallbackHandler10.CallbackHandler10' , wowex)
Tinkr:require('scripts.cromulon.libs.HereBeDragons.HereBeDragons-20' , wowex)
Tinkr:require('scripts.cromulon.libs.HereBeDragons.HereBeDragons-pins-20' , wowex)
Tinkr:require('scripts.cromulon.interface.uibuilder' , wowex)
Tinkr:require('scripts.cromulon.interface.buttons' , wowex)
Tinkr:require('scripts.cromulon.interface.panels' , wowex)
Tinkr:require('scripts.cromulon.interface.minimap' , wowex)


function distanceto(object)
  local X1, Y1, Z1 = ObjectPosition('player')
  local X2, Y2, Z2 = ObjectPosition(object)
  if X1 and Y1 and X2 and Y2 and Z1 and Z2 then
    return math.sqrt(((X2 - X1) ^ 2) + ((Y2 - Y1) ^ 2) + ((Z2 - Z1) ^ 2))
  end
end

function round(num, numDecimalPlaces)
  return tonumber(string.format("%." .. (numDecimalPlaces or 0) .. "f", num))
end

function UnitTargetingUnit(unit1,unit2)
  if UnitIsVisible(UnitTarget(unit1)) and UnitIsVisible(unit2) then
    if UnitGUID(UnitTarget(unit1)) == UnitGUID(unit2) then
      return true
    end
  end
end

Draw:Sync(function(draw)
  px, py, pz = ObjectPosition("player")
  tx, ty, tz = ObjectPosition("target")
  local playerHeight = ObjectHeight("player")
  local playerRadius = ObjectBoundingRadius("player")
  local targetRadius = ObjectBoundingRadius("target")
  local targetReach = ObjectCombatReach("target")
  local combatReach = ObjectCombatReach("player")
  local drawclass = UnitClass("target") 
  --draw:SetColor(draw.colors.white)
  --draw:Circle(px, py, pz, playerRadius)
  --draw:Circle(px, py, pz, combatReach)

  local rotation = ObjectRotation("player")
  --local rx, ry, rz = RotateVector(px, py, pz, rotation, playerRadius);

  --draw:Line(px, py, pz, rx, ry, rz)

  if UnitExists("target") and UnitCanAttack("player","target") and not UnitIsDeadOrGhost("target") then
    local targetrotation = ObjectRotation("target")
    local fx, fy, fz = RotateVector(tx, ty, tz, (targetrotation+math.pi), 2)
    local xx, xy, xz = RotateVector(tx, ty, tz, (targetrotation+math.pi/2), 1)
    local vx, vy, vz = RotateVector(tx, ty, tz, (targetrotation-math.pi/2), 1)
    draw:SetColor(draw.colors.blue)
    draw:Line(tx, ty, tz, xx, xy, xz)
    draw:Line(tx, ty, tz, vx, vy, vz)
    draw:SetColor(draw.colors.yellow)
    draw:Line(tx, ty, tz, fx, fy, fz)
  end

  if UnitExists("target") and drawclass == "Warrior" and UnitCanAttack("player","target") and not UnitIsDeadOrGhost("target") then
    draw:Circle(tx, ty, tz, 5)
    draw:SetColor(draw.colors.red)
    draw:Circle(tx, ty, tz, 8)
  end

  for object in OM:Objects(OM.Types.Player) do
    if UnitCanAttack("player",object) then
      if UnitTargetingUnit(object,"player") then
        ObjectTargetingMe = Object(object)
        local ix, iy, iz = ObjectPosition(object)
        if distanceto(object) <= 8 then
          draw:SetColor(0,255,0)
        end
        if distanceto(object) >= 8 and distanceto(object) <= 30 then
          draw:SetColor(199,206,0)            
        end
        if distanceto(object) >= 30 then
          draw:SetColor(255,0,0)
        end 
        draw:Line(px,py,pz,ix,iy,iz,4,55)  
      end
    end
  --end

  --for object in OM:Objects(OM.Types.Player) do
    if UnitCanAttack("player",object) then
    local tx, ty, tz = ObjectPosition(object)
    local dist = distanceto(object)
    local health = UnitHealth(object)
    local class = UnitClass(object)
    if distanceto(object) <= 8 then
      draw:SetColor(0,255,0)
    end
    if distanceto(object) >= 8 and distanceto(object) <= 30 then
      draw:SetColor(199,206,0)            
    end
    if distanceto(object) >= 30 then
      draw:SetColor(255,0,0)
    end  

    Draw:Text(round(dist).."y".." ","GameFontNormalSmall", tx, ty+2, tz+3)
    if UnitHealth(object) >= 70 then
      draw:SetColor(0,255,0)
    end
    if UnitHealth(object) >= 30 and UnitHealth(object) <= 70 then
      draw:SetColor(199,206,0)
    end
    if UnitHealth(object) <= 30 then
      draw:SetColor(255,0,0)
    end

    Draw:Text(health.."%","GameFontNormalSmall", tx, ty+2, tz+2)
      if UnitClass(object) == "Warrior" then
        Draw:SetColor(198,155,109)
        Draw:Text(class,"GameFontNormalSmall", tx, ty+2, tz+1)
      elseif UnitClass(object) == "Warlock" then
        Draw:SetColor(135,136,238)
        Draw:Text(class,"GameFontNormalSmall", tx, ty+2, tz+1)
      elseif UnitClass(object) == "Shaman" then
        Draw:SetColor(0,112,221 )
        Draw:Text(class,"GameFontNormalSmall", tx, ty+2, tz+1)
      elseif UnitClass(object) == "Priest" then
        Draw:SetColor(255,255,255)
        Draw:Text(class,"GameFontNormalSmall", tx, ty+2, tz+1)
      elseif UnitClass(object) == "Mage" then
        Draw:SetColor(63,199,235)
        Draw:Text(class,"GameFontNormalSmall", tx, ty+2, tz+1)
      elseif UnitClass(object) == "Hunter" then
        Draw:SetColor(170,211,114)
        Draw:Text(class,"GameFontNormalSmall", tx, ty+2, tz+1)
      elseif UnitClass(object) == "Paladin" then
        Draw:SetColor(244,140,186 )
        Draw:Text(class,"GameFontNormalSmall", tx, ty+2, tz+1)
      elseif UnitClass(object) == "Rogue" then
        Draw:SetColor(255,244,104)
        Draw:Text(class,"GameFontNormalSmall", tx, ty+2, tz+1)
      elseif UnitClass(object) == "Druid" then
        Draw:SetColor(255,124,10)
        Draw:Text(class,"GameFontNormalSmall", tx, ty+2, tz+1)
      end
    end
  end
end)

local function Debug(spellid,text)
  if (lastdebugmsg ~= message or lastdebugtime < GetTime()) then
    local _, _, icon = GetSpellInfo(spellid)
    lastdebugmsg = message
    lastdebugtime = GetTime() + 2
    RaidNotice_AddMessage(RaidWarningFrame, "|T"..icon..":0|t"..text, ChatTypeInfo["RAID_WARNING"],1)
    return true
  end
  return false
end

local playerGUID = UnitGUID("player")
local f = CreateFrame("Frame")
f:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
f:SetScript("OnEvent", function(self, event)
  self:COMBAT_LOG_EVENT_UNFILTERED(CombatLogGetCurrentEventInfo())
  end)

local t = CreateFrame("Frame")
t:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
t:RegisterEvent("PLAYER_TARGET_CHANGED")

local function LogEvent(self, event, ...)
  if event == "COMBAT_LOG_EVENT_UNFILTERED" or event == "COMBAT_LOG_EVENT" then
    self:LogEvent_Original(event, CombatLogGetCurrentEventInfo())
  elseif event == "COMBAT_TEXT_UPDATE" then
    self:LogEvent_Original(event, (...), GetCurrentCombatTextEventInfo())
  else
    self:LogEvent_Original(event, ...)
  end
end

local function OnEventTraceLoaded()
  EventTrace.LogEvent_Original = EventTrace.LogEvent
  EventTrace.LogEvent = LogEvent
end

if EventTrace then
  OnEventTraceLoaded()
else
  local frame = CreateFrame("Frame")
  frame:RegisterEvent("ADDON_LOADED")
  frame:SetScript("OnEvent", function(self, event, ...)
    if event == "ADDON_LOADED" and (...) == "Blizzard_EventTrace" then
      OnEventTraceLoaded()
      self:UnregisterAllEvents()
    end
  end)
end

Routine:RegisterRoutine(function()
  local GetComboPoints = GetComboPoints("player","target")
  local mana = power(0, "player")
  local rage = power(1, "player")
  local energy = power(3, "player")
  local inInstance, instanceType = IsInInstance()

  function isProtected(unit)
    if buff(1020,unit) or debuff(12826,unit) or buff(45438,unit) or buff(642,unit) or buff(1022,unit) or debuff(33786,unit) then 
      return true 
    end
  end

  function isNova(unit)
  if debuff(122,unit) or debuff(33395,unit) or debuff(12494,unit) or debuff(27088,unit) then
    return true end
  end

  function isRooted(unit)
    if debuff(26989,unit) then
      return true end
    end

  --if gcd() > latency() then return end

  if UnitIsDeadOrGhost("player") or isProtected("target") then
    if IsPlayerAttacking("target") then
      Eval('RunMacroText("/stopattack")', 'player')
    end
    if castable(Prowl,"player") and not buff(Prowl,"player") then
      return cast(Prowl,"player")
    end
  return end
  
  _G.QueueDruidCast = function(_spell, _target)
    table.insert(_G.DruidSpellQueue, {spell=_spell, target=_target})
  end

  local function GetAggroRange(unit)
    local range = 0
    local playerlvl = UnitLevel("player")
    local targetlvl = UnitLevel(unit)
    range = 20 - (playerlvl - targetlvl) * 1
    if range <= 5 then
      range = 10
    elseif range >= 45 then
      range = 45
    elseif UnitReaction("player", unit) >= 4 then
      range = 10
    end
    return range +2
  end
  function AoeHasDebuff(spell,range)
    local count = 0
    for object in OM:Objects(OM.Types.Units) do
      if UnitAffectingCombat(object) and UnitCanAttack("player",object) and not UnitIsDeadOrGhost(object) and ObjectDistance("player",object) <= range then
        local isTanking, status, threatpct, rawthreatpct, threatvalue = UnitDetailedThreatSituation("player", object)
        if threatvalue and threatvalue > 0 then
          if debuff(spell,object) then
            count = count + 1
          end
        end
      end
    end
    return count
  end
  local function GetFinisherMaxDamage(ID)
    local function GetStringSpace(x, y)
      for i = 1, 7 do
        if string.sub(x, y + i, y + i) then
          if string.sub(x, y + i, y + i) == " " then
            return i
          end
        end
      end
    end
    local f = GetSpellDescription(ID)
    local _, a, b, c, d, e = strsplit("\n", f)
    local aa, bb, cc, dd, ee = string.find(a, "%-"), string.find(b, "%-"), string.find(c, "%-"), string.find(d, "%-"), string.find(e, "%-")
    return tonumber(string.sub(a, aa + 1, aa + GetStringSpace(a, aa))), tonumber(string.sub(b, bb + 1, bb + GetStringSpace(b, bb))), tonumber(string.sub(c, cc + 1, cc + GetStringSpace(c, cc))), tonumber(string.sub(d, dd + 1, dd + GetStringSpace(d, dd))), tonumber(string.sub(e, ee + 1, ee + GetStringSpace(e, ee)))
  end
  local function manacost(spellname)
    if not spellname then
      return 0
    else
      local costTable = GetSpellPowerCost(spellname)
      if costTable == nil then
        return 0
      end
      for _, costInfo in pairs(costTable) do
        if costInfo.type == 0 then
          return costInfo.cost
        end
      end
    end
  end
  local function GetSpellEffect(spellID)
    local spell_effect_cache = {}
    if not spellID then return end
    if spell_effect_cache[spellID] then return spell_effect_cache[spellID] end
    local desc = GetSpellDescription(spellID);
    local blocks = {};
    for n in desc:gmatch("%S+") do
      table.insert(blocks,n);
    end
    local good = {}
    for i=1,#blocks do
      local s = string.gsub(blocks[i],",","");
      table.insert(good,s);
    end
    local reallygood={};
    for i=1,#good do if tonumber(good[i]) then table.insert(reallygood,tonumber(good[i])); end end
    table.sort(reallygood, function(x,y) return x > y end)
    spell_effect_cache[spellID] = reallygood[1]
    return reallygood[1]
  end
  local function Shapeform()
    if not IsSpellKnown(9634) then
      return manacost("Bear Form")
    end
    if IsSpellKnown(9634) then
      return manacost("Dire Bear Form")
    end
    return false
  end
  local function IsFacing(Unit, Other)
    local SelfX, SelfY, SelfZ = ObjectPosition(Unit)
    local SelfFacing = ObjectRotation(Unit)
    local OtherX, OtherY, OtherZ = ObjectPosition(Other)
    local Angle = SelfX and SelfY and OtherX and OtherY and SelfFacing and ((SelfX - OtherX) * math.cos(-SelfFacing)) - ((SelfY - OtherY) * math.sin(-SelfFacing)) or 0
    return Angle < 0
  end
  local function IsBehind(Unit, Other)
    if not IsFacing(Unit, Other) then
      return true
    else return false
    end
  end
  local function IsPoisoned(unit)
    unit = unit or "player"
    for i=1,30 do
      local debuff,_,_,debufftype = UnitDebuff(unit,i)
      if not debuff then break end
      if debufftype == "Poison" then
        return debuff
      end
    end
  end

  local function isDotted(unit)
  unit = unit or "player"
  for i=1,30 do
    local debuff,_,_,debufftype = UnitDebuff(unit,i)
    if not debuff then break end
      if debufftype == "Disease" or debufftype == "Curse" or debufftype == "Bleed" or debufftype == "Magic" then
        return debuff
      end
    end
  end

  local function isCursed(unit)
  unit = unit or "player"
  for i=1,30 do
    local debuff,_,_,debufftype = UnitDebuff(unit,i)
    if not debuff then break end
      if debufftype == "Curse" then
        return debuff
      end
    end
  end

  local function isCasting(Unit)
    local name  = UnitCastingInfo(Unit);    
    if name then
      return true
    end
  end

  local function isChanneling(Unit)
    local name  = UnitChannelInfo(Unit);    
    if name then
      return true
    end
  end

  local function UnitTargetingUnit(unit1,unit2)
    if UnitIsVisible(UnitTarget(unit1)) and UnitIsVisible(unit2) then
      if UnitGUID(UnitTarget(unit1)) == UnitGUID(unit2) then
        return true
      end
    end
  end

  local function isElite(unit)
    local classification = UnitClassification(unit)
    if classification == "elite" or classification == "rareelite" or classification == "worldboss" then
      return true
    end
  end

  local function noForm(unit)
    if not buff(CatForm,unit) and not buff(DireBearForm,unit) and not buff(TravelForm,unit) and not buff(AquaticForm,unit) then
      return true
    end
  end

  local function Queue()
    if #_G.DruidSpellQueue > 0 then
      local current_spell = _G.DruidSpellQueue[1]
      table.remove(_G.DruidSpellQueue, 1)
      if UnitExists(current_spell.target) and not UnitIsDeadOrGhost(current_spell.target) and distancecheck(current_spell.target, current_spell.spell) and not isProtected(current_spell.target) then
        print("doing manual override spells")        
        return cast(current_spell.spell, current_spell.target)
      else
        print("manual cast was on invalid target. skipped")
      end
    end
  end

  function f:COMBAT_LOG_EVENT_UNFILTERED(...)
    local timestamp, subevent, _, sourceGUID, sourceName, _, _, destGUID, destName, _, _ = ...
    local spellId, spellName, spellSchool
    --local amount, overkill, school, resisted, blocked, absorbed, critical, glancing, crushing, isOffHand

    if subevent == "SPELL_CAST_SUCCESS" then
      local spellId, spellName, _, _, _, _, _, _, _, _, _, _, _ = select(12, ...)
      local myname = UnitName("player")
      if spellName == "Vanish" and (sourceName ~= myname) then
        for object in OM:Objects(OM.Types.Player) do
          if castable(DireBearForm) and not castable(Prowl,"player") and not buff(Prowl,"player") and distance(object,"player") <= 20 then
            Debug(1856,"Bearform to avoid Rogue opener")
            return cast(DireBearForm)
          end
        end
      end
      if spellName == "Summon Water Elemental" and instanceType ~= "arena" and wowex.wowexStorage.read("fap") then
        for object in OM:Objects(OM.Types.Player) do
          if sourceName == ObjectName(object) then
            if distance("player",object) <= 30 and UnitCanAttack("player",object) and GetItemCooldown(5634) == 0 and UnitTargetingUnit(object,"player") and not buff(6615,"player") and not buff(Stealth,"player") and not mounted() then
              Eval('RunMacroText("/use Free Action Potion")', 'player')
            end
          end
        end
      end
    end

    if subevent == "SPELL_CAST_START" then
      local spellId, spellName, _, _, _, _, _, _, _, _, _, _, _ = select(12, ...)
      if spellName == "Fear" or spellName == "Polymorph" or spellName == "Regrowth" or spellName == "Cyclone" or spellName == "Greater Heal" or spellName == "Flash Heal" or spellname == "Healing Wave" or spellname == "Binding Heal" or spellName == "Mana Burn" or spellName == "Drain Mana" or spellName == "Holy Light" then
          if health("target") <= 80 and not debuff(Pounce,"target") then
            for object in OM:Objects(OM.Types.Player) do
              if sourceName == ObjectName(object) then
                if UnitCanAttack("player",object) then
                  if distance("player",object) > 8 then
                    if castable(DireBearForm,"player") and not buff(DireBearForm,"player") and cooldown(FeralCharge) == 0 and not buff(Prowl,"player") and distance("player",object) <= 25 and not UnitTargetingUnit("player",object) then
                      if not isProtected(object) then
                        chargetarget = Object(object)
                        FaceObject(object)
                        Debug(38768,"Bear form to Charge on " .. ObjectName(object))
                        return cast(DireBearForm,"player")
                      end
                    end
                  elseif distance("player",object) <= 8 then
                    if castable(DireBearForm,"player") and not buff(DireBearForm,"player") and cooldown(FeralCharge) == 0 and not buff(Prowl,"player") and health("target") <= 70 then
                      chargetarget = Object(object)
                      Debug(38768,"RUN AWAY FROM TARGET - " .. UnitClass(object) .. " " .. ObjectName(object))
                      return cast(DireBearForm,"player")
                    end
                  end
                end
              end
            end
          end
      end
      if spellName == "Entangling Roots" and destName == myname and instanceType ~= "arena" and wowex.wowexStorage.read("fap") then
        if GetItemCooldown(5634) == 0 and not buff(6615,"player") and not buff(Stealth,"player") and not mounted() then
          Eval('RunMacroText("/use Free Action Potion")', 'player')
        end
      end
    end

    if subevent == "SPELL_INTERRUPT" then
      local kicktime = GetTime()
      local spellId, spellName, _, _, _, _, _, _, _, _, _, _, _ = select(12, ...)
      if spellName == "Kick" and sourceName == UnitName("player") and destName == UnitName("target") then
        kickDuration = kicktime + 5
      end
    end
  end

  function t:UNIT_SPELLCAST_SUCCEEDED()
    t:SetScript("OnEvent", function(self, event, arg1, arg2, arg3)
      trinketUsedBy = nil
      if event == "UNIT_SPELLCAST_SUCCEEDED" then
        if arg3 == 42292 then
          if UnitCanAttack("player",arg1) and distance("player",arg1) <= 20 then
            trinketUsedBy = Object(arg1)
            Debug(42292,"Trinket used by " .. ObjectName(trinketUsedBy))
          end
        end
      end
      if event == "PLAYER_TARGET_CHANGED" and UnitAffectingCombat("player") then 
        for hunter in OM:Objects(OM.Types.Player) do
          if distance("player",hunter) <= 10 then
            if UnitClass(hunter) == "Hunter" then
              if UnitCanAttack("player",hunter) then
                if buff(5384,hunter) then
                  FaceObject(hunter)
                  TargetUnit(hunter)
                  Debug(5384,"Re-targeting Huntard")
                  break
                end
              end
            end
          end
        end
      end
    end)
  end

  local function Kitty()
    local isSwimming = IsSwimming()
    if noForm("player") --[[and not isSwimming]] and not buff(768,"player") and not UnitIsDeadOrGhost("player") and not IsEatingOrDrinking() and not isCasting("player") and not mounted() and not (isCasting(chargetarget) or isChanneling(chargetarget)) then
      if UnitAffectingCombat("player") or ((buff(MarkOfTheWild,"player") or buff(26991,"player")) and buff(Thorns,"player") and buff(OmenOfClarity,"player")) then
        return cast(CatForm,"player")
      end
    end
    --if isSwimming and not buff(AquaticForm,"player") then
    --  return cast(AquaticForm,"player")
    --end
  end

  local function Loot()
    if wowex.wowexStorage.read('autoloot') and not buff(Prowl,"player") then
      for i, object in ipairs(Objects()) do
        if ObjectLootable(object) and ObjectDistance("player",object) < 5 and ObjectType(object) == 3 then
          ObjectInteract(object)
        end
      end
      for i = GetNumLootItems(), 1, -1 do
        LootSlot(i)
      end
    end
    return false
  end

  local function Opener()
    if buff(Prowl,"player") and energy >= 80 then
      if distance("player","target") >= 15 and distance("player","target") <= 40 and energy >= 90 and not buff(9846,"player") and UnitCanAttack("player","target") then
        cast(9846,"player")
      end
      if IsBehind("target","player") then
        if wowex.wowexStorage.read("openerbehind") == "Ravage" and castable(Ravage,"target") then
          return cast(Ravage,"target")
        end
        if wowex.wowexStorage.read("openerbehind") == "Pounce"  and castable(Pounce,"target") then
          return cast(Pounce,"target")
        end
      end
      if not IsBehind("target","player") then
        if wowex.wowexStorage.read("openerfrontal") == "Pounce" and castable(Pounce,"target") then
          return cast(Pounce,"target")
        end
      end
      elseif not buff(Prowl,"player") and energy >= 80 and melee() and not UnitIsPlayer("target") then
        Eval('StartAttack()', 't')
    end    
  end

  local function IsDungeonBoss(unit)
    unit = unit or "target"
    if IsInInstance() or IsInRaid() then
      local _, _, encountersTotal = GetInstanceLockTimeRemaining()
      for i = 1, encountersTotal do
        local boss = GetInstanceLockTimeRemainingEncounter(i)
        local name = UnitName(unit)
        if name == boss then            
          return true
        end
      end
      return false
    end
  end

  local function Interrupt()
    if UnitAffectingCombat("player") and not buff(Prowl,"player") and cooldown(FeralCharge) == 0 and buff(DireBearForm,"player") then
      for object in OM:Objects(OM.Types.Player) do
        if UnitCanAttack("player",object) then
          local kickclass, _, _ = UnitClass(object)
          if isCasting(object) and kickclass ~= "Hunter" then
            if castable(FeralCharge,object) and not isProtected(object) and (distance("player",object) >= 8 and distance("player",object) <= 25) then
              local _, _, _, _, endTime, _, _, _ = UnitCastingInfo(object);
              local finish = endTime/1000 - GetTime()
              if finish <= 1.5 then
                FaceObject(object)
                Debug(9634, "Charge at " .. UnitName(object) .. " at " .. finish)
                return cast(FeralCharge,object)
              end
            end  
          elseif isChanneling(object) and kickclass ~= "Hunter" then
            if castable(FeralCharge,object) and not isProtected(object) and (distance("player",object) >= 8 and distance("player",object) <= 25) then
              FaceObject(object)
              Debug(9634, "Charge at  " .. UnitName(object) .. " fast ")
              return cast(FeralCharge,object)
            end
          end
        end
      end
    end
  end 

  local function Cooldowns()
    if UnitExists("target") and UnitCanAttack("player","target") and UnitAffectingCombat("player") and not buff(Prowl,"player") and not mounted() then
      if (energy <= 20 or noForm("player")) then
        if health() <= 59 and castable(27009) and melee() and noForm("player") then
          return cast(27009,"player")
        end
        if health() <= 59 and castable(Barkskin,"player") and noForm("player") and not buff(Barkskin,"player") and (mana >= manacost("Barkskin") + manacost("Cat Form")) and health("target") >= 20 then
          return cast(Barkskin,"player")
        end
      end
      if castable(Dash) and distance("player","target") >= 25 and UnitAffectingCombat("target") and buff(CatForm,"player") then
        cast(Dash)
        Debug(11305, "Dash used on " .. UnitName("player"))
      end
    end
  end

  local function Healing()
    --if wowex.wowexStorage.read("useHeals") then
      --*ic
      if UnitAffectingCombat("player") and (energy < 40 or noForm("player")) and health("target") >= 70 then
        if health() <= 60 and castable(Lifebloom,"player") and mana >= manacost("Lifebloom") + manacost("Cat Form") and buffCount(Lifebloom, "player", 'HELPFUL') < 2 then 
          return cast(Lifebloom,"player")
        end
        if health() <= 55 and castable(Lifebloom,"player") and mana >= manacost("Lifebloom") + manacost("Cat Form") and buffCount(Lifebloom, "player", 'HELPFUL') < 3 then 
          return cast(Lifebloom,"player")
        end
        if health() <= 50 and not moving("player") and castable(Regrowth,"player") and (not buff(Regrowth,"player") or buffduration(Regrowth,"player") <= 0.3) and mana >= manacost("Regrowth") + manacost("Cat Form") then 
          return cast(Regrowth,"player")
        end
        --if health() <= 20 --[[and not moving("player")]] and castable(HealingTouch,"player") and (mana >= manacost("Healing Touch") + manacost("Cat Form")) and health("target") >= 20 then 
        --  return cast(HealingTouch,"player")
        --end
        if wowex.wowexStorage.read("useDispel") and IsPoisoned("player") and castable(AbolishPoison,"player") and not buff(AbolishPoison,"player") and noForm("player") then
          Debug(2893," Abolished "..UnitName("player"))
          return cast(AbolishPoison,"player")
        end
        if isCursed("player") and castable(RemoveCurse,"player") and noForm("player") and health() >= 30 then
          Debug(2893," Cured "..UnitName("player"))
          return cast(RemoveCurse,"player")
        end
      end
      --*ooc
      if not UnitAffectingCombat("player") and not IsEatingOrDrinking("player") and not buff(Prowl,"player") then
        if castable(Innervate,"player") and mana <= 2000 then
          return cast(Innervate,"player")
        end
        if (health() <= 75 and castable(Rejuvenation,"player") and (not buff(Rejuvenation,"player") or buffduration(Rejuvenation,"player") <= 0.3) --[[and (mana >= manacost("Rejuvenation") + manacost("Cat Form"))]] and health("target") >= 20) --[[or mana <= manacost("Gift of the Wild")]] then 
          return cast(Rejuvenation,"player") 
        end
        if health() <= 60 and castable(Lifebloom,"player") and mana >= manacost("Lifebloom") + manacost("Cat Form") and buffCount(Lifebloom, "player", 'HELPFUL') < 2 then 
          return cast(Lifebloom,"player")
        end
        if health() <= 55 and castable(Lifebloom,"player") and mana >= manacost("Lifebloom") + manacost("Cat Form") and buffCount(Lifebloom, "player", 'HELPFUL') < 3 then 
          return cast(Lifebloom,"player")
        end
        if health() <= 50 and not moving("player") and castable(Regrowth,"player") and (not buff(Regrowth,"player") or buffduration(Regrowth,"player") <= 0.3) and mana >= manacost("Regrowth") + manacost("Cat Form") then 
          return cast(Regrowth,"player")
        end
        --if health() <= 20 --[[and not moving("player")]] and castable(HealingTouch,"player") and mana >= manacost("Healing Touch") + manacost("Cat Form") then 
        --  return cast(HealingTouch,"player")
        --end
        if wowex.wowexStorage.read("useDispel") and IsPoisoned("player") and castable(AbolishPoison,"player") and not buff(AbolishPoison,"player") and noForm("player") then
          Debug(2893," Cured "..IsPoisoned("player"))          
          return cast(AbolishPoison,"player")
        end
        if isCursed("player") and castable(RemoveCurse,"player") and noForm("player") and health() >= 30 then
          Debug(2893," Cured "..UnitName("player"))
          return cast(RemoveCurse,"player")
        end
      end
    --end
    return false
  end
  local function Dps()
    if UnitCanAttack("player","target") and not UnitIsDeadOrGhost("target") and not buff(Prowl,"player") then
      local dpsEnergy = power(3, "player")
      if not IsPlayerAttacking('target') then
        Eval('StartAttack()', 't')
      end
      if buff(CatForm,"player") and melee() then
        if castable(FerociousBite,"target") and not UnitIsPlayer("target") then
          local ap = UnitAttackPower("player")
          local multiplier = 2.6
          local f1, f2, f3, f4, f5 = GetFinisherMaxDamage("Ferocious Bite")
          local fb1calculated = ap * (1 * 0.03) + f1 * multiplier
          local fb2calculated = ap * (2 * 0.03) + f2 * multiplier
          local fb3calculated = ap * (3 * 0.03) + f3 * multiplier
          local fb4calculated = ap * (4 * 0.03) + f4 * multiplier
          local fb5calculated = ap * (5 * 0.03) + f4 * multiplier
          if UnitHealth("target") <= fb1calculated and GetComboPoints == 1 then
            return cast(FerociousBite,"target")
          end
          if UnitHealth("target") <= fb2calculated and GetComboPoints == 2 then
            return cast(FerociousBite,"target")
          end
          if UnitHealth("target") <= fb3calculated and GetComboPoints == 3 then
            return cast(FerociousBite,"target")
          end
          if UnitHealth("target") <= fb4calculated and GetComboPoints == 4 then
            return cast(FerociousBite,"target")   
          end
          if UnitHealth("target") <= fb5calculated and GetComboPoints == 5 then
            return cast(FerociousBite,"target")
          end
        end
        if castable(Rip,"target") and not debuff(Rip,"target") and health("target") >= 60 then
          if GetComboPoints >= 5 then
            return cast(Rip,"target")
          end
        end
        if castable(FerociousBite, "target") and GetComboPoints >= 5 and UnitHealth("target") <= 50 and UnitIsPlayer("target") then
          Debug(26865, "Uncalculated Ferocious Bite on " .. UnitName("target"))          
          return cast(FerociousBite, "target")
        end
        if castable(MangleCat) and GetComboPoints < 5 and (not debuff(MangleCat,"target") or debuffduration(MangleCat,"target") <= 0.4) then
          return cast(MangleCat,"target")
        end
        if IsBehind("target","player") then
          if castable(Shred,"target") and GetComboPoints < 5 then
            return cast(Shred,"target")
          end
        end
        --if castable(Rake,"target") and (not debuff(Rake,"target") or debuffduration(Rake,"target") <= 0.5) and health("target") >= 25 and GetComboPoints < 5 then
        --  return cast(Rake,"target")
        --end
        if (not IsBehind("target","player") or not castable(Shred)) then
          if castable(MangleCat,"target") and GetComboPoints < 5 then
            return cast(MangleCat,"target")
          end
        end
        if castable(FaerieFireFeral,"target") and not buff(16870,"player") and (not debuff(FaerieFireFeral,"target") or debuffduration(FaerieFireFeral,"target") <= 0.4) and (not immune("target",FaerieFireFeral) or UnitIsPlayer("target")) and (not buff(9846,"player") or dpsEnergy <= 34) --[[and (dpsEnergy <= 79 or not melee())]] then
          return cast(FaerieFireFeral,"target")
        end
      elseif buff(CatForm,"player") and not melee() then
        if castable(FaerieFireFeral,"target") and UnitAffectingCombat("player") and not buff(16870,"player") and (not debuff(FaerieFireFeral,"target") or debuffduration(FaerieFireFeral,"target") <= 0.4) and (not immune("target",FaerieFireFeral) or UnitIsPlayer("target")) and (not buff(9846,"player") or dpsEnergy <= 34) and (dpsEnergy <= 79 or not melee()) then
          return cast(FaerieFireFeral,"target")
        end
      end
      --*Bear
      if buff(BearForm,"player") or buff(DireBearForm,"player") then
        local rage = power(PowerType.Rage, "player")
        local base, posBuff, negBuff = UnitAttackPower("player")
        local effective = base + posBuff + negBuff
        local MaulID = resolveSpellID(Maul)
        if castable(FeralCharge,chargetarget) and (isCasting(chargetarget) or isChanneling(chargetarget)) then
          return cast(FeralCharge,chargetarget)
        end
        if castable(Bash,"target") and not debuff(FeralCharge,"target") then
          return cast(Bash,"target")
        end
        if castable(FaerieFireFeral,"target") and not buff(16870,"player") and (not debuff(FaerieFireFeral,"target") or debuffduration(FaerieFireFeral,"target") <= 0.4) and (not immune("target",FaerieFireFeral) or UnitIsPlayer("target")) and (not buff(9846,"player") or rage <= 10) then
          return cast(FaerieFireFeral,"target")
        end
        if castable(Growl) then
          for object in OM:Objects(OM.Types.Units) do
            if UnitCanAttack("player",object) and UnitCreatureType(object) ~= "Critter" and not UnitIsPlayer(object) and not UnitIsDeadOrGhost(object) then
              local isTanking, status, threatpct, rawthreatpct, threatvalue = UnitDetailedThreatSituation("player", object)
              if threatpct and threatpct <= 60 and distance("player",object) <= 8 then
                cast(Growl,object)
              end
            end
          end
        end
        if AoeHasDebuff(DemoralizingRoar,8) < enemies("player", 8) and castable(DemoralizingRoar) then
          return cast(DemoralizingRoar)
        end
        if enemies("player",8) >= 3 then
          if castable(Swipe,"target") then
            return cast(Swipe,"target")
          end
          if rage > 45 and not IsCurrentSpell(MaulID) then
            return cast(Maul,"target")
          end
        end
        if enemies("player", 8) < 3 then
          if castable(Lacerate) and (debuffCount(Lacerate, "target") < 5 or debuffduration(Lacerate,"target") <= 2) then --(debuffCount('target', Lacerate) < 5 or debuffduration(Lacerate,"target") <= 2) then
            return cast(Lacerate,"target")
          end
          if rage > 45 and not IsCurrentSpell(MaulID) then
            return cast(Maul,"target")
          end
        end        
      end
    end
    return false
  end

  local function Buff()
    if not UnitAffectingCombat("player") and not buff(Prowl,"player") then
      local isArena, isRegistered = IsActiveBattlefieldArena();
      if castable(MarkOfTheWild,"player") and not (buff(MarkOfTheWild,"player") or buff(26991,"player")) then
        return cast(MarkOfTheWild,"player")
      end
      if castable(Thorns,"player") and (not buff(Thorns,"player") or buffduration(Thorns,"player") <= 60) then
        return cast(Thorns,"player")
      end
      if castable(OmenOfClarity) and (not buff(OmenOfClarity,"player") or buffduration(OmenOfClarity,"player") <= 120) then
        return cast(OmenOfClarity,"player")
      end
    end
    if not UnitAffectingCombat("player") and (buff(BearForm,"player") or buff(DireBearForm,"player")) then 
      if rage <= 20 and rage >= 5 then
        if distance("player","target") <= 25 and distance("player","target") > 15 then
          cast(Enrage,"player")
          Debug(5229,"Enrage on Pull")
        end
      end
      if rage == 0 and UnitExists("target") and not UnitIsDeadOrGhost("target") and distance("player","target") <= 25 then
        Eval('RunMacroText("/cast !Dire Bear Form")', 'r')
        Debug(9634,"Power Shift 0 Rage on Pull")
      end
    end
    if isArena then
      for i = 1 , GetNumGroupMembers() do
        if not buff(MarkOfTheWild,"PARTY"..i) and castable(MarkOfTheWild,"PARTY"..i) then
          return cast(MarkOfTheWild,"PARTY"..i)
        end
      end
      for i = 1 , GetNumGroupMembers() do
        if not buff(Thorns,"PARTY"..i) and castable(Thorns,"PARTY"..i) then
          return cast(Thorns,"PARTY"..i)
        end
      end
    end
  end

  local function pvp()
    if isNova("player") or isRooted("player") then
      if buff(BearForm,"player") then
        return cast(BearForm)
      end
      if buff(DireBearForm,"player") then
        return cast(DireBearForm)
      end
      if buff(TravelForm,"player") then
        return cast(TravelForm)
      end
      if buff(768,"player") or noForm("player") then
        Eval('RunMacroText("/cast !Cat Form")', 'r')
      end
    end
    if instanceType == "pvp" then
      for flag in OM:Objects(OM.Types.GameObject) do
        if ObjectID(flag) == 328418 or ObjectID(flag) == 328416 or ObjectID(flag) == 367128 then
          if distance("player",flag) <= 5 then
            InteractUnit(flag)
          end
        elseif ObjectID(flag) == 183511 then
          if GetItemCount(22103) == 0 then
            if distance("player",flag) <= 5 then
              InteractUnit(flag)
            end
          end
        elseif ObjectID(flag) == 183512 then
          if GetItemCount(22104) == 0 then 
            if distance("player",flag) <= 5 then
              InteractUnit(flag)
            end 
          end
        elseif ObjectID(flag) == 181621 then
          if GetItemCount(22105) == 0 then 
            if distance("player",flag) <= 5 then
              InteractUnit(flag)
            end
          end
        end
      end
    end
    for object in OM:Objects(OM.CreatureTypes) do
      local totemname = ObjectName(object)
      if totemname == "Stoneskin Totem" or totemname == "Windfury Totem" or totemname == "Poison Cleansing Totem" or totemname == "Mana Tide Totem" or totemname == "Grounding Totem" or totemname == "Earthbind Totem" then
        if melee("player",totemname) and health("target") >= 20 and not (buff(Stealth,"player") or buff(Vanish,"player")) then
          if UnitCanAttack("player",object) then
            oldertarget = Object("target")
            totemobject = Object(object)
            TargetUnit(totemobject)
            FaceObject(totemobject)
            Eval('StartAttack()', 't')
          end
          if not UnitExists("target") then
            TargetUnit(oldertarget)
          end
        end
      end
    end
  end

  local function healthstone()
    local healthstonelist = {22103, 22104, 22105}
    if health() <= 40 and UnitAffectingCombat("player") then
      for i = 1, #healthstonelist do
        if GetItemCount(healthstonelist[i]) >= 1 and GetItemCooldown(healthstonelist[i]) == 0 then
          local healthstonename = GetItemInfo(healthstonelist[i])
          Eval('RunMacroText("/use ' .. healthstonename .. '")', 'player')
          Debug(22103,"Healthstone used!!")
        end
      end
    end
  end

  local function Dismounter()
    if UnitIsPlayer(ObjectTargetingMe) and distance("player",ObjectTargetingMe) <= 45 and not (buff(301089,"target") or buff(301091,"target") or buff(34976,"target")) then
      Dismount()
    end
  end

  local function Hide()
    if instanceType == "pvp" and not UnitAffectingCombat("player") and not buff(Prowl,"player") and not IsPoisoned("player") and not isDotted("player") then
      cast(Prowl)
    end
    if not buff(Prowl,"player") and not UnitIsDeadOrGhost("target") and not UnitAffectingCombat("player") and UnitCanAttack("player","target") and not melee() and not (buff(301089,"target") or buff(301091,"target") or buff(34976,"target")) then
      if UnitExists("target") and distance("player","target") <= 30 and not IsPoisoned("player") and not isDotted("player") then
        cast(Prowl)
      end
    end
  end

--[[
  local function Hide()
    if wowex.wowexStorage.read("useStealth") and not buff(Prowl,"player") and castable(Prowl) then
      if wowex.wowexStorage.read("stealthmode") == "DynOM" then
        for object in OM:Objects(OM.Types.Unit) do
          if ObjectType(object) == 3 and UnitCanAttack("player",object) and UnitCreatureType(object) ~= "Critter" and distance("player",object) <= GetAggroRange(object) and not UnitIsDeadOrGhost(object) and not UnitAffectingCombat(object) then
            return return cast(Prowl)
          end
        end
      end
      if UnitIsPlayer("target") and distance("player","target") <= 30 and UnitCanAttack("player","target") then
        return return cast(Prowl)
      end
    end    
    return false
  end
]]

  local function PowerShift()
    if UnitAffectingCombat("player") and not UnitIsDeadOrGhost("target") and UnitExists("target") and buff(CatForm,"player") and energy <= 19 and mana >= manacost("Cat Form") and not buff(16870,"player") and health("target") >= 15 then
      Eval('RunMacroText("/cast !Cat Form")', 'r')
    end 
  end
  local function OutOfCombat()
    if not UnitAffectingCombat("player") then
      if Queue() then return true end
      if Opener() then return true end
      --if Loot() then return true end
      if Healing() then return true end
      if Buff() then return true end
      --if Kitty() then return true end
      if Hide() then return true end
      if pvp() then return true end
      if Dismounter() then return true end
    end
    return false
  end
  local function Incombat()
    if UnitAffectingCombat("player") then
      if Queue() then return true end
      if PowerShift() then return true end
      if Cooldowns() then return true end     
      if Healing() then return true end
      --if Kitty() then return true end
      if Dps() then return true end
      if PowerShift() then return true end
      if Interrupt() then return true end
      if pvp() then return true end
      if healthstone() then return true end
      if Dismounter() then return true end
      if f:COMBAT_LOG_EVENT_UNFILTERED() then return true end
      if t:UNIT_SPELLCAST_SUCCEEDED() then return true end
    end
    return false
  end  
  if OutOfCombat() then return true end
  if Incombat() then return true end
  
end, Routine.Classes.Druid, Routine.Specs.Druid)
Routine:LoadRoutine(Routine.Specs.Druid)

local button_example = {
  {
    key = "useStealth",
    buttonname = "useStealth",
    texture = "ability_druid_supriseattack",
    tooltip = "Stealth",
    text = "Stealth",
    setx = "TOP",
    parent = "settings",
    sety = "TOPRIGHT"
  },
  {
    key = "useHeals",
    buttonname = "useHeals",
    texture = "spell_nature_healingtouch",
    tooltip = "Use Heals",
    text = "Use Heals",
    setx = "TOP",
    parent = "useStealth",
    sety = "TOPRIGHT"
  },
  {
    key = "useDispel",
    buttonname = "useDispel",
    texture = "Spell_nature_nullifypoison",
    tooltip = "Dispel Poison",
    text = "Dispel Poison",
    setx = "TOP",
    parent = "useHeals",
    sety = "TOPRIGHT"
  },
}
wowex.button_factory(button_example)

local mytable = {
  key = "cromulon_config",
  name = "Yosh Feral Tbc",
  height = 650,
  width = 400,
  panels = 
  {
    { 
      name = "Offensive",
      items = 
      {
        { key = "heading", type = "text", color = 'FF7C0A', text = "Multiplier = Eviscerate=Attack Power * (Number of Combo Points used * 0.03) * abitrary multiplier to account for Auto Attacks while pooling Recommendation : <= 60 == 1.6 >= 60 == 1.4" },
        
        { key = "heading", type = "heading", color = 'FF7C0A', text = "Execute" },
        { key = "personalmultiplier", type = "slider", text = "Execute Multiplier", label = "Execute Multiplier", min = 1, max = 3, step = 0.1 },
        { key = "heading", type = "heading", color = 'FF7C0A', text = "Opener" },
        { key = "openerfrontal", width = 175, label = "Frontal", text = wowex.wowexStorage.read("openerfrontal"), type = "dropdown",
        options = {"Pounce", "None",} },
        { key = "openerbehind", width = 175, label = "Behind", text = wowex.wowexStorage.read("openerbehind"), type = "dropdown",
        options = {"Ravage", "Pounce","None"} },
        --{ key = "pershealwavepercent", type = "slider", text = "Healing Wave", label = "Healing Wave at", min = 1, max = 100, step = 1 },
        
      },
    },
    { 
      name = "Defensives",
      items = 
      {
        { key = "heading", type = "heading", color = 'FF7C0A', text = "In Combat Healing" },
        { key = "heading", type = "heading", color = 'FF7C0A', text = "Rejuvenation" },
        { key = "rejuvichp", type = "slider", text = "", label = "Rejuvenation at", min = 1, max = 100, step = 1 },
        { key = "heading", type = "heading", color = 'FF7C0A', text = "Healing Touch" },
        { key = "healingtouchichp", type = "slider", text = "", label = "Healing Touch at", min = 0, max = 100, step = 1 },
        { key = "heading", type = "heading", color = 'FF7C0A', text = "Regrowth" },
        { key = "regrowthichp", type = "slider", text = "", label = "Regrowth at", min = 0, max = 100, step = 1 },
        { key = "heading", type = "heading", color = 'FF7C0A', text = "Out of Combat Healing" },
        { key = "heading", type = "heading", color = 'FF7C0A', text = "Rejuvenation" },
        { key = "rejuvoochp", type = "slider", text = "", label = "Rejuvenation at", min = 1, max = 100, step = 1 },
        { key = "heading", type = "heading", color = 'FF7C0A', text = "Healing Touch" },
        { key = "healingtouchoochp", type = "slider", text = "", label = "Healing Touch at", min = 0, max = 100, step = 1 },
        { key = "heading", type = "heading", color = 'FF7C0A', text = "Regrowth" },
        { key = "regrowthoochp", type = "slider", text = "", label = "Regrowth at", min = 0, max = 100, step = 1 },
        
      }
    },
    { 
      name = "General",
      items = 
      {
        { key = "heading", type = "heading", color = 'FF7C0A', text = "Stealth" },
        {type = "text", text = "DynOM = Scans the area around you for NPC aggro ranges and puts you into stealth when you get close to them.", color = 'FF7C0A'},
        {type = "text", text = "DynTarget = Stealthes you when you're near your TARGET's aggro range.", color = 'FF7C0A'},       
        { key = "stealthmode", width = 175, label = "Stealth Mode", text = wowex.wowexStorage.read("stealthmode"), type = "dropdown",
        options = {"DynOM", "DynTarget",} },
        
        { key = "heading", type = "heading", color = 'FF7C0A', text = "Other" },
        { key = "autoloot",  type = "checkbox", text = "Auto Loot", desc = "" },
        
      }
    },
    { 
      name = "Draw",
      items = 
      {
        --  { key = "bladeflurrydraw",  type = "checkbox", text = "BladeFlurry Range", desc = "" },
        --  { key = "targetingusdraw",  type = "checkbox", text = "Players targeting us", desc = "" },
        --  {type = "text", text = "Red: >= 30y yellow: <= 30y green: <= 8y", color = 'FFF468'},
        { key = "pvpdraw",  type = "checkbox", text = "PvP Radar", desc = "" },
        
      }
    },
  },
  
  tabgroup = 
  {
    {text = "Offensive", value = "one"},
    {text = "Defensives", value = "two"},
    {text = "General", value = "three"},
    {text = "Draw", value = "four"}
    
  }
}
Draw:Enable()
wowex.createpanels(mytable)
wowex.panel:Hide()     