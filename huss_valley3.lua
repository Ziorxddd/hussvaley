local RunService = (function() local ok, s = pcall(function() return game:GetService("RunService") end); return ok and s or nil end)()
local UIS     = game:GetService("UserInputService")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local iskeypressed: any = rawget(_G, "iskeypressed")
local writefile: any    = rawget(_G, "writefile")
local readfile: any     = rawget(_G, "readfile")
local function setclipboard(text: string)
    local env = (getfenv and getfenv()) or _G
    local fn = env.setclipboard or env.toclipboard or env.set_clipboard
        or rawget(_G,"setclipboard") or rawget(_G,"toclipboard") or rawget(_G,"set_clipboard")
    if type(fn)=="function" then pcall(fn, text); return true end
    return false
end
local isrbxactive: any  = rawget(_G, "isrbxactive")
local _dbg = debug

-- kill any previous instance
local prev = rawget(_G, "ValleyHV")
if type(prev) == "table" and type(prev.stop) == "function" then pcall(prev.stop) end

local me = Players.LocalPlayer
assert(me, "LocalPlayer unavailable")

-- ── Jnkie key system ──────────────────────────────────────────────────────────

local JNKIE_SERVICE    = "hussvaley"
local JNKIE_IDENTIFIER = "1218286"
local JNKIE_PROVIDER   = "linkvertise"
local KEY_FILE         = "HussValleyKey.txt"

