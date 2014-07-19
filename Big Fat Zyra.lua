if myHero.charName ~= "Zyra" then return end
	
local version = "0.03"
local AUTOUPDATE = true
local UPDATE_HOST = "raw.github.com"
local UPDATE_PATH = "/BigFatNidalee/BoL-Releases/master/Big Fat Zyra.lua".."?rand="..math.random(1,10000)
local UPDATE_FILE_PATH = SCRIPT_PATH.."Big Fat Zyra.lua"
local UPDATE_URL = "https://"..UPDATE_HOST..UPDATE_PATH

function AutoupdaterMsg(msg) print("<font color=\"#66cc00\">Big Fat Zyra:</font> <font color=\"#FFFFFF\">"..msg..".</font>") end
if AUTOUPDATE then
local ServerData = GetWebResult(UPDATE_HOST, "/BigFatNidalee/BoL-Releases/master/versions/Big Fat Zyra.version")
if ServerData then
ServerVersion = type(tonumber(ServerData)) == "number" and tonumber(ServerData) or nil
if ServerVersion then
if tonumber(version) < ServerVersion then
AutoupdaterMsg("New version available"..ServerVersion)
AutoupdaterMsg("Updating, please don't press F9")
DelayAction(function() DownloadFile(UPDATE_URL, UPDATE_FILE_PATH, function () AutoupdaterMsg("Successfully updated. ("..version.." => "..ServerVersion.."), press F9 twice to load the updated version.") end) end, 3)
else
AutoupdaterMsg("You have got the latest version ("..ServerVersion..")")
end
end
else
AutoupdaterMsg("Error downloading version info")
end
end
--[[

227.223
1135.79

241.72
903.50
range = 800, width = 240, speed = 1400, delay = .5
                 [_Q] = { speed = math.huge, delay = 0.7, range = 800, minionCollisionWidth = 0},
         [_E] = { speed = 1150, delay = 0.16, range = 1100, minionCollisionWidth = 0}
		 800, math.huge, 0.7, 215
		 1125, 935, 0.245
]]--
local QReady, WReady, EReady, RReady = false, false, false, false

--local QRange, QSpeed, QDelay, QWidth = 800, math.huge, 0.7, 85
local QRange, QSpeed, QDelay, QWidth, QWidth2 = 800, 1400, 0.5, 100, 150
local WRange, WSpeed, WDelay, WWidth = 825, math.huge, 0.2432, 10
local ERange, ESpeed, EDelay, EWidth = 1000, 1130, 0.23, 40
local ERangeCut = 900
local RRange, RSpeed, RDelay, RRadius = 700, math.huge, 0.500, 500
local PRange, PSpeed, PDelay, PWidth = 1470, 1870, 0.500, 60
local CastingQ = false
-- Orbwalk --
local myTarget = nil
local lastAttack, lastWindUpTime, lastAttackCD = 0, 0, 0

local processes = {}
local prodqposes = {}
-- Skinhack
local lastSkin = 0

