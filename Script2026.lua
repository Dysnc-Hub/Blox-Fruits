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
local FH,QH,MCI,NEG,KT=10,1,2.0,15,30
local ka,af=false,false

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

local function AQ() local o,r=pcall(function() return CF:InvokeServer("getActiveQuests") end) if o and type(r)=="table" then for _,q in pairs(r) do if type(q)=="table" and(q.Quest or q.Name) then return q end end end end
local function IsA(qn,qno) local a=AQ() if not a then return false end return(a.Quest or a.Name)==qn and(a.QuestNo or a.Number or a.QuestId)==qno end
local function IsC(qn,qno) local a=AQ() if not a then return false end local n=a.Quest or a.Name local no=a.QuestNo or a.Number or a.QuestId if n~=qn or no~=qno then return false end local p=a.Progress or a.progress or a.Current or 0 local r=a.Requirement or a.requirement or a.Target or 0 return r>0 and p>=r end

local bp
-- 🛠️ FIX: sempre seta PlatformStand=true, não retorna cedo
local function Hov() 
    if not ch or not ch.Parent then return end 
    if not bp or not bp.Parent or bp.Parent~=hrp then 
        if bp then bp:Destroy() end 
        bp=Instance.new("BodyPosition") 
        bp.Name="KarpaHover"
        bp.P=12000 
        bp.D=700 
        bp.MaxForce=Vector3.new(1e7,1e7,1e7) 
        bp.Position=hrp.Position 
        bp.Parent=hrp 
    end 
    hum.PlatformStand=true 
end
local function StopH() if bp then bp:Destroy() bp=nil end if hum then hum.PlatformStand=false pcall(function() hum:ChangeState(Enum.HumanoidStateType.GettingUp) end) end end

local occ,nc={},nil
local function NCstart() if nc then return end nc=RUN.Stepped:Connect(function() if not ch or not ch.Parent then return end for _,p in pairs(ch:GetDescendants()) do if p:IsA("BasePart") and p.CanCollide then if occ[p]==nil then occ[p]=p.CanCollide end p.CanCollide=false end end end) end
local function NCstop() if nc then nc:Disconnect() nc=nil end for p,c in pairs(occ) do if p and p.Parent then p.CanCollide=c end end occ={} end

local function Fly(t)
    Hov()
    if not bp then return end
    hum.PlatformStand=true
    local s=bp.Position
    local d=(s-t).Magnitude
    if d<0.5 then bp.Position=t return end
    local du=math.max(d/SPD,0.15)
    local t0=tick()
    while af do
        local el=tick()-t0
        local a=math.min(el/du,1)
        if not bp then return end
        bp.Position=s:Lerp(t,a)
        if a>=1 then break end
        RUN.Heartbeat:Wait()
    end
    if bp then bp.Position=t end
end

local qc={}
local function QG(nc0,k) if qc[k] and qc[k].Parent then return qc[k] end local b,bd=nil,math.huge for _,o in pairs(workspace:GetDescendants()) do if o:IsA("Model") and o:FindFirstChild("Humanoid") then local h=o:FindFirstChild("HumanoidRootPart") or o:FindFirstChild("Head") if h then local d=(h.Position-nc0.Position).Magnitude if d<150 then local n=o.Name:lower() local bn=0 if n:find("quest") or n:find("giver") or n:find("adventurer") then bn=-1000 end if o:FindFirstChildWhichIsA("ProximityPrompt",true) then bn=bn-500 end if d+bn<bd then b=o bd=d+bn end end end end end if b then qc[k]=b end return b end

local function Acc(q) pcall(function() CF:InvokeServer("StartQuest",q.questName,q.questNo) end) task.wait(0.6) end
local function Comp(q) pcall(function() CF:InvokeServer("CompleteQuest") end) task.wait(0.8) end

local MN={"Combat","Black Leg","Electro","Fishman Karate","Superhuman","Death Step","Sharkman Karate","Dragon Talon","Godhuman","Sanguine Art","Electric Claw","Dragons Breath"}
local function IsM(n) for _,v in ipairs(MN) do if n:find(v) then return true end end end
local function FM() for _,t in pairs(pl.Backpack:GetChildren()) do if t:IsA("Tool") and IsM(t.Name) then return t end end for _,t in pairs(pl.Backpack:GetChildren()) do if t:IsA("Tool") and not t.Name:find("Fruit") and not t.Name:find("Sword") and not t.Name:find("Gun") and not t.Name:find("Accessory") and not t.Name:find("Cursed") then return t end end end

-- 🛠️ FIX: após equipar, restaura PlatformStand
local function EM() 
    if not ch then return end 
    for _,t in pairs(ch:GetChildren()) do 
        if t:IsA("Tool") and IsM(t.Name) then 
            hum.PlatformStand=true 
            return true 
        end 
    end 
    local t=FM() 
    if not t then return false end 
    for i=1,3 do 
        pcall(function() hum:EquipTool(t) end) 
        task.wait(0.25) 
        local e=t:FindFirstChild("EquipEvent") 
        if not e then 
            local eq=ch:FindFirstChild(t.Name) 
            if eq then e=eq:FindFirstChild("EquipEvent") end 
        end 
        if e then 
            pcall(function() e:FireServer() end) 
            task.wait(0.2) 
            if t.Parent==ch then 
                hum.PlatformStand=true 
                return true 
            end 
        end 
        task.wait(0.2) 
    end 
    return false 
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
            if e:IsA("Model") and(n=="" or e.Name:find(n)) and e~=ch and not P:GetPlayerFromCharacter(e) then
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