local function runKeySystem()
    local Junkie = loadstring(game:HttpGet("https://jnkie.com/sdk/library.lua"))()
    Junkie.service    = JNKIE_SERVICE
    Junkie.identifier = JNKIE_IDENTIFIER
    Junkie.provider   = JNKIE_PROVIDER

    -- try saved key first
    local savedKey = nil
    if type(readfile) == "function" then
        local ok, raw = pcall(readfile, KEY_FILE)
        if ok and type(raw) == "string" then
            savedKey = raw:match("^%s*(.-)%s*$")
            if savedKey == "" then savedKey = nil end
        end
    end
    if savedKey then
        local ok, result = pcall(Junkie.check_key, savedKey)
        if ok and result.valid then return true end
        savedKey = nil
    end

    -- build key UI
    local gui = Instance.new("ScreenGui")
    gui.Name = "HVKeyUI"
    gui.ResetOnSpawn = false
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    gui.IgnoreGuiInset = true
    pcall(function() gui.Parent = game:GetService("CoreGui") end)
    if not gui.Parent then gui.Parent = me.PlayerGui end

    local overlay = Instance.new("Frame", gui)
    overlay.Size = UDim2.new(1,0,1,0)
    overlay.BackgroundColor3 = Color3.fromRGB(8,8,14)
    overlay.BackgroundTransparency = 0.25
    overlay.BorderSizePixel = 0

    local card = Instance.new("Frame", gui)
    card.Size = UDim2.new(0,380,0,290)
    card.Position = UDim2.new(0.5,-190,0.5,-145)
    card.BackgroundColor3 = Color3.fromRGB(16,16,26)
    card.BorderSizePixel = 0
    Instance.new("UICorner", card).CornerRadius = UDim.new(0,14)
    local cardStroke = Instance.new("UIStroke", card)
    cardStroke.Color = Color3.fromRGB(60,60,130)
    cardStroke.Thickness = 1

    local function lbl(parent, text, x, y, w, h, size, color, bold, xalign)
        local l = Instance.new("TextLabel", parent)
        l.Size = UDim2.new(0,w,0,h); l.Position = UDim2.new(0,x,0,y)
        l.BackgroundTransparency = 1; l.Text = text
        l.TextColor3 = color or Color3.fromRGB(230,230,250)
        l.Font = bold and Enum.Font.GothamBold or Enum.Font.Gotham
        l.TextSize = size or 14
        l.TextXAlignment = xalign or Enum.TextXAlignment.Center
        return l
    end

    lbl(card, "Huss Valley", 0, 22, 380, 28, 21, Color3.fromRGB(240,240,255), true)
    lbl(card, "Enter your key to continue", 20, 58, 340, 18, 13, Color3.fromRGB(130,130,170), false, Enum.TextXAlignment.Left)

    local inputBox = Instance.new("TextBox", card)
    inputBox.Size = UDim2.new(1,-40,0,40)
    inputBox.Position = UDim2.new(0,20,0,84)
    inputBox.BackgroundColor3 = Color3.fromRGB(24,24,38)
    inputBox.BorderSizePixel = 0
    inputBox.TextColor3 = Color3.fromRGB(220,220,245)
    inputBox.PlaceholderText = "Paste your key here..."
    inputBox.PlaceholderColor3 = Color3.fromRGB(90,90,120)
    inputBox.Font = Enum.Font.Gotham; inputBox.TextSize = 13
    inputBox.ClearTextOnFocus = false; inputBox.Text = ""
    Instance.new("UICorner", inputBox).CornerRadius = UDim.new(0,8)
    local iStroke = Instance.new("UIStroke", inputBox)
    iStroke.Color = Color3.fromRGB(60,60,110); iStroke.Thickness = 1
    local iPad = Instance.new("UIPadding", inputBox)
    iPad.PaddingLeft = UDim.new(0,10); iPad.PaddingRight = UDim.new(0,10)

    local statusLbl = lbl(card, "", 20, 134, 340, 16, 12, Color3.fromRGB(210,70,70), false, Enum.TextXAlignment.Left)

    -- selectable link box (hidden until key link is fetched)
    local linkBox = Instance.new("TextBox", card)
    linkBox.Size = UDim2.new(1,-40,0,30)
    linkBox.Position = UDim2.new(0,20,0,152)
    linkBox.BackgroundColor3 = Color3.fromRGB(12,12,22)
    linkBox.BorderSizePixel = 0
    linkBox.TextColor3 = Color3.fromRGB(100,180,255)
    linkBox.Font = Enum.Font.Gotham; linkBox.TextSize = 11
    linkBox.ClearTextOnFocus = false; linkBox.Text = ""
    linkBox.TextXAlignment = Enum.TextXAlignment.Left
    linkBox.Visible = false
    Instance.new("UICorner", linkBox).CornerRadius = UDim.new(0,6)
    local lbStroke = Instance.new("UIStroke", linkBox)
    lbStroke.Color = Color3.fromRGB(40,40,80); lbStroke.Thickness = 1
    local lbPad = Instance.new("UIPadding", linkBox)
    lbPad.PaddingLeft = UDim.new(0,8); lbPad.PaddingRight = UDim.new(0,8)

    local function makeBtn(parent, text, x, y, w, h, bg, tc)
        local b = Instance.new("TextButton", parent)
        b.Size = UDim2.new(0,w,0,h); b.Position = UDim2.new(0,x,0,y)
        b.BackgroundColor3 = bg; b.BorderSizePixel = 0
        b.TextColor3 = tc; b.Text = text
        b.Font = Enum.Font.GothamBold; b.TextSize = 14
        b.AutoButtonColor = false
        Instance.new("UICorner", b).CornerRadius = UDim.new(0,8)
        return b
    end

    local submitBtn = makeBtn(card, "Submit Key", 20, 192, 340, 40,
        Color3.fromRGB(70,70,200), Color3.fromRGB(255,255,255))
    local getKeyBtn = makeBtn(card, "Get Free Key (ad)", 20, 242, 340, 40,
        Color3.fromRGB(22,22,40), Color3.fromRGB(130,130,210))
    local getKeyStroke = Instance.new("UIStroke", getKeyBtn)
    getKeyStroke.Color = Color3.fromRGB(60,60,130); getKeyStroke.Thickness = 1

    -- expand card height to fit link box
    card.Size = UDim2.new(0,380,0,330)
    card.Position = UDim2.new(0.5,-190,0.5,-165)

    lbl(card, "free via ads  ·  or buy a key in our Discord", 0, 295, 380, 18, 11,
        Color3.fromRGB(80,80,110), false)

    local done, busy = false, false

    submitBtn.MouseButton1Click:Connect(function()
        if busy or done then return end
        local k = inputBox.Text:match("^%s*(.-)%s*$")
        if k == "" then
            statusLbl.TextColor3 = Color3.fromRGB(210,70,70)
            statusLbl.Text = "Enter a key first"; return
        end
        busy = true; submitBtn.Text = "Checking..."
        statusLbl.Text = ""
        local ok, result = pcall(Junkie.check_key, k)
        busy = false; submitBtn.Text = "Submit Key"
        if not ok then
            statusLbl.TextColor3 = Color3.fromRGB(210,70,70)
            statusLbl.Text = "Request failed, try again"; return
        end
        if not result.valid then
            statusLbl.TextColor3 = Color3.fromRGB(210,70,70)
            statusLbl.Text = "Invalid key: " .. tostring(result.error); return
        end
        if type(writefile) == "function" then pcall(writefile, KEY_FILE, k) end
        done = true
    end)

    getKeyBtn.MouseButton1Click:Connect(function()
        if busy then return end
        busy = true; getKeyBtn.Text = "Getting link..."
        statusLbl.Text = ""; linkBox.Visible = false
        local ok, link = pcall(Junkie.get_key_link, JNKIE_PROVIDER)
        busy = false; getKeyBtn.Text = "Get Free Key (ad)"
        if not ok or type(link) ~= "string" or link == "" then
            statusLbl.TextColor3 = Color3.fromRGB(210,70,70)
            statusLbl.Text = "Couldn't get link: " .. tostring(link); return
        end
        local copied = setclipboard(link)
        -- show selectable link box so user can Ctrl+C if clipboard failed
        linkBox.Text = link
        linkBox.Visible = true
        statusLbl.TextColor3 = Color3.fromRGB(70,210,120)
        statusLbl.Text = copied and "✓ Copied! Open link in browser" or "✓ Select link below → Ctrl+C"
    end)

    repeat task.wait(0.05) until done
    gui:Destroy()
    return true