function OnLoad()

	require "Prodiction"
	Myspace = GetDistance(myHero.minBBox)
	
	myTrueRange = 575 + Myspace
	
	ZyraMenu = scriptConfig("Big Fat Zyra", "Big Fat Zyra")
	ZyraMenu:addSubMenu("[Combo]", "Combo")
	ZyraMenu.Combo:addParam("UseQ","Use Q", SCRIPT_PARAM_ONOFF, true)
	ZyraMenu.Combo:addParam("UseE","Use E", SCRIPT_PARAM_ONOFF, true)
	ZyraMenu.Combo:addParam("UseW","Use W", SCRIPT_PARAM_ONOFF, true)

	ZyraMenu:addSubMenu("[Harass]", "Harass")
	ZyraMenu.Harass:addParam("info", "~=[ Mixed Mode ]=~", SCRIPT_PARAM_INFO, "")
    ZyraMenu.Harass:addParam("Harass1Mode","Harass Q Mode", SCRIPT_PARAM_LIST, 1, { "Only if W Ready", "Dont wait for W" })
	ZyraMenu.Harass:addParam("ManaSliderHarass1", "Min mana to use skills",   SCRIPT_PARAM_SLICE, 40, 0, 100, 0)
	ZyraMenu.Harass:addParam("info", "~=[ Lane Clear Mode ]=~", SCRIPT_PARAM_INFO, "")
    ZyraMenu.Harass:addParam("Harass2Mode","Harass Q Mode", SCRIPT_PARAM_LIST, 2, { "Only if W Ready", "Dont wait for W" })
	ZyraMenu.Harass:addParam("ManaSliderHarass2", "Min mana to use skills",   SCRIPT_PARAM_SLICE, 40, 0, 100, 0)


	ZyraMenu:addSubMenu("[KS Options]", "KSOptions")
	ZyraMenu.KSOptions:addParam("KSwithQ","KS with Q", SCRIPT_PARAM_ONOFF, true)
	ZyraMenu.KSOptions:addParam("KSwithE","KS with E", SCRIPT_PARAM_ONOFF, true)
	ZyraMenu.KSOptions:addParam("Lachen","senden lachen waehrend KS", SCRIPT_PARAM_ONOFF, true)
	
	ZyraMenu:addSubMenu("[Ultimate]", "Ultimate")
	ZyraMenu.Ultimate:addParam("UseAutoUlt","Use Auto Ult", SCRIPT_PARAM_ONOFF, true)
	ZyraMenu.Ultimate:addParam("UltGroupMinimum", "Ult Enemy Team Min:", SCRIPT_PARAM_SLICE, 3, 2, 5, 0)
	
	ZyraMenu:addSubMenu("[Prodiction Settings]", "ProdictionSettings")
	ZyraMenu.ProdictionSettings:addParam("UsePacketsCast","Use Packets Cast", SCRIPT_PARAM_ONOFF, true)
	ZyraMenu.ProdictionSettings:addParam("info0", "", SCRIPT_PARAM_INFO, "")
	ZyraMenu.ProdictionSettings:addParam("QHitchance", "Q Hitchance", SCRIPT_PARAM_SLICE, 1, 1, 3, 0)
	ZyraMenu.ProdictionSettings:addParam("EHitchance", "E Hitchance", SCRIPT_PARAM_SLICE, 2, 1, 3, 0)
	ZyraMenu.ProdictionSettings:addParam("info", "", SCRIPT_PARAM_INFO, "")
	ZyraMenu.ProdictionSettings:addParam("info2", "HITCHANCE:", SCRIPT_PARAM_INFO, "")
	ZyraMenu.ProdictionSettings:addParam("info3", "LOW = 1  NORMAL = 2  HIGH = 3", SCRIPT_PARAM_INFO, "")
	ZyraMenu:addSubMenu("[Draws]", "draws")
	ZyraMenu.draws:addParam("DrawQ","Draw Q Range", SCRIPT_PARAM_ONOFF, true)
	ZyraMenu.draws:addParam("DrawE","Draw E Range", SCRIPT_PARAM_ONOFF, true)

	ZyraMenu:addParam("Orbwalk","Use Orbwalk", SCRIPT_PARAM_ONOFF, true)
	ZyraMenu:addParam("SBTW","Combo Key", SCRIPT_PARAM_ONKEYDOWN, false, 32)
	ZyraMenu:addParam("Harass1key","Harass Key", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("X"))
	ZyraMenu:addParam("Harass2key","Harass 2 Key", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("C"))
	
	ZyraMenu:addParam("blank2", "", SCRIPT_PARAM_INFO, "")
	ZyraMenu:addParam("skin", "Skin Hack by Shalzuth:", SCRIPT_PARAM_LIST, 1, { "Wildfire", "Haunted", "SKT T1", "No Skin" })
	ZyraMenu:addParam("blank3", "", SCRIPT_PARAM_INFO, "")
	ZyraMenu:addParam("info1", "Big Fat Zyra: Test v. "..version.."", SCRIPT_PARAM_INFO, "")
	ZyraMenu:addParam("info2", "by Big Fat Nidalee", SCRIPT_PARAM_INFO, "")
	
	ts = TargetSelector(TARGET_LESS_CAST, 1400, true)
	ts.name = "ZyraMenu"
    ZyraMenu:addTS(ts)
	
	PrintChat("<font color='#c9d7ff'>BigFatNidalee's Zyra: </font><font color='#64f879'> "..version.." </font><font color='#c9d7ff'> loaded, happy elo boosting! </font>")
	
	

	
end 

function OnTick()

	ts:update()
	Target = ts.target

	QReady = (myHero:CanUseSpell(_Q) == READY)
	WReady = (myHero:CanUseSpell(_W) == READY)
	EReady = (myHero:CanUseSpell(_E) == READY)
	RReady = (myHero:CanUseSpell(_R) == READY)
	PReady = (myHero:GetSpellData(_Q).name == myHero:GetSpellData(_W).name or myHero:GetSpellData(_W).name == myHero:GetSpellData(_E).name)
	
	if ValidTarget(Target) then
	KS()
	end 
		-- Range checks

	if ValidTarget(Target) and ZyraMenu.SBTW then
	Combo() 
	end
	
	if ValidTarget(Target) and ZyraMenu.Harass1key then 
	Harass1()
	end
	if ZyraMenu.Orbwalk and ZyraMenu.SBTW or ZyraMenu.Harass1key or ZyraMenu.Harass2key then
	OrbWalk()
	end
	
	if ValidTarget(Target) and ZyraMenu.Harass2key then 
	Harass2()
	end

	if ZyraMenu.Ultimate.UseAutoUlt then
	UltGroup()
	end
	-- Skinhack
	SkinHack()
end 
 -- << --  -- << --  -- << --  -- << -- [Skin Hack]  -- >> --  -- >> --  -- >> --  -- >> --