local function Atk(t) if not t or not t.Parent then return end pcall(function() RA:FireServer(math.random(S1,S2)) RH:FireServer(t,{},nil,tostring(math.random(100000,999999))) end) end

task.spawn(function() while true do task.wait(ACD) if ka then local t=NE("",AR) if t then Atk(t) end end end end)

-- 🛠️ GUARDIÃO: reafirma PlatformStand a cada 1s enquanto af ligado
task.spawn(function()
    while true do
        task.wait(1)
        if af and ch and ch.Parent and hum and hum.Parent then
            if not bp or not bp.Parent or bp.Parent~=hrp then pcall(Hov) end
            hum.PlatformStand=true
        end
    end
end)

task.spawn(function() while true do task.wait(1) if not af then continue end if not ch or not hum or hum.Health<=0 then task.wait(2) continue end Hov() local q=GQ() if not q then task.wait(2) continue end local nm=QG(q.qCF,q.enemy) local focus=nm and(nm:FindFirstChild("HumanoidRootPart") or nm:FindFirstChild("Head")) or nil

if not IsA(q.questName,q.questNo) then Fly((focus and focus.Position or q.qCF.Position)+Vector3.new(0,QH,0)) Acc(q) Rayfield:Notify({Title="Quest",Content="Aceita: "..q.questName,Duration=2}) task.wait(1) end
if IsC(q.questName,q.questNo) then Fly((focus and focus.Position or q.qCF.Position)+Vector3.new(0,QH,0)) Comp(q) Rayfield:Notify({Title="Quest",Content="Completa: "..q.questName,Duration=2}) task.wait(1.5) continue end

EM()
Hov()
local sl,se=LV(),q.enemy local lm=tick() local nT=0
while af do
if not ch or not hum or hum.Health<=0 then break end
if LV()~=sl then break end
if GQ().enemy~=se then break end
if IsC(q.questName,q.questNo) then break end
if tick()-lm>=MCI then EM() lm=tick() end
local t=NE(q.enemy,SR)
-- 🛠️ FIX: se não achou, voa até spawnCF antes de desistir
if not t and q.spawnCF then
    local dS=(hrp.Position-q.spawnCF.Position).Magnitude
    if dS>150 then
        Fly(q.spawnCF.Position+Vector3.new(0,FH,0))
        task.wait(0.3)
        t=NE(q.enemy,SR)
    end
end
if not t then nT=nT+2 if nT>=NEG then break end task.wait(2) continue end
nT=0 Fly(t.Position+Vector3.new(0,FH,0))
local hu=t.Parent and t.Parent:FindFirstChild("Humanoid") local ks=tick()
while af and hu and hu.Parent and hu.Health>0 do
if not ch or not hum or hum.Health<=0 then break end
if tick()-ks>KT then break end
if bp and t and t.Parent then bp.Position=t.Position+Vector3.new(0,FH,0) end
if tick()-lm>=MCI then EM() lm=tick() end
Atk(t) task.wait(ACD)
end
task.wait(0.1)
end
task.wait(0.5)
end end)

local W=Rayfield:CreateWindow({Name="Karpa Hub | Blox Fruits",LoadingTitle="Karpa Hub",LoadingSubtitle="Kill Aura + Auto Farm",ConfigurationSaving={Enabled=false},KeySystem=false})

local KT1=W:CreateTab("Kill Aura",4483362458)
KT1:CreateToggle({Name="Kill Aura",CurrentValue=false,Flag="kaT",Callback=function(v) ka=v end})
KT1:CreateSlider({Name="Attack Range",Range={10,150},Increment=5,Suffix="studs",CurrentValue=AR,Flag="AR",Callback=function(v) AR=v end})
KT1:CreateSlider({Name="Attack Cooldown",Range={0.02,0.2},Increment=0.01,Suffix="s",CurrentValue=ACD,Flag="ACD",Callback=function(v) ACD=v end})
KT1:CreateSection("Keybind")
KT1:CreateKeybind({Name="Toggle Kill Aura",CurrentKeybind="K",HoldToInteract=false,Flag="kaK",Callback=function() ka=not ka Rayfield:Notify({Title="Kill Aura",Content=ka and "ON" or "OFF",Duration=2}) end})

local FT=W:CreateTab("Auto Farm",4483362458)
local function tog(v) af=v if v then Hov() NCstart() else StopH() NCstop() end Rayfield:Notify({Title="Auto Farm",Content=v and "ON (Noclip)" or "OFF",Duration=2}) end
FT:CreateToggle({Name="Auto Farm",CurrentValue=false,Flag="afT",Callback=tog})
FT:CreateSlider({Name="Fly Speed",Range={50,400},Increment=10,Suffix="studs/s",CurrentValue=SPD,Flag="SPD",Callback=function(v) SPD=v end})
FT:CreateSlider({Name="Hover Height",Range={5,20},Increment=1,Suffix="studs",CurrentValue=FH,Flag="FH",Callback=function(v) FH=v end})
FT:CreateSlider({Name="Search Range",Range={200,1500},Increment=50,Suffix="studs",CurrentValue=SR,Flag="SR",Callback=function(v) SR=v end})
FT:CreateSection("Keybind")
FT:CreateKeybind({Name="Toggle Auto Farm",CurrentKeybind="F",HoldToInteract=false,Flag="afK",Callback=function() tog(not af) end})

Rayfield:Notify({Title="Karpa Hub",Content="Carregado",Duration=3})

pl.CharacterAdded:Connect(function(c) ch=c hrp=c:WaitForChild("HumanoidRootPart") hum=c:WaitForChild("Humanoid") occ={} if bp then bp:Destroy() bp=nil end if af then task.wait(1) Hov() NCstart() EM() end end)
