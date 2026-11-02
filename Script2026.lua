local Rayfield=loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local P=game:GetService("Players") local RS=game:GetService("ReplicatedStorage")
local RUN=game:GetService("RunService")
local pl=P.LocalPlayer local ch=pl.Character or pl.CharacterAdded:Wait()
local hrp=ch:WaitForChild("HumanoidRootPart") local hum=ch:WaitForChild("Humanoid")
local R=RS:WaitForChild("Remotes") local CF=R:WaitForChild("CommF_")
local N=RS:WaitForChild("Modules"):WaitForChild("Net")
local RA=N:WaitForChild("RE/RegisterAttack") local RH=N:WaitForChild("RE/RegisterHit")

local AR,SR,ACD=60,800,0.05
local S1,S2,SPD=5,20,150
local FH,QH,MCI,KT=10,1,2.0,30
local PROG_TIMEOUT=120
local NOENEMY_TIMEOUT=90
local ka,af=false,false
local curQuest=nil

local Q={
{1,9,"Bandit","BanditQuest1",1,CFrame.new(1053.52,14.69,1556.72),CFrame.new(1038,41,1576)},
{10,14,"Monkey","JungleQuest",1,CFrame.new(-1601.9,36.8,153.4),CFrame.new(-1448,50,63)},
{15,29,"Gorilla","JungleQuest",2,CFrame.new(-1601.9,36.8,153.4),CFrame.new(-1136,40,-520)},
{30,39,"Pirate","PirateQuest",1,CFrame.new(-1138.4,4.4,1433.2),CFrame.new(-1094,8,1458)},
{40,59,"Brute","BruteQuest",1,CFrame.new(-1138.4,4.4,1433.2),CFrame.new(-1120,8,1458)},
{60,74,"Desert Bandit","DesertQuest",1,CFrame.new(894.2,5.9,1451.7),CFrame.new(928,5,1477)},
{75,89,"Desert Officer","DesertQuest",2,CFrame.new(894.2,5.9,1451.7),CFrame.new(1101,5,1395)},
{90,104,"Snow Bandit","SnowQuest",1,CFrame.new(1384.3,87.1,-1298.1),CFrame.new(1248,87,-1387)},
{105,119,"Snowman","SnowQuest",2,CFrame.new(1384.3,87.1,-1298.1),CFrame.new(1160,87,-1440)},
{120,149,"Marine","MarineQuest",1,CFrame.new(-2370.8,72.1,-163.4),CFrame.new(-2240,72,-200)},
{150,189,"Sky Bandit","SkyQuest",1,CFrame.new(-4841.3,717.8,-843.2),CFrame.new(-4700,717,-900)},
{190,249,"Prisoner","PrisonQuest",1,CFrame.new(5310.6,22.5,475.1),CFrame.new(5400,22,500)},
{250,299,"Gladiator","ColosseumQuest",1,CFrame.new(-1395.8,16.1,-1668.9),CFrame.new(-1450,16,-1700)}}

