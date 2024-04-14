--[[
		- RO SOCKET -
	A blazing fast implementation of WebSockets in roblox, similar to the "ws" library in Node.
	Supports client and server implementation.
	Backend uses the "ws" library aswell, providing proper socket support, and is coded in Node.
	
	• Creator: @binarychunk
]]--

local RoSocket = {}
-----------------------------------------------
local Reader = require(script.Reader)
local Errors = require(script.Reader.Errors)
local Signal = require(script.Signal)
local Maid = require(script.Maid)
-----------------------------------------------
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")
-----------------------------------------------
local SOCKET_SERVER_UPDATES = 0.15
-----------------------------------------------
export type RequestResponse<T> = {
	Success: boolean?,
	StatusCode: number?,
	StatusMessage: string?,
	Headers: {[string?]: string},
	Body: T
}
-----------------------------------------------
-- Main checks for proper execution, such as context checks --
-- Context check
if RunService:IsServer() == false then
	error(Reader:FormatText(Errors.INVALID_REQUIREMENT_CONTEXT))
end
-- Http check
if not HttpService.HttpEnabled then
	error(Reader:FormatText(Errors.HTTP_SERVICE_DISABLED))
end
-----------------------------------------------
local MaidSocket = Maid.new()
local Sockets = {}
RoSocket.Version = "1.0.0"
RoSocket.Connect = function(socket: string): (any?) -> (table)
	local validsocket = true

	if validsocket ~= false then
		local data = Reader:Connect(socket)
		if data.success ~= false then
			local dis = false
			local uuid = data.UUID
			local localmsgs = {}
			local localerrors = {}
			local tbl = {}
			tbl.readyState = dis
			coroutine.resume(coroutine.create(function() 
				while tbl do 
					tbl.readyState = dis and "CLOSED" or "OPEN"
					task.wait()
				end
			end))
			tbl.binaryType = "buffer"
			local OnDisconnect : RBXScriptSignal = Signal.new()
			tbl.OnDisconnect = OnDisconnect
			local OnMessageReceived : RBXScriptSignal = Signal.new()
			tbl.OnMessageReceived = OnMessageReceived
			local OnErrorReceived : RBXScriptSignal = Signal.new()
			tbl.OnErrorReceived = OnErrorReceived

			local elapsedTimer = Sockets[uuid] and Sockets[uuid].elapsedtimer or 0

			MaidSocket[uuid] = RunService.Heartbeat:Connect(function(deltaTime)

				if elapsedTimer >= SOCKET_SERVER_UPDATES then
					elapsedTimer = 0
				end
				elapsedTimer += deltaTime
				if elapsedTimer >= SOCKET_SERVER_UPDATES then
					if dis == false then
						-- messages
						local suc, Msgs = pcall(Reader.Get, Reader, uuid)
						if typeof(Msgs) == "table" then
							for _, msgobj in ipairs(Msgs) do
								local existsAlready = false
								for i,msg in ipairs(Sockets[uuid].msgs) do
									if msg.id == msgobj.id then
										existsAlready = true
										break
									end
								end

								if existsAlready == false then
									tbl.OnMessageReceived:Fire(msgobj.message)
									table.insert(Sockets[uuid].msgs, {
										id = msgobj.id,
										message = msgobj.message,
									})
									table.insert(localmsgs, {
										id = msgobj.id,
										message = msgobj.message,
									})
								end
							end
						end
						-- errors
						local suc, Msgs = pcall(Reader.GetErrors, Reader, uuid)
						if typeof(Msgs) == "table" then
							for _, msgobj in ipairs(Msgs) do
								local existsAlready = false
								for i,msg in ipairs(Sockets[uuid].errors) do
									if msg.id == msgobj.id then
										existsAlready = true
										break
									end
								end

								if existsAlready == false then
									tbl.OnErrorReceived:Fire(msgobj.message)
									table.insert(Sockets[uuid].errors, {
										id = msgobj.id,
										message = msgobj.message,
									})
									table.insert(localerrors, {
										id = msgobj.id,
										message = msgobj.message,
									})
								end
							end
						end
					else

					end
				end
			end)

			tbl.UUID = uuid
			tbl.Socket = data.Socket
			tbl.Disconnect = function(...)
				local success = Reader:Disconnect(uuid)
				Sockets[uuid] = nil
				MaidSocket[uuid] = nil
				tbl.OnDisconnect:Fire()
				dis = true
				return true
			end
			tbl.Send = function(...) 
				if dis == false then
					local success = Reader:Send(uuid, select(1, ...))
					return success
				else
					warn(Reader:FormatText("You cannot send messages to a disconnected socket!"))
					return false
				end
			end
			tbl.Messages = localmsgs and localmsgs or {}
			tbl.Errors = localerrors and localerrors or {}

			setmetatable(tbl, {
				__call = function(self, index, ...) 
					return tbl[index](...)
				end,
				__metatable = "This is a protected metatable!"
			})
			Sockets[uuid] = {
				sockettbl = tbl,
				msgs = {},
				errors = {},
				elapsedtimer = 0
			}

			return tbl
		end
	else
		return {}
	end
end
setmetatable(RoSocket, {
	__call = function(self, ...)
		return RoSocket.Connect(...)
	end
})
table.freeze(RoSocket)
-----------------------------------------------
return RoSocket