end

assert(runKeySystem(), "Key system failed")


-- ── helpers ───────────────────────────────────────────────────────────────────

local function finite(n) return type(n)=="number" and n==n and math.abs(n)<1e12 end
local function read(obj, key)
    if not obj then return nil end
    local ok, v = pcall(function() return obj[key] end); return ok and v or nil
end
local function attr(obj, key)
    if not obj then return nil end
    local ok, v = pcall(function() return obj:GetAttribute(key) end); return ok and v or nil
end
local function child(obj, name)
    if not obj then return nil end
    local ok, v = pcall(function() return obj:FindFirstChild(name) end); return ok and v or nil
end
local function vector(v)
    return v and finite(read(v,"X")) and finite(read(v,"Y")) and finite(read(v,"Z"))
end
local function idOf(obj) return read(obj,"Address") or obj end
local function horizontal(v) return math.sqrt(v.X*v.X + v.Z*v.Z) end
local function pressedKey(vk)
    if type(iskeypressed)=="function" then
        local ok, v = pcall(iskeypressed, vk); if ok then return v==true end
    end
    local ok, v = pcall(function() return UIS:IsKeyDown(vk) end)
    return ok and v==true
end

-- ── log ───────────────────────────────────────────────────────────────────────

local logLines = {}
local logDirty, nextLogWrite = false, 0
local function flushLog(force)
    if not logDirty or (not force and tick()<nextLogWrite) then return end
    nextLogWrite = tick() + .25
    if type(writefile)=="function" then
        pcall(writefile, "valley_hv_log.txt", table.concat(logLines,"\n"))
        logDirty = false
    end
end
local function log(msg)
    local line = tostring(msg)
    print("[Valley HV] "..line)
    logLines[#logLines+1] = line
    if #logLines>60 then table.remove(logLines,1) end
    logDirty = true; flushLog()
end

-- ── state (declared early so callbacks can close over it) ────────────────────

local state = { speed = false, target = 36 }

local dash = {
    infinite=false, longer=false, scale=1.5,
    status="Off", boost="Off",
    track=nil, character=nil,
    failedCount=nil, nextScan=nil,
    failures=0, lastCount=nil, motion=nil,
}

-- ── load Rayfield ─────────────────────────────────────────────────────────────

local Rayfield
do
    local ok, result = pcall(function()
        return loadstring(game:HttpGet("https://sirius.menu/rayfield"))()
    end)
    assert(ok and type(result)=="table", "Rayfield failed: "..tostring(result))
    Rayfield = result
end

local Window = Rayfield:CreateWindow({
    Name = "Huss Valley",
    LoadingTitle = "Huss Valley",
    LoadingSubtitle = "v0.7.0",
    ConfigurationSaving = { Enabled = true, FileName = "HussValleyConfig" },
    KeySystem = false,  -- handled by Jnkie above
})

-- ── UI tabs ───────────────────────────────────────────────────────────────────

local MovTab = Window:CreateTab("Movement", 4483362458)

MovTab:CreateToggle({
    Name = "Speed Tuning",
    CurrentValue = false,
    Flag = "HV_Speed",
    Callback = function(v) state.speed = v end,
})
MovTab:CreateSlider({
    Name = "Travel Speed",
    Range = {10, 45},
    Increment = 1,
    Suffix = " studs/s",
    CurrentValue = 36,
    Flag = "HV_SpeedTarget",
    Callback = function(v) state.target = v end,
})

MovTab:CreateSection("Dash Cooldown")
MovTab:CreateToggle({
    Name = "Infinite Dash (no cooldown)",
    CurrentValue = false,
    Flag = "HV_InfDash",
    Callback = function(v)
        dash.infinite = v
        if not v then dash.status = "Off" end
    end,
})
local labelCooldown = MovTab:CreateLabel("Cooldown: Off")

MovTab:CreateSection("Dash Distance")
MovTab:CreateToggle({
    Name = "Longer Dash",
    CurrentValue = false,
    Flag = "HV_LongDash",
    Callback = function(v)
        dash.longer = v
        if not v then dash.boost = "Off" end
    end,
})
MovTab:CreateSlider({
    Name = "Dash Distance",
    Range = {1.1, 3.0},
    Increment = 0.1,
    Suffix = "x",
    CurrentValue = 1.5,
    Flag = "HV_DashScale",
    Callback = function(v) dash.scale = v end,
})
local labelDistance = MovTab:CreateLabel("Distance: Off")

MovTab:CreateSection("Status")
local labelMovement = MovTab:CreateLabel("Movement: Off")
local labelDash     = MovTab:CreateLabel("Dash: Off")

-- ── app object ────────────────────────────────────────────────────────────────

local app = { alive = true, dashState = dash }
rawset(_G, "ValleyHV", app)

-- ── dash engine ───────────────────────────────────────────────────────────────

local function findDashTable(c, count)
    local env = (getfenv and getfenv()) or _G
    -- debug.getreg + debug.getupvalues (PC executors)
    local dbg = _dbg or env.debug or rawget(_G,"debug")
    local dbgOk = type(dbg)=="table"
        and (type(rawget(dbg,"getreg"))=="function" or type(rawget(dbg,"getregistry"))=="function")
        and type(rawget(dbg,"getupvalues"))=="function"
    local getreg = dbgOk and (rawget(dbg,"getreg") or rawget(dbg,"getregistry")) or nil
    local getups = dbgOk and rawget(dbg,"getupvalues") or nil
    -- getgc (Delta + most mobile executors inject into script env, not _G)
    local gcFn = env.getgc or rawget(_G,"getgc")
    if not dbgOk and type(gcFn)~="function" then
        return nil, "No table scanner available"
    end
    local fresh = attr(c, "DashCount")
    local found, seen = {}, {}
    local function check(v)
        if type(v)~="table" or seen[v] then return end; seen[v]=true
        local dc=rawget(v,"dashCount"); local cd=rawget(v,"cooldown")
        local dr=rawget(v,"dashRemaining"); local rr=rawget(v,"recoveryRemaining")
        if finite(dc) and finite(cd) and finite(dr) and finite(rr) and dc==count then
            found[#found+1]=v
        end
    end
    if dbgOk then
        local ok, reg = pcall(getreg)
        if ok and type(reg)=="table" then
            for _, v in pairs(reg) do
                check(v)
                if type(v)=="function" then
                    local ok2, uvs = pcall(getups, v)
                    if ok2 and type(uvs)=="table" then
                        for _, uv in ipairs(uvs) do check(uv) end
                    end
                end
            end
        end
    end
    if #found==0 and type(gcFn)=="function" then
        local ok, gc = pcall(gcFn, false)
        if not ok or type(gc)~="table" then ok, gc = pcall(gcFn) end
        if ok and type(gc)=="table" then
            for _, v in ipairs(gc) do check(v) end
        end
    end
    if #found==1 then return found[1], nil, fresh
    elseif #found==0 then return nil, "Dash state not found", fresh
    else return nil, "Dash state ambiguous ("..#found.." tables)", fresh end
end

local function readField(t,name)
    local ok,v=pcall(rawget,t,name); return ok and v or nil
end
local function writeField(t,name,value)
    if not pcall(rawset,t,name,value) then return false end
    local after=readField(t,name)
    return finite(after) and math.abs(after-value)<=1e-6
end

local function extendDash(track, count)
    local elapsed  = readField(track,"dashElapsed")
    local remaining= readField(track,"dashRemaining")
    local start    = readField(track,"boostStart")
    local exit_    = readField(track,"boostExit")
    local lift     = readField(track,"boostLift")
    if not (finite(elapsed) and finite(remaining) and finite(start) and finite(exit_) and finite(lift)) then
        dash.boost = "Boost fields missing"; return
    end
    if remaining<=0 then dash.boost="Dash ended before extension"; return end
    local duration = elapsed+remaining
    local done = elapsed/duration
    if done>.5 then dash.boost="Dash seen too late; next will extend"; return end
    local pace = (start+exit_)/2+lift
    local newLift = lift+(dash.scale-1)*pace/(1-3*done*done+2*done*done*done)
    if not writeField(track,"boostLift",newLift) then dash.boost="Write not observed"; return end
    dash.boost = string.format("%.1fx (%.0f studs)", dash.scale, duration*pace*dash.scale)
end

local function loseDash(reason)
    dash.track, dash.status = nil, reason.."; dash to find again"
    log("Dash state: "..reason)
end

local function dashStep(c, now)
    dash.motion = nil
    if not dash.infinite and not dash.longer then dash.status="Off"; return end
    local env = (getfenv and getfenv()) or _G
    local dbg = _dbg or env.debug or rawget(_G,"debug")
    local canScan = (type(dbg)=="table"
        and (type(rawget(dbg,"getreg"))=="function" or type(rawget(dbg,"getregistry"))=="function")
        and type(rawget(dbg,"getupvalues"))=="function")
        or type(env.getgc or rawget(_G,"getgc"))=="function"
    if not canScan then dash.status="Scanner unavailable"; return end
    local character = idOf(c)
    if character~=dash.character then
        dash.character,dash.track,dash.failedCount,dash.nextScan,dash.failures=character,nil,nil,now+.5,0
    end
    if not c then dash.status="Waiting for character"; return end
    local track = dash.track
    if not track then
        if now<(dash.nextScan or 0) then return end
        dash.nextScan = now+.5
        local count = attr(c,"DashCount")
        if not finite(count) or count<=0 then dash.status="Dash once to find state"; return end
        if count==dash.failedCount then return end
        local began = tick()
        local reason, fresh
        track, reason, fresh = findDashTable(c, count)
        if not track then
            dash.failures = dash.failures+1
            dash.failedCount = finite(fresh) and fresh or count
            dash.nextScan = tick()+math.min(30,2^dash.failures)
            dash.status = reason.."; dash again"
            log(string.format("Dash: %s (%.2fs)", reason, tick()-began)); return
        end
        track._checkAt, track._misses = now+2, 0
        dash.track, dash.lastCount, dash.failures = track, fresh, 0
        log(string.format("Dash state found in %.2fs", tick()-began))
    end
    local count     = readField(track,"dashCount")
    local remaining = readField(track,"dashRemaining")
    if not finite(count) or not finite(remaining) then
        track._misses = (track._misses or 0)+1
        if track._misses>30 then loseDash("Dash state became invalid") end
        return
    end
    track._misses = 0
    dash.motion = remaining>0
    if now>=(track._checkAt or 0) then
        track._checkAt = now+2
        local pub = attr(c,"DashCount")
        track._mismatch = finite(pub) and pub~=count and (track._mismatch or 0)+1 or 0
        if track._mismatch>=2 then loseDash("Dash state stopped matching"); return end
    end
    if count~=dash.lastCount then
        dash.lastCount = count
        if dash.longer then extendDash(track,count) end
    end
    if dash.infinite then
        local cooldown = readField(track,"cooldown")
        local recovery = readField(track,"recoveryRemaining")
        if not finite(cooldown) or not finite(recovery) then return end
        if cooldown>0 then writeField(track,"cooldown",0) end
        if remaining<=0 and recovery>0 then writeField(track,"recoveryRemaining",0) end
    end
    dash.status = remaining>0 and "Dashing" or "Ready"
end

-- ── movement engine ───────────────────────────────────────────────────────────

local MAX_SPEED = 45
local lastWriteAt, lastWritten, moveFails = 0, 0, 0
local movementStatus = "Off"
local pendingVelocity, characterId

local function disableFeature(feature, reason)
    state[feature] = false
    log(feature..": "..reason)
    pcall(function()
        Rayfield:Notify({Title="Control stopped", Content=feature..": "..reason, Duration=4})
    end)
end

local function movementDirection(humanoid)
    local fwd  = (pressedKey(0x57) and 1 or 0)-(pressedKey(0x53) and 1 or 0)
    local side = (pressedKey(0x44) and 1 or 0)-(pressedKey(0x41) and 1 or 0)
    local anyKeys = pressedKey(0x57) or pressedKey(0x53) or pressedKey(0x44) or pressedKey(0x41)
    if anyKeys and fwd==0 and side==0 then return nil end
    local dir = read(humanoid,"MoveDirection")
    if vector(dir) and horizontal(dir)>.01 then return dir end
    if not anyKeys then return nil end
    local cf = read(read(Workspace,"CurrentCamera"),"CFrame")
    local look, right = read(cf,"LookVector"), read(cf,"RightVector")
    if not vector(look) or not vector(right) then
        local ok, comp = pcall(function() return {cf:GetComponents()} end)
        if not ok or #comp<12 then return nil end
        look  = Vector3.new(-comp[6],-comp[9],-comp[12])
        right = Vector3.new(comp[4],  comp[7], comp[10])
    end
    local ll, rl = horizontal(look), horizontal(right)
    if ll<.001 or rl<.001 then return nil end
    return Vector3.new(look.X/ll*fwd+right.X/rl*side, 0, look.Z/ll*fwd+right.Z/rl*side)
end

local function movementStep(c, root, now)
    if not state.speed then movementStatus="Off"; return end
    if type(isrbxactive)=="function" then
        local ok, focused = pcall(isrbxactive)
        if not ok or not focused then movementStatus="Paused: not focused"; return end
    end
    local humanoid = child(c,"Humanoid")
    local health = read(humanoid,"Health")
    if not finite(health) or health<=0 then movementStatus="Paused: dead"; return end
    local v = read(root,"AssemblyLinearVelocity")
    if not vector(v) then
        moveFails=moveFails+1; movementStatus="Velocity unavailable"
        if moveFails>=60 then moveFails=0; disableFeature("speed","Velocity unavailable") end
        return
    end
    local magnitude = horizontal(v)
    if pendingVelocity and now-pendingVelocity.at>=.06 then
        movementStatus = math.abs(magnitude-pendingVelocity.target)<3 and "Active" or "Game changed velocity"
        pendingVelocity = nil
    end
    local direction = movementDirection(humanoid)
    if not direction or horizontal(direction)<.01 then
        pendingVelocity=nil; movementStatus="Paused: no input"; return
    end
    local dashing = dash.motion
    if dashing==nil then
        local ms = attr(c,"MovementState")
        dashing = ms=="Dashing" or ms=="Dash" or ms=="Boosting"
    end
    if dashing then movementStatus="Paused: dashing"; return end
    local target = math.min(state.target, MAX_SPEED)
    local dirLen = horizontal(direction)
    local dt, base = now-lastWriteAt, lastWritten
    if dt<0 or dt>.1 then dt,base=1/60,0 end
    target = math.min(target, math.max(magnitude,base)+90*dt)
    local ok, err = pcall(function()
        root.AssemblyLinearVelocity = Vector3.new(
            direction.X/dirLen*target, v.Y, direction.Z/dirLen*target)
    end)
    if not ok then
        moveFails=moveFails+1; movementStatus="Write rejected"
        if moveFails>=60 then moveFails=0; disableFeature("speed","Velocity write rejected"); log(tostring(err)) end
        return
    end
    moveFails,lastWriteAt,lastWritten = 0,now,target
    if not pendingVelocity then pendingVelocity={at=now,target=target} end
    movementStatus = string.format("Active (%.0f studs/s)", target)
end

-- ── main loop ─────────────────────────────────────────────────────────────────

local nextLabels, nextLog = 0, 0
local stepErrors = 0

local function step()
    if not app.alive then return end
    flushLog()
    local now = tick()
    local c    = read(me,"Character")
    local root = child(c,"HumanoidRootPart")
    if idOf(c)~=characterId then
        characterId=idOf(c); pendingVelocity=nil; lastWritten=0
        movementStatus="Character changed"
    end
    dashStep(c, now)
    if root then movementStep(c,root,now) else movementStatus="Waiting for character" end
    if now>=nextLabels then
        nextLabels = now+.25
        pcall(function()
            labelMovement:Set("Movement: "..movementStatus)
            labelDash:Set("Dash: "..dash.status)
            labelCooldown:Set("Cooldown: "..(dash.infinite and dash.status or "Off"))
            labelDistance:Set("Distance: "..(dash.longer and (dash.track and dash.boost or dash.status) or "Off"))
        end)
    end
    if state.speed and now>=nextLog then
        nextLog=now+3; log("Movement "..movementStatus)
    end
end

local connection = RunService.Heartbeat:Connect(function()
    local ok, err = pcall(step)
    if ok then stepErrors=0; return end
    stepErrors=stepErrors+1
    if stepErrors==1 then log("Runtime error: "..tostring(err)) end
    if stepErrors>=120 then log("Stopping after repeated errors"); app.stop() end
end)

function app.stop()
    if not app.alive then return end
    app.alive = false
    if connection then connection:Disconnect() end
    pcall(function() Rayfield:Destroy() end)
    if rawget(_G,"ValleyHV")==app then rawset(_G,"ValleyHV",nil) end
    log("Stopped"); flushLog(true)
end

-- ── RShift to toggle ─────────────────────────────────────────────────────────

UIS.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.RightShift then
        pcall(function()
            Rayfield:SetVisibility(not Rayfield:IsVisible())
        end)
    end
end)

-- ── mobile draggable overlay button ──────────────────────────────────────────

local isMobile = UIS.TouchEnabled

if isMobile then
    local gui = Instance.new("ScreenGui")
    gui.Name = "HVMobileBtn"
    gui.ResetOnSpawn = false
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    gui.IgnoreGuiInset = true
    pcall(function() gui.Parent = game:GetService("CoreGui") end)
    if not gui.Parent then gui.Parent = me.PlayerGui end

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 58, 0, 58)
    btn.Position = UDim2.new(0, 16, 0.5, -29)
    btn.BackgroundColor3 = Color3.fromRGB(18, 18, 28)
    btn.BackgroundTransparency = 0.05
    btn.TextColor3 = Color3.fromRGB(240, 240, 255)
    btn.Text = "HV"
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 15
    btn.BorderSizePixel = 0
    btn.AutoButtonColor = false
    btn.Parent = gui

    Instance.new("UICorner", btn).CornerRadius = UDim.new(1, 0)

    local stroke = Instance.new("UIStroke", btn)
    stroke.Color = Color3.fromRGB(90, 90, 200)
    stroke.Thickness = 2

    -- drag logic: track touch id so drag and tap don't conflict
    local dragging, dragTouchId = false, nil
    local dragStart, startPos, tapStartTime, tapStartPos

    btn.InputBegan:Connect(function(input)
        if input.UserInputType ~= Enum.UserInputType.Touch then return end
        dragging = true
        dragTouchId = input
        dragStart = input.Position
        startPos = btn.Position
        tapStartTime = tick()
        tapStartPos = input.Position
    end)

    UIS.InputChanged:Connect(function(input)
        if not dragging or input ~= dragTouchId then return end
        local delta = input.Position - dragStart
        btn.Position = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + delta.X,
            startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end)

    UIS.InputEnded:Connect(function(input)
        if not dragging or input ~= dragTouchId then return end
        dragging = false
        dragTouchId = nil
        local moved = tapStartPos and (input.Position - tapStartPos).Magnitude or 999
        local elapsed = tick() - (tapStartTime or 0)
        if moved < 12 and elapsed < 0.35 then
            pcall(function()
                Rayfield:SetVisibility(not Rayfield:IsVisible())
            end)
        end
    end)

    -- destroy button when script stops
    local origStop = app.stop
    function app.stop()
        pcall(function() gui:Destroy() end)
        origStop()
    end
end

log("Loaded Huss Valley v0.7.0 with Rayfield")