local function LV() local o,v=pcall(function() return pl.Data.Level.Value end) return o and type(v)=="number" and v or 1 end
local function GQ() local l=LV() for _,q in ipairs(Q) do if l>=q[1] and l<=q[2] then return{min=q[1],max=q[2],enemy=q[3],questName=q[4],questNo=q[5],qCF=q[6],spawnCF=q[7]} end end local q=Q[#Q] return{min=q[1],max=q[2],enemy=q[3],questName=q[4],questNo=q[5],qCF=q[6],spawnCF=q[7]} end

local aqC,aqT=nil,0
local function AQ()
    local now=tick()
    if aqC and now-aqT<1 then return aqC end
    local o,r=pcall(function() return CF:InvokeServer("getActiveQuests") end)
    aqC=o and r or nil aqT=now
    return aqC
end
local function FA(qn,qno)
    local r=AQ() if type(r)~="table" then return nil end
    for _,a in pairs(r) do
        if type(a)=="table" then
            local n=a.Quest or a.Name
            local no=a.QuestNo or a.Number or a.QuestId
            if n==qn and tonumber(no)==tonumber(qno) then return a end
        end
    end
    return nil
end
local function QProg(qn,qno)
    local a=FA(qn,qno) if not a then return nil end
    local p=tonumber(a.Progress or a.progress or a.Current or 0) or 0
    local r=tonumber(a.Requirement or a.requirement or a.Target or 0) or 0
    return p,r
end
local function IsC(qn,qno)
    local p,r=QProg(qn,qno) if not p or not r then return false end
    return r>0 and p>=r
end

local bp
local function Hov()
    if not ch or not ch.Parent then return end
    if not bp or not bp.Parent or bp.Parent~=hrp then
        if bp then bp:Destroy() end
        bp=Instance.new("BodyPosition") bp.Name="KarpaHover" bp.P=12000 bp.D=700
        bp.MaxForce=Vector3.new(1e7,1e7,1e7) bp.Position=hrp.Position bp.Parent=hrp
    end
    hum.PlatformStand=true
end
local function StopH() if bp then bp:Destroy() bp=nil end if hum then hum.PlatformStand=false pcall(function() hum:ChangeState(Enum.HumanoidStateType.GettingUp) end) end end

local occ,nc={},nil
local function NCstart() if nc then return end nc=RUN.Stepped:Connect(function() if not ch or not ch.Parent then return end for _,p in pairs(ch:GetDescendants()) do if p:IsA("BasePart") and p.CanCollide then if occ[p]==nil then occ[p]=p.CanCollide end p.CanCollide=false end end end) end
local function NCstop() if nc then nc:Disconnect() nc=nil end for p,c in pairs(occ) do if p and p.Parent then p.CanCollide=c end end occ={} end

local function Fly(t)
    Hov() if not bp then return end
    hum.PlatformStand=true
    local s=bp.Position local d=(s-t).Magnitude
    if d<0.5 then bp.Position=t return end
    local du=math.max(d/SPD,0.15) local t0=tick()
    while af do
        local a=math.min((tick()-t0)/du,1)
        if not bp then return end
        bp.Position=s:Lerp(t,a)
        if a>=1 then break end
        RUN.Heartbeat:Wait()
    end
    if bp then bp.Position=t end
end

local qc={}
local function QG(nc0,k) if qc[k] and qc[k].Parent then return qc[k] end local b,bd=nil,math.huge for _,o in pairs(workspace:GetDescendants()) do if o:IsA("Model") and o:FindFirstChild("Humanoid") then local h=o:FindFirstChild("HumanoidRootPart") or o:FindFirstChild("Head") if h then local d=(h.Position-nc0.Position).Magnitude if d<150 then local n=o.Name:lower() local bn=0 if n:find("quest") or n:find("giver") or n:find("adventurer") then bn=-1000 end if o:FindFirstChildWhichIsA("ProximityPrompt",true) then bn=bn-500 end if d+bn<bd then b=o bd=d+bn end end end end end if b then qc[k]=b end return b end

local function Acc(q) pcall(function() CF:InvokeServer("StartQuest",q.questName,q.questNo) end) aqC=nil task.wait(0.6) end
local function Comp(q) pcall(function() CF:InvokeServer("CompleteQuest") end) aqC=nil task.wait(0.8) end

local MN={"Combat","Black Leg","Electro","Fishman Karate","Superhuman","Death Step","Sharkman Karate","Dragon Talon","Godhuman","Sanguine Art","Electric Claw","Dragons Breath"}
local function IsM(n) for _,v in ipairs(MN) do if n:find(v) then return true end end end
local function hasMelee() if not ch then return false end for _,t in pairs(ch:GetChildren()) do if t:IsA("Tool") and IsM(t.Name) then return true end end return false end
local function FM() for _,t in pairs(pl.Backpack:GetChildren()) do if t:IsA("Tool") and IsM(t.Name) then return t end end for _,t in pairs(pl.Backpack:GetChildren()) do if t:IsA("Tool") and not t.Name:find("Fruit") and not t.Name:find("Sword") and not t.Name:find("Gun") and not t.Name:find("Accessory") and not t.Name:find("Cursed") then return t end end end
local function EM()
    if not ch then return end
    if hasMelee() then hum.PlatformStand=true return true end
    local t=FM() if not t then return false end
    for i=1,3 do
        pcall(function() hum:EquipTool(t) end) task.wait(0.25)
        local e=t:FindFirstChild("EquipEvent")
        if not e then local eq=ch:FindFirstChild(t.Name) if eq then e=eq:FindFirstChild("EquipEvent") end end
        if e then pcall(function() e:FireServer() end) task.wait(0.2) if t.Parent==ch then hum.PlatformStand=true return true end end
        task.wait(0.2)
    end
    return false
end

-- 🎯 NM robusto: aceita [Lv. 20], [Lv 20], [Lv20], (Lv. 20), Lv. 20, -Lv. 20; case-insensitive
local function NM(modelName,target)
    if target=="" then return true end
    local tl=target:lower()
    local mn=modelName:lower()
    mn=mn:gsub("%s*%[%s*lv%.?%s*%d+%s*%]","")
    mn=mn:gsub("%s*%(%s*lv%.?%s*%d+%s*%)","")
    mn=mn:gsub("%s*[-_]%s*lv%.?%s*%d+$","")
    mn=mn:gsub("%s+lv%.?%s*%d+$","")
    mn=mn:gsub("^%s+",""):gsub("%s+$","")
    return mn==tl
end

local function NE(n,d) d=d or AR if not hrp or not hrp.Parent then return end
    local ps={}
    local ef=workspace:FindFirstChild("Enemies")
    local nf=workspace:FindFirstChild("NPCs")
    if ef then table.insert(ps,ef) end
    if nf then table.insert(ps,nf) end
    if #ps==0 then table.insert(ps,workspace) end
    local nr,s=nil,d
    for _,p in ipairs(ps) do
        for _,e in pairs(p:GetChildren()) do
            if e:IsA("Model") and NM(e.Name,n) and e~=ch and not P:GetPlayerFromCharacter(e) then
                local h=e:FindFirstChild("HumanoidRootPart")
                local hu=e:FindFirstChild("Humanoid")
                if h and hu and hu.Health>0 then
                    local dd=(hrp.Position-h.Position).Magnitude
                    if dd<s then s=dd nr=h end
                end
            end
        end
    end
    return nr
end

-- 🔍 Debug: lista inimigos no F9 para você conferir nomes reais
local lastDbg=0
local function Dbg(n)
    if tick()-lastDbg<30 then return end
    lastDbg=tick()
    local ef=workspace:FindFirstChild("Enemies")
    local names={}
    if ef then
        for _,e in pairs(ef:GetChildren()) do
            if e:IsA("Model") and e:FindFirstChild("Humanoid") and e.Humanoid.Health>0 then
                table.insert(names,e.Name)
            end
        end
    end
    warn("[Karpa Debug] Procurando '"..n.."'. Inimigos no servidor: "..(#names>0 and table.concat(names,", ") or "NENHUM"))
end

local lastAtk=0
local function Atk(t)
    if not t or not t.Parent then return end
    local now=tick()
    if now-lastAtk<ACD*0.9 then return end
    lastAtk=now
    pcall(function()
        RA:FireServer(math.random(S1,S2))
        RH:FireServer(t,{},nil,tostring(math.random(100000,999999)))
    end)
end

task.spawn(function() while true do task.wait(ACD) if ka then local t=NE("",AR) if t then Atk(t) end end end end)

task.spawn(function()
    while true do
        task.wait(1)
        if af and ch and ch.Parent and hum and hum.Parent then
            if not bp or not bp.Parent or bp.Parent~=hrp then pcall(Hov) end
            hum.PlatformStand=true
        end
    end
end)

task.spawn(function()
    while true do
        task.wait(1)
        if not af then curQuest=nil continue end
        if not ch or not hum or hum.Health<=0 then task.wait(2) continue end
        Hov()

        local q=GQ() if not q then task.wait(2) continue end
        local qk=q.questName..":"..q.questNo
        if curQuest and curQuest.key~=qk then curQuest=nil end

        local nm=QG(q.qCF,q.enemy)
        local focus=nm and(nm:FindFirstChild("HumanoidRootPart") or nm:FindFirstChild("Head")) or nil
        local npcPos=(focus and focus.Position or q.qCF.Position)+Vector3.new(0,QH,0)

        if not curQuest then
            local active=FA(q.questName,q.questNo)
            if not active then
                Fly(npcPos)
                Acc(q)
                Rayfield:Notify({Title="Quest",Content="Aceita: "..q.questName,Duration=2})
                task.wait(1)
            end
            curQuest={key=qk,questName=q.questName,questNo=q.questNo,lastProg=-1,lastProgTime=tick()}
            -- 🛠️ FIX: voa direto pro spawn se não houver inimigo por perto
            if q.spawnCF and not NE(q.enemy,SR) then
                Fly(q.spawnCF.Position+Vector3.new(0,FH,0))
            end
        end

        if IsC(q.questName,q.questNo) then
            Fly(npcPos) Comp(q)
            Rayfield:Notify({Title="Quest",Content="Completa: "..q.questName,Duration=2})
            curQuest=nil task.wait(1.5) continue
        end

        EM()
        local sl=LV() local lm=tick() local noEnemyStart=nil

        while af do
            if not ch or not hum or hum.Health<=0 then break end
            if LV()~=sl then break end

            local p,r=QProg(q.questName,q.questNo)
            if p and r then
                if p~=curQuest.lastProg then
                    curQuest.lastProg=p curQuest.lastProgTime=tick()
                end
                if r>0 and p>=r then break end
            else
                if tick()-curQuest.lastProgTime>PROG_TIMEOUT then curQuest=nil break end
            end

            if tick()-lm>=MCI then if not hasMelee() then EM() end lm=tick() end

            local t=NE(q.enemy,SR)
            if not t then
                Dbg(q.enemy)  -- 🔍 warn no F9
                if not noEnemyStart then noEnemyStart=tick() end
                if tick()-noEnemyStart>NOENEMY_TIMEOUT and q.spawnCF then
                    Fly(q.spawnCF.Position+Vector3.new(0,FH,0))
                    noEnemyStart=tick()
                end
                task.wait(2) continue
            end
            noEnemyStart=nil

            Fly(t.Position+Vector3.new(0,FH,0))
            local hu=t.Parent and t.Parent:FindFirstChild("Humanoid")
            local ks=tick()
            while af and hu and hu.Parent and hu.Health>0 do
                if not ch or not hum or hum.Health<=0 then break end
                if tick()-ks>KT then break end
                if bp and t and t.Parent then bp.Position=t.Position+Vector3.new(0,FH,0) end
                if tick()-lm>=MCI then if not hasMelee() then EM() end lm=tick() end
                Atk(t) task.wait(ACD)
            end
            task.wait(0.1)
        end
        task.wait(0.5)
    end
end)

local W=Rayfield:CreateWindow({Name="Karpa Hub | Blox Fruits",LoadingTitle="Karpa Hub",LoadingSubtitle="Kill Aura + Auto Farm",ConfigurationSaving={Enabled=false},KeySystem=false})

local KT1=W:CreateTab("Kill Aura",4483362458)
KT1:CreateToggle({Name="Kill Aura",CurrentValue=false,Flag="kaT",Callback=function(v) ka=v end})
KT1:CreateSlider({Name="Attack Range",Range={10,150},Increment=5,Suffix="studs",CurrentValue=AR,Flag="AR",Callback=function(v) AR=v end})
KT1:CreateSlider({Name="Attack Cooldown",Range={0.02,0.2},Increment=0.01,Suffix="s",CurrentValue=ACD,Flag="ACD",Callback=function(v) ACD=v end})
KT1:CreateSection("Keybind")
KT1:CreateKeybind({Name="Toggle Kill Aura",CurrentKeybind="K",HoldToInteract=false,Flag="kaK",Callback=function() ka=not ka Rayfield:Notify({Title="Kill Aura",Content=ka and "ON" or "OFF",Duration=2}) end})

local FT=W:CreateTab("Auto Farm",4483362458)
local function tog(v) af=v if v then Hov() NCstart() else StopH() NCstop() curQuest=nil end Rayfield:Notify({Title="Auto Farm",Content=v and "ON (Noclip)" or "OFF",Duration=2}) end
FT:CreateToggle({Name="Auto Farm",CurrentValue=false,Flag="afT",Callback=tog})
FT:CreateSlider({Name="Fly Speed",Range={50,400},Increment=10,Suffix="studs/s",CurrentValue=SPD,Flag="SPD",Callback=function(v) SPD=v end})
FT:CreateSlider({Name="Hover Height",Range={5,20},Increment=1,Suffix="studs",CurrentValue=FH,Flag="FH",Callback=function(v) FH=v end})
FT:CreateSlider({Name="Search Range",Range={200,1500},Increment=50,Suffix="studs",CurrentValue=SR,Flag="SR",Callback=function(v) SR=v end})
FT:CreateSection("Keybind")
FT:CreateKeybind({Name="Toggle Auto Farm",CurrentKeybind="F",HoldToInteract=false,Flag="afK",Callback=function() tog(not af) end})

Rayfield:Notify({Title="Karpa Hub",Content="Carregado",Duration=3})

pl.CharacterAdded:Connect(function(c) ch=c hrp=c:WaitForChild("HumanoidRootPart") hum=c:WaitForChild("Humanoid") occ={} aqC=nil curQuest=nil if bp then bp:Destroy() bp=nil end if af then task.wait(1) Hov() NCstart() EM() end end)