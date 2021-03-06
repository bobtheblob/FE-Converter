-- loadstring(game:GetService'HttpService':GetAsync("https://raw.githubusercontent.com/bobtheblob/FE-Converter/main/main.lua"))()
wait(1/60)
local ts =game:GetService("TweenService")
local tscreate = ts.Create
local inst = getfenv().Instance
local cache = setmetatable({},{__mode = "k"})
local sndlist = {}
-- functions
function newfakesignal()
	local signal = {}
	local cons = {}
	local waiting = false
	signal.ClassName = "Signal"
	signal.Connect = function(_,func)
		table.insert(cons,func)
		local index = cons[#cons]
		local b = {}
		b.Disconnect = function()
			table.remove(cons,index)
		end
	end
	signal.Fire = function(_,...)
		for i,v in pairs(cons) do
			local args = {...}
			v(unpack(args))
		end
		waiting = false
	end
	signal.Wait = function(_)
		waiting = true
		repeat wait() until waiting == false
	end
	return signal
end
function wrap(object)
	for i,v in next,cache do
		if v == object then
			return i
		end
	end
	if type(object) == 'userdata' then
		local proxy = newproxy(true)
		local meta = getmetatable(proxy)
		local funcs = {}
		meta.__index = function(a,b)
			for i,v in pairs(funcs) do
				if v[1] == b then
					return function(self,...)
						local args = {...}
						return v[2](unpack(args))
					end
				end
			end
			if b == "AddFunc" then
				return function(self,name,func)
					local id = funcs[#funcs+1]
					table.insert(funcs,{name,func})
					return id
				end
			elseif b == "RemoveFunc" then
				return function(self,name)
					for i,v in pairs(funcs)do
						if v[1] == name then
							funcs[i] = nil
						end
					end
				end
			end
			return wrap(object[b])
		end
		meta.__newindex = function(a,b,c)
			if type(object[b]) == 'function' then
				object[b](c)
			else
				object[b] = c
			end

		end
		meta.__tostring = function(a)
			return tostring(object)
		end
		meta.__unm = function(a)
			return wrap(object:Clone())
		end
		cache[proxy] = object
		return proxy
	elseif type(object) == "table" then
		local fake = {}
		for k,v in next,object do
			fake[k] = wrap(v)
		end
		return fake
	elseif type(object) == "function" then
		local fake = function(...)
			local args = unwrap{...}
			local results = wrap{object(unpack(args))}
			return unpack(results)
		end
		cache[fake] = object
		return fake
	else
		return object
	end

end
function unwrap(fake)
	if type(fake) == "table" then
		local real = {}
		for k,v in next,fake do
			real[k] = unwrap(v)
		end
		return real
	else

		local obj = cache[fake]
		if obj then
			return obj
		end
		return fake
	end
end
function genguid()
	return game:service'HttpService':GenerateGUID(true)
end
function spairs(t, order)
	-- collect the keys
	local keys = {}
	for k in pairs(t) do keys[#keys+1] = k end

	-- if order function given, sort by it by passing the table and keys a, b,
	-- otherwise just sort the keys 
	if order then
		table.sort(keys, function(a,b) return order(t, a, b) end)
	else
		table.sort(keys)
	end

	-- return the iterator function
	local i = 0
	return function()
		i = i + 1
		if keys[i] then
			return keys[i], t[keys[i]]
		end
	end
end
local libs = {
	{'RbxUtility',"https://pastebin.com/raw/NSWnCKFv"};
	{'RbxGui','https://pastebin.com/raw/5rZgHPA0'};
	{'RbxStamper','https://pastebin.com/raw/RrYxewLA'}
}
getfenv().LoadLibrary = function(lib)
	for i,v in pairs(libs) do
		if v[1] == lib then
			return loadstring(game:GetService'HttpService':GetAsync(v[2]))()
		end
	end
end
--
local mouse = {
	Hit = CFrame.new();
	X = 0;
	Y = 0;
	Target = nil;
	Origin = CFrame.new();
	TargetSurface = Enum.NormalId.Back;
	ViewSizeX = 0;
	ViewSizeY = 0;
	KeyDown = newfakesignal();
	KeyUp = newfakesignal();
	Button1Down = newfakesignal();
	Button2Down = newfakesignal();
	Button1Up = newfakesignal();
	Button2Up = newfakesignal();
	Move = newfakesignal();
	Idle = newfakesignal();
	WheelBackward = newfakesignal();
	WheelForward = newfakesignal();
}
local rem = Instance.new("RemoteEvent")
rem.Parent = owner.PlayerGui
rem.Name = "Remote"
local key = genguid()
local ls = NLS([[
task.wait(1/60)
local rem = script.Parent:WaitForChild'Remote'
local keyt = script:WaitForChild'Instance'.ServerInstanceId
local mouse = owner:GetMouse()
local uis = game:GetService("UserInputService")
local hit,target = mouse.Hit,mouse.Target
rem:FireServer()
uis.InputBegan:Connect(function(key,gpe)
	rem:FireServer(keyt,'InputBegan',{KeyCode = key.KeyCode,Position = key.Position,Delta = key.Delta,UserInputState = key.UserInputState,UserInputType = key.UserInputType,GPE = gpe})
end)
uis.InputEnded:Connect(function(key,gpe)
	rem:FireServer(keyt,'InputEnded',{KeyCode = key.KeyCode,Position = key.Position,Delta = key.Delta,UserInputState = key.UserInputState,UserInputType = key.UserInputType,GPE = gpe})
end)
rem:FireServer(keyt,'setmouse',{
	Hit = mouse.Hit;
	X = mouse.X;
	Y = mouse.Y;
	ViewSizeX = mouse.ViewSizeX;
	ViewSizeY = mouse.ViewSizeY;
	TargetSurface = mouse.TargetSurface;
	Target = mouse.Target;
	Origin = mouse.Origin;
	CameraCFrame = workspace:FindFirstChildOfClass'Camera'.CFrame;
})
game:service'RunService'.Stepped:Connect(function()
	if hit ~= mouse.Hit or target ~= mouse.Target then
		hit,target = mouse.Hit,mouse.Target
		rem:FireServer(keyt,'setmouse',{
			Hit = mouse.Hit;
			X = mouse.X;
			Y = mouse.Y;
			ViewSizeX = mouse.ViewSizeX;
			ViewSizeY = mouse.ViewSizeY;
			TargetSurface = mouse.TargetSurface;
			Target = mouse.Target;
			Origin = mouse.Origin;
			CameraCFrame = workspace:FindFirstChildOfClass'Camera'.CFrame;
		})
	end
end)
]],owner.PlayerGui)
local to = Instance.new("TeleportOptions")
to.ServerInstanceId = key
to.Parent = ls
rem.OnServerEvent:Wait()
to:Destroy()
local fakegame = {}
local realgame = game
local realplrs = game:GetService("Players")
getfenv().GetMouse = function()
	return mouse
end

getfenv().typeof = wrap(typeof)
getfenv().wrap = wrap
getfenv().unwrap = unwrap
getfenv().Tween = function(a,b,c)
	return tscreate(a,b,c)
end
rem.OnServerEvent:Connect(function(who,akey,type,...)
	if akey == key then
		local args = {...}
		if type == 'setmouse' then

			mouse.Hit = args[1].Hit
			mouse.X = args[1].X
			mouse.Y = args[1].Y
			mouse.Target = args[1].Target
			mouse.Origin = args[1].Origin
			mouse.TargetSurface = args[1].TargetSurface
			mouse.ViewSizeX = args[1].ViewSizeX
			mouse.ViewSizeY = args[1].ViewSizeY
			mouse.CameraCFrame = args[1].CameraCFrame
		elseif type == "InputBegan" then
			local ta = args[1]
			if not ta.GPE then
				if ta.UserInputType == Enum.UserInputType.MouseButton1 then
					mouse.Button1Down:Fire()
				elseif ta.UserInputType == Enum.UserInputType.MouseButton2 then
					mouse.Button2Down:Fire()
				elseif ta.UserInputType == Enum.UserInputType.Keyboard then
					mouse.KeyDown:Fire(ta.KeyCode.Name:lower())
				end
			end
		elseif type == "InputEnded" then
			local ta = args[1]
			if not ta.GPE then
				if ta.UserInputType == Enum.UserInputType.MouseButton1 then
					mouse.Button1Up:Fire()
				elseif ta.UserInputType == Enum.UserInputType.MouseButton2 then
					mouse.Button2Up:Fire()
				elseif ta.UserInputType == Enum.UserInputType.Keyboard then
					mouse.KeyUp:Fire(ta.KeyCode.Name:lower())
				end
			end
		end
	end
end)