function GenModelPacket(champ, skinId)
	p = CLoLPacket(0x97)
	p:EncodeF(myHero.networkID)
	p.pos = 1
	t1 = p:Decode1()
	t2 = p:Decode1()
	t3 = p:Decode1()
	t4 = p:Decode1()
	p:Encode1(t1)
	p:Encode1(t2)
	p:Encode1(t3)
	p:Encode1(bit32.band(t4,0xB))
	p:Encode1(1)--hardcode 1 bitfield
	p:Encode4(skinId)
	for i = 1, #champ do
		p:Encode1(string.byte(champ:sub(i,i)))
	end
	for i = #champ + 1, 64 do
		p:Encode1(0)
	end
	p:Hide()
	RecvPacket(p)
end

function SkinHack()
if ZyraMenu.skin ~= lastSkin and VIP_USER then
	lastSkin = ZyraMenu.skin
	GenModelPacket("Zyra", ZyraMenu.skin)
end
end
 -- << --  -- << --  -- << --  -- << -- [COMBO]  -- >> --  -- >> --  -- >> --  -- >> --
 
function Combo()
	if not Target then return end
	
	if EReady and ZyraMenu.Combo.UseE and GetDistance(Target) <= ERange then

			if GetDistance(Target) <= ERangeCut and myHero.mana >= ManaCost(E)  then

					local epos, einfo = Prodiction.GetLineAOEPrediction(Target, ERange, ESpeed, EDelay, EWidth, myPlayer)
					if epos and einfo.hitchance >= ZyraMenu.ProdictionSettings.EHitchance then
						if ZyraMenu.ProdictionSettings.UsePacketsCast then
						Packet('S_CAST', {spellId = _E, toX = epos.x, toY = epos.z, fromX = epos.x, fromY = epos.z}):send(true)
						else 
						CastSpell(_E, epos.x, epos.z)
						end	

					end 
			end
		end

	
	if QReady and ZyraMenu.Combo.UseQ then
		if GetDistance(Target) <= QRange and myHero.mana >= ManaCost(Q) then
			
			local qpos, qinfo = Prodiction.GetCircularAOEPrediction(Target, QRange, QSpeed, QDelay, QWidth, myPlayer)
			
			if qpos and qinfo.hitchance >= ZyraMenu.ProdictionSettings.QHitchance then
							
				if ZyraMenu.Combo.UseW then				
					if ZyraMenu.ProdictionSettings.UsePacketsCast then
					Packet('S_CAST', {spellId = _W, toX = qpos.x, toY = qpos.z, fromX = qpos.x, fromY = qpos.z}):send(true)
					else 
					CastSpell(_W, qpos.x, qpos.z)
					end	
				end	
				
				
				if ZyraMenu.ProdictionSettings.UsePacketsCast then
				Packet('S_CAST', {spellId = _Q, toX = qpos.x, toY = qpos.z, fromX = qpos.x, fromY = qpos.z}):send(true)
				else 
				CastSpell(_Q, qpos.x, qpos.z)
				end

				if ZyraMenu.Combo.UseW then				
					if ZyraMenu.ProdictionSettings.UsePacketsCast then
					Packet('S_CAST', {spellId = _W, toX = qpos.x, toY = qpos.z, fromX = qpos.x, fromY = qpos.z}):send(true)
					else 
					CastSpell(_W, qpos.x, qpos.z)
					end	
				end	
			end
			
		end
	end

	

end	

-- << --  -- << --  -- << --  -- << -- [Harass]  -- >> --  -- >> --  -- >> --  -- >> --
function Harass1()
	if not Target then return end
	
	if ZyraMenu.Harass.Harass1Mode == 1 then
		if QReady and WReady and not mymanaislowerthen(ZyraMenu.Harass.ManaSliderHarass1) and GetDistance(Target) <= QRange then
				local qpos, qinfo = Prodiction.GetPrediction(Target, QRange, QSpeed, QDelay, QWidth2, myPlayer)
			
				if qpos and qinfo.hitchance >= ZyraMenu.ProdictionSettings.QHitchance then
				prodqposes[1] = qpos.x
				prodqposes[2] = qpos.z


					if ZyraMenu.ProdictionSettings.UsePacketsCast then
					Packet('S_CAST', {spellId = _W, toX = qpos.x, toY = qpos.z, fromX = qpos.x, fromY = qpos.z}):send(true)
					else
					CastSpell(_W, qpos.x, qpos.z)
					end
				
					if ZyraMenu.ProdictionSettings.UsePacketsCast then
					Packet('S_CAST', {spellId = _Q, toX = qpos.x, toY = qpos.z, fromX = qpos.x, fromY = qpos.z}):send(true)
					else
					CastSpell(_Q, qpos.x, qpos.z)
					end
				
					if ZyraMenu.ProdictionSettings.UsePacketsCast then
					Packet('S_CAST', {spellId = _W, toX = qpos.x, toY = qpos.z, fromX = qpos.x, fromY = qpos.z}):send(true)
					else
					CastSpell(_W, qpos.x, qpos.z)
					end
					if processes[1] ~= nil then
						if ZyraMenu.ProdictionSettings.UsePacketsCast then
						Packet('S_CAST', {spellId = _W, toX = processes[1], toY = processes[3], fromX = processes[1], fromY = processes[3]}):send(true)
						else
						CastSpell(_W, processes[1], processes[3])
						end
					end

				end
			
		end 
	elseif ZyraMenu.Harass.Harass1Mode == 2 then
		if QReady and WReady and not mymanaislowerthen(ZyraMenu.Harass.ManaSliderHarass1) and GetDistance(Target) <= QRange then
				local qpos, qinfo = Prodiction.GetPrediction(Target, QRange, QSpeed, QDelay, QWidth2, myPlayer)
			
				if qpos and qinfo.hitchance >= ZyraMenu.ProdictionSettings.QHitchance then
				prodqposes[1] = qpos.x
				prodqposes[2] = qpos.z
				
					if ZyraMenu.ProdictionSettings.UsePacketsCast then
					Packet('S_CAST', {spellId = _W, toX = qpos.x, toY = qpos.z, fromX = qpos.x, fromY = qpos.z}):send(true)
					else
					CastSpell(_W, qpos.x, qpos.z)
					end
				
					if ZyraMenu.ProdictionSettings.UsePacketsCast then
					Packet('S_CAST', {spellId = _Q, toX = qpos.x, toY = qpos.z, fromX = qpos.x, fromY = qpos.z}):send(true)
					else
					CastSpell(_Q, qpos.x, qpos.z)
					end
				
					if processes[1] ~= nil then
						if ZyraMenu.ProdictionSettings.UsePacketsCast then
						Packet('S_CAST', {spellId = _W, toX = processes[1], toY = processes[3], fromX = processes[1], fromY = processes[3]}):send(true)
						else
						CastSpell(_W, processes[1], processes[3])
						end
					end

				end
				
		elseif QReady and not WReady and not mymanaislowerthen(ZyraMenu.Harass.ManaSliderHarass1) and GetDistance(Target) <= QRange then
				local qpos, qinfo = Prodiction.GetPrediction(Target, QRange, QSpeed, QDelay, QWidth2, myPlayer)
				
				if qpos and qinfo.hitchance >= ZyraMenu.ProdictionSettings.QHitchance then

					if ZyraMenu.ProdictionSettings.UsePacketsCast then
					Packet('S_CAST', {spellId = _Q, toX = qpos.x, toY = qpos.z, fromX = qpos.x, fromY = qpos.z}):send(true)
					else
					CastSpell(_Q, qpos.x, qpos.z)
					end


				end
				
		end
	end 
	
end 

function Harass2()
	if not Target then return end
	
	if ZyraMenu.Harass.Harass2Mode == 1 then
		if QReady and WReady and not mymanaislowerthen(ZyraMenu.Harass.ManaSliderHarass2) and GetDistance(Target) <= QRange then
				local qpos, qinfo = Prodiction.GetPrediction(Target, QRange, QSpeed, QDelay, QWidth2, myPlayer)
			
				if qpos and qinfo.hitchance >= ZyraMenu.ProdictionSettings.QHitchance then
				prodqposes[1] = qpos.x
				prodqposes[2] = qpos.z
					if ZyraMenu.ProdictionSettings.UsePacketsCast then
					Packet('S_CAST', {spellId = _W, toX = qpos.x, toY = qpos.z, fromX = qpos.x, fromY = qpos.z}):send(true)
					else
					CastSpell(_W, qpos.x, qpos.z)
					end
				
					if ZyraMenu.ProdictionSettings.UsePacketsCast then
					Packet('S_CAST', {spellId = _Q, toX = qpos.x, toY = qpos.z, fromX = qpos.x, fromY = qpos.z}):send(true)
					else
					CastSpell(_Q, qpos.x, qpos.z)
					end
				
					if processes[1] ~= nil then
						if ZyraMenu.ProdictionSettings.UsePacketsCast then
						Packet('S_CAST', {spellId = _W, toX = processes[1], toY = processes[3], fromX = processes[1], fromY = processes[3]}):send(true)
						else
						CastSpell(_W, processes[1], processes[3])
						end
					end

				end
			
		end 
	elseif ZyraMenu.Harass.Harass2Mode == 2 then
		if QReady and WReady and not mymanaislowerthen(ZyraMenu.Harass.ManaSliderHarass2) and GetDistance(Target) <= QRange then
				local qpos, qinfo = Prodiction.GetPrediction(Target, QRange, QSpeed, QDelay, QWidth2, myPlayer)
			
				if qpos and qinfo.hitchance >= ZyraMenu.ProdictionSettings.QHitchance then
				prodqposes[1] = qpos.x
				prodqposes[2] = qpos.z
					if ZyraMenu.ProdictionSettings.UsePacketsCast then
					Packet('S_CAST', {spellId = _W, toX = qpos.x, toY = qpos.z, fromX = qpos.x, fromY = qpos.z}):send(true)
					else
					CastSpell(_W, qpos.x, qpos.z)
					end
				
					if ZyraMenu.ProdictionSettings.UsePacketsCast then
					Packet('S_CAST', {spellId = _Q, toX = qpos.x, toY = qpos.z, fromX = qpos.x, fromY = qpos.z}):send(true)
					else
					CastSpell(_Q, qpos.x, qpos.z)
					end
				
					if processes[1] ~= nil then
						if ZyraMenu.ProdictionSettings.UsePacketsCast then
						Packet('S_CAST', {spellId = _W, toX = processes[1], toY = processes[3], fromX = processes[1], fromY = processes[3]}):send(true)
						else
						CastSpell(_W, processes[1], processes[3])
						end
					end

				end
				
		elseif QReady and not WReady and not mymanaislowerthen(ZyraMenu.Harass.ManaSliderHarass2) and GetDistance(Target) <= QRange then
				local qpos, qinfo = Prodiction.GetPrediction(Target, QRange, QSpeed, QDelay, QWidth2, myPlayer)
				
				if qpos and qinfo.hitchance >= ZyraMenu.ProdictionSettings.QHitchance then

					if ZyraMenu.ProdictionSettings.UsePacketsCast then
					Packet('S_CAST', {spellId = _Q, toX = qpos.x, toY = qpos.z, fromX = qpos.x, fromY = qpos.z}):send(true)
					else
					CastSpell(_Q, qpos.x, qpos.z)
					end


				end
				
		end
	end 
	
end 

-- << --  -- << --  -- << --  -- << -- [KS]  -- >> --  -- >> --  -- >> --  -- >> --

function KS()
	for i = 1, heroManager.iCount do
	local enemy = heroManager:getHero(i)
--	
	
		if EReady and QReady and WReady and ZyraMenu.KSOptions.KSwithQ and ZyraMenu.KSOptions.KSwithE then
		
			if GetDistance(Target) <= QRange and myHero.mana >= ManaCost(QE) and not enemy.dead and enemy.health < getDmg("Q",enemy,myHero) + getDmg("E",enemy,myHero) then
				local epos, einfo = Prodiction.GetLineAOEPrediction(Target, QRange, ESpeed, EDelay, EWidth, myPlayer)
				local qpos, qinfo = Prodiction.GetCircularAOEPrediction(Target, QRange, QSpeed, QDelay, QWidth, myPlayer)
				
				if qpos and epos and qinfo.hitchance >= ZyraMenu.ProdictionSettings.QHitchance and einfo.hitchance >= ZyraMenu.ProdictionSettings.EHitchance then
				
					
					if ZyraMenu.ProdictionSettings.UsePacketsCast then
					Packet('S_CAST', {spellId = _Q, toX = qpos.x, toY = qpos.z, fromX = qpos.x, fromY = qpos.z}):send(true)
					else 
					CastSpell(_Q, qpos.x, qpos.z)
					end
					
					if ZyraMenu.ProdictionSettings.UsePacketsCast then
					Packet('S_CAST', {spellId = _W, toX = epos.x, toY = epos.z, fromX = epos.x, fromY = epos.z}):send(true)
					else 
					CastSpell(_W, epos.x, epos.z)
					end	
					
					if ZyraMenu.ProdictionSettings.UsePacketsCast then
					Packet('S_CAST', {spellId = _E, toX = epos.x, toY = epos.z, fromX = epos.x, fromY = epos.z}):send(true)
					else 
					CastSpell(_E, epos.x, epos.z)
					end	
						
					if ZyraMenu.ProdictionSettings.UsePacketsCast then
					Packet('S_CAST', {spellId = _W, toX = epos.x, toY = epos.z, fromX = epos.x, fromY = epos.z}):send(true)
					else 
					CastSpell(_W, epos.x, epos.z)
					end	
					
						
			
				end	
	
			elseif GetDistance(Target) >= QRange and GetDistance(Target) <= ERange and myHero.mana >= ManaCost(E) and not enemy.dead and enemy.health < getDmg("E",enemy,myHero) then
			
				local epos, einfo = Prodiction.GetLineAOEPrediction(Target, ERange, ESpeed, EDelay, EWidth, myPlayer)
				if epos and einfo.hitchance >= ZyraMenu.ProdictionSettings.EHitchance then
					if ZyraMenu.ProdictionSettings.UsePacketsCast then
					Packet('S_CAST', {spellId = _E, toX = epos.x, toY = epos.z, fromX = epos.x, fromY = epos.z}):send(true)
					else 
					CastSpell(_E, epos.x, epos.z)
					end	

				end	

			end

		elseif EReady and not QReady and WReady and ZyraMenu.KSOptions.KSwithE then
		
			if GetDistance(Target) <= WRange  and myHero.mana >= ManaCost(E) and not enemy.dead and enemy.health < getDmg("E",enemy,myHero) then
				local epos, einfo = Prodiction.GetLineAOEPrediction(Target, WRange, ESpeed, EDelay, EWidth, myPlayer)
				
				if epos and einfo.hitchance >= ZyraMenu.ProdictionSettings.EHitchance then
				
					if ZyraMenu.ProdictionSettings.UsePacketsCast then
					Packet('S_CAST', {spellId = _W, toX = epos.x, toY = epos.z, fromX = epos.x, fromY = epos.z}):send(true)
					else 
					CastSpell(_W, epos.x, epos.z)
					end				
					if ZyraMenu.ProdictionSettings.UsePacketsCast then
					Packet('S_CAST', {spellId = _E, toX = epos.x, toY = epos.z, fromX = epos.x, fromY = epos.z}):send(true)
					else 
					CastSpell(_E, epos.x, epos.z)
					end				
					if ZyraMenu.ProdictionSettings.UsePacketsCast then
					Packet('S_CAST', {spellId = _W, toX = epos.x, toY = epos.z, fromX = epos.x, fromY = epos.z}):send(true)
					else 
					CastSpell(_W, epos.x, epos.z)
					end		

				end	

			elseif GetDistance(Target) >= WRange and GetDistance(Target) <= ERange and myHero.mana >= ManaCost(E) and not enemy.dead and enemy.health < getDmg("E",enemy,myHero) then
				local epos, einfo = Prodiction.GetLineAOEPrediction(Target, ERange, ESpeed, EDelay, EWidth, myPlayer)
				if epos and einfo.hitchance >= ZyraMenu.ProdictionSettings.EHitchance then
					if ZyraMenu.ProdictionSettings.UsePacketsCast then
					Packet('S_CAST', {spellId = _E, toX = epos.x, toY = epos.z, fromX = epos.x, fromY = epos.z}):send(true)
					else 
					CastSpell(_E, epos.x, epos.z)
					end	

				end	

			end 
			
		elseif EReady and QReady and not WReady and ZyraMenu.KSOptions.KSwithQ and ZyraMenu.KSOptions.KSwithE then
		
			if GetDistance(Target) <= QRange and myHero.mana >= ManaCost(QE) and not enemy.dead and enemy.health < getDmg("Q",enemy,myHero) + getDmg("E",enemy,myHero) then
				local epos, einfo = Prodiction.GetLineAOEPrediction(Target, QRange, ESpeed, EDelay, EWidth, myPlayer)
				local qpos, qinfo = Prodiction.GetCircularAOEPrediction(Target, QRange, QSpeed, QDelay, QWidth, myPlayer)
				
				if qpos and epos and qinfo.hitchance >= ZyraMenu.ProdictionSettings.QHitchance and einfo.hitchance >= ZyraMenu.ProdictionSettings.EHitchance then
								
					if ZyraMenu.ProdictionSettings.UsePacketsCast then
					Packet('S_CAST', {spellId = _E, toX = epos.x, toY = epos.z, fromX = epos.x, fromY = epos.z}):send(true)
					else 
					CastSpell(_E, epos.x, epos.z)
					end	
									
					if ZyraMenu.ProdictionSettings.UsePacketsCast then
					Packet('S_CAST', {spellId = _Q, toX = qpos.x, toY = qpos.z, fromX = qpos.x, fromY = qpos.z}):send(true)
					else 
					CastSpell(_Q, qpos.x, qpos.z)
					end

				end	

				
			elseif GetDistance(Target) >= QRange and GetDistance(Target) <= ERange and myHero.mana >= ManaCost(E) and not enemy.dead and enemy.health < getDmg("E",enemy,myHero) then
				local epos, einfo = Prodiction.GetLineAOEPrediction(Target, ERange, ESpeed, EDelay, EWidth, myPlayer)
				if epos and einfo.hitchance >= ZyraMenu.ProdictionSettings.EHitchance then
					if ZyraMenu.ProdictionSettings.UsePacketsCast then
					Packet('S_CAST', {spellId = _E, toX = epos.x, toY = epos.z, fromX = epos.x, fromY = epos.z}):send(true)
					else 
					CastSpell(_E, epos.x, epos.z)
					end	

				end	

			end 
		elseif EReady and not QReady and not WReady and myHero.mana >= ManaCost(E) and ZyraMenu.KSOptions.KSwithE and not enemy.dead and enemy.health < getDmg("E",enemy,myHero) then
			local epos, einfo = Prodiction.GetLineAOEPrediction(Target, ERange, ESpeed, EDelay, EWidth, myPlayer)
			if epos and einfo.hitchance >= ZyraMenu.ProdictionSettings.EHitchance then
				if ZyraMenu.ProdictionSettings.UsePacketsCast then
				Packet('S_CAST', {spellId = _E, toX = epos.x, toY = epos.z, fromX = epos.x, fromY = epos.z}):send(true)
				else 
				CastSpell(_E, epos.x, epos.z)
				end	

			end	

		
		elseif not EReady and QReady and WReady and myHero.mana >= ManaCost(Q) and ZyraMenu.KSOptions.KSwithQ and not enemy.dead and enemy.health < getDmg("Q",enemy,myHero) then
			local qpos, qinfo = Prodiction.GetCircularAOEPrediction(Target, QRange, QSpeed, QDelay, QWidth, myPlayer)
			
			if qpos and qinfo.hitchance >= ZyraMenu.ProdictionSettings.QHitchance then
							
								
				if ZyraMenu.ProdictionSettings.UsePacketsCast then
				Packet('S_CAST', {spellId = _W, toX = qpos.x, toY = qpos.z, fromX = qpos.x, fromY = qpos.z}):send(true)
				else 
				CastSpell(_W, qpos.x, qpos.z)
				end		
				
				if ZyraMenu.ProdictionSettings.UsePacketsCast then
				Packet('S_CAST', {spellId = _Q, toX = qpos.x, toY = qpos.z, fromX = qpos.x, fromY = qpos.z}):send(true)
				else 
				CastSpell(_Q, qpos.x, qpos.z)
				end
				
				if ZyraMenu.ProdictionSettings.UsePacketsCast then
				Packet('S_CAST', {spellId = _W, toX = qpos.x, toY = qpos.z, fromX = qpos.x, fromY = qpos.z}):send(true)
				else 
				CastSpell(_W, qpos.x, qpos.z)
				end	

			end	

		elseif not EReady and QReady and not WReady and myHero.mana >= ManaCost(Q) and ZyraMenu.KSOptions.KSwithQ and not enemy.dead and enemy.health < getDmg("Q",enemy,myHero) then
			local qpos, qinfo = Prodiction.GetCircularAOEPrediction(Target, QRange, QSpeed, QDelay, QWidth, myPlayer)
			
			if qpos and qinfo.hitchance >= ZyraMenu.ProdictionSettings.QHitchance then

				if ZyraMenu.ProdictionSettings.UsePacketsCast then
				Packet('S_CAST', {spellId = _Q, toX = qpos.x, toY = qpos.z, fromX = qpos.x, fromY = qpos.z}):send(true)
				else 
				CastSpell(_Q, qpos.x, qpos.z)
				end
				

			end	

		end
--

end
end
 -- << --  -- << --  -- << --  -- << -- [OrbWalker]  -- >> --  -- >> --  -- >> --  -- >> --
 
function OrbWalk()
	if ZyraMenu.Orbwalk then
	myTarget = ts.target
	if myTarget ~= nil and GetDistance(myTarget) <= myTrueRange then
		if timeToShoot() then
			myHero:Attack(myTarget)
		elseif heroCanMove() then
			moveToCursor()
		end
	else		
		moveToCursor() 
	end
	end
end

function heroCanMove()
	return ( GetTickCount() + GetLatency() / 2 > lastAttack + lastWindUpTime + 20 )
end 
 
function timeToShoot()
	return ( GetTickCount() + GetLatency() / 2 > lastAttack + lastAttackCD )
end 
 
function moveToCursor()
	if GetDistance(mousePos) > 100 and GetDistance(mousePos) > 1 or lastAnimation == "Idle1" then
		local moveToPos = myHero + (Vector(mousePos) - myHero):normalized() * 250
		myHero:MoveTo(moveToPos.x, moveToPos.z)
	end 
end

 -- << --  -- << --  -- << --  -- << -- [Ult]  -- >> --  -- >> --  -- >> --  -- >> --

 function UltGroup(manual)
	if not Target then return false end

	if not manual and EnemyCount(myHero, (RRange + RRadius)) < ZyraMenu.Ultimate.UltGroupMinimum then return false end

	local spellPos = GetAoESpellPosition(RRadius, Target, RDelay * 1000)

	if spellPos and GetDistance(spellPos) <= RRange then
		if manual or EnemyCount(spellPos, RRadius) >= ZyraMenu.Ultimate.UltGroupMinimum then

			CastSpell(_R, spellPos.x, spellPos.z)
			return true
		end
	end

	return false
end

function EnemyCount(point, range)
	local count = 0

	for _, enemy in pairs(GetEnemyHeroes()) do
		if enemy and not enemy.dead and GetDistance(point, enemy) <= range then
			count = count + 1
		end
	end            

	return count
end

function GetAoESpellPosition(radius, main_target, delay)
	local targets = delay and GetPredictedInitialTargets(radius, main_target, delay) or GetInitialTargets(radius, main_target)
	local position = GetCenter(targets)
	local best_pos_found = true
	local circle = Circle(position, radius)
	circle.center = position
	
	if #targets > 2 then best_pos_found = ContainsThemAll(circle, targets) end
	
	while not best_pos_found do
		targets = RemoveWorst(targets, position)
		position = GetCenter(targets)
		circle.center = position
		best_pos_found = ContainsThemAll(circle, targets)
	end
	
	return position
end

function GetPredictedInitialTargets(radius, main_target, delay)
	if VIP_USER and not vip_target_predictor then vip_target_predictor = TargetPredictionVIP(nil, nil, delay/1000) end
	local predicted_main_target = VIP_USER and vip_target_predictor:GetPrediction(main_target) or GetPredictionPos(main_target, delay)
	local predicted_targets = {predicted_main_target}
	local diameter_sqr = 4 * radius * radius
	
	for i=1, heroManager.iCount do
		target = heroManager:GetHero(i)
		if ValidTarget(target) then
			predicted_target = VIP_USER and vip_target_predictor:GetPrediction(target) or GetPredictionPos(target, delay)
			if target.networkID ~= main_target.networkID and GetDistanceSqr(predicted_main_target, predicted_target) < diameter_sqr then table.insert(predicted_targets, predicted_target) end
		end
	end
	
	return predicted_targets
end


function GetCenter(points)
	local sum_x = 0
	local sum_z = 0
	
	for i = 1, #points do
		sum_x = sum_x + points[i].x
		sum_z = sum_z + points[i].z
	end
	
	local center = {x = sum_x / #points, y = 0, z = sum_z / #points}
	
	return center
end
function ContainsThemAll(circle, points)
	local radius_sqr = circle.radius*circle.radius
	local contains_them_all = true
	local i = 1
	
	while contains_them_all and i <= #points do
		contains_them_all = GetDistanceSqr(points[i], circle.center) <= radius_sqr
		i = i + 1
	end
	
	return contains_them_all
end

function RemoveWorst(targets, position)
	local worst_target = FarthestFromPositionIndex(targets, position)
	
	table.remove(targets, worst_target)
	
	return targets
end

function FarthestFromPositionIndex(points, position)
	local index = 2
	local actual_dist_sqr
	local max_dist_sqr = GetDistanceSqr(points[index], position)
	
	for i = 3, #points do
		actual_dist_sqr = GetDistanceSqr(points[i], position)
		if actual_dist_sqr > max_dist_sqr then
			index = i
			max_dist_sqr = actual_dist_sqr
		end
	end
	
	return index
end

-- << --  -- << --  -- << --  -- << -- [Double Q fix]  -- >> --  -- >> --  -- >> --  -- >> --
function OnProcessSpell(unit, spell)


if unit.isMe and spell.name == "ZyraQFissure" then
	CastingQ = true
	processes[1] = spell.endPos.x
	processes[2] = spell.endPos.y
	processes[3] = spell.endPos.z
	
		if ZyraMenu.ProdictionSettings.UsePacketsCast then
		Packet('S_CAST', {spellId = _W, toX = spell.endPos.x, toY = spell.endPos.z, fromX = spell.endPos.x, fromY = spell.endPos.z}):send(true)
		else 
		CastSpell(_W, spell.endPos.x, spell.endPos.z)
		end

	
		if prodqposes[1] ~= nil then
			if ZyraMenu.ProdictionSettings.UsePacketsCast then
			Packet('S_CAST', {spellId = _W, toX = prodqposes[1], toY = prodqposes[2], fromX = prodqposes[1], fromY = prodqposes[2]}):send(true)
			else 
			CastSpell(_W, prodqposes[1], prodqposes[2])
			end
			
		end
		
end

	
	if unit.isMe and not spell.name == "ZyraQFissure" then
	CastingQ = false
	end

	
	-- Orbwalker
	if unit == myHero then
		--print(""..spell.name.."")
		if spell.name:lower():find("attack") then
			lastAttack = GetTickCount() - GetLatency() / 2
			lastWindUpTime = spell.windUpTime * 1000
			lastAttackCD = spell.animationTime * 1000
		end 
	end
--

	
end 
-- << --  -- << --  -- << --  -- << -- [MANA]  -- >> --  -- >> --  -- >> --  -- >> --
 
function mymanaislowerthen(percent)
    if myHero.mana < (myHero.maxMana * ( percent / 100)) then
        return true
    else
        return false
    end
end

function ManaCost(spell)
	if spell == Q then
		return 70 + (5 * myHero:GetSpellData(_Q).level)
	elseif spell == E then
		return 65 + (5 * myHero:GetSpellData(_E).level)
	elseif spell == R then
		return 80 + (20 * myHero:GetSpellData(_R).level)
	elseif spell == QER then
		return 70 + (5 * myHero:GetSpellData(_Q).level) + 65 + (5 * myHero:GetSpellData(_E).level) + 80 + (20 * myHero:GetSpellData(_R).level)
	elseif spell == QE then
		return 70 + (5 * myHero:GetSpellData(_Q).level) + 65 + (5 * myHero:GetSpellData(_E).level)
	elseif spell == QR then
		return 70 + (5 * myHero:GetSpellData(_Q).level) + 80 + (20 * myHero:GetSpellData(_R).level)
	elseif spell == ER then
		return 65 + (5 * myHero:GetSpellData(_E).level) + 80 + (20 * myHero:GetSpellData(_R).level)
	end
end		
function OnDraw()
	
	if QReady then
	if ZyraMenu.draws.DrawQ then
	DrawCircle3D(myHero.x, myHero.y, myHero.z, 740, 1, ARGB(60,23,190,23))
	end
	end
	if EReady then
	if ZyraMenu.draws.DrawE then
	DrawCircle3D(myHero.x, myHero.y, myHero.z, 820, 1, ARGB(60,23,190,23))
	end
	end
	
end
