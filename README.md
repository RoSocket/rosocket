
# RoSocket

Roblox websocket support made possible thru a server and a roblox module.
Http requests must be enabled for this to work. To enable them, make sure your game is published, then head over to the topbar > **FILE** > **Game Settings** > **Security** > _Allow HTTP Requests_. If you want to self-host the server source on a server of your choice, then after build is successfull (or just manually grab the RBXM), find the **"Reader"** module which is a descendant of RoSocket module, and change "SOCKET_SERVER_URL" to the URL of your server.

## Installation

Wally:

```toml
[dependencies]
Socket = "RoSocket/rosocket@1.0.0"
```

Roblox Model:
Click [here](https://create.roblox.com/store/asset/17132752732/RoSocket) or
Download from [Releases](https://github.com/RoSocket/rosocket/releases)
(we recommend you get the marketplace one which will always be the latest one)

## API

**Functions:**

```Lua
function RoSocket.Connect(socket: string): (any?) -> (table)
```

**Socket:**
```Lua
function socket.Disconnect(...: any): (boolean) -> (boolean)
function socket.Send(msg: string?): (boolean) -> (boolean)
RBXScriptSignal socket.OnDisconnect()
RBXScriptSignal socket.OnMessageReceived(msg: string?)
RBXScriptSignal socket.OnErrorReceived(err: string?)
string socket.UUID -- Universal Unique Identifier
string socket.Socket -- Socket link (e.g: wss://hello.com)
string socket.binaryType -- buffer (doesn't modify way of requests)
string socket.readyState -- OPEN/CLOSED
object socket.Messages
object socket.Errors
```

**Keys:**

```Lua
Version: "1.0.0"
```

## Simple Example

```Lua
local RoSocket = require(script.RoSocket)

-- Http service requests should be enabled for this to work, and a correct server should be set in the Reader module.
local Success, Socket = pcall(RoSocket.Connect, "wss://echo.websocket.org")
if Success ~= false then 
	print(`Socket's Universal Unique Identifier: {Socket.UUID}`) -- ...
	print(`Socket's URL is:	 {Socket.Socket}`) -- wss://echo.websocket.org
	print(`Socket's state is: {Socket.readyState}`) -- OPEN
	print(`Socket's binary Type is: {Socket.binaryType}`) -- buffer (read-only)
	print(`Socket's amount of messages: {#Socket.Messages}`)
	print(`Socket's amount of errors: {#Socket.Errors}`)
	Socket.OnDisconnect:Connect(function(...: any?)
		warn(`Socket {Socket.Socket} was disconnected!`)
	end)
	Socket.OnMessageReceived:Connect(function(msg: string?)
		warn(`Message from {Socket.Socket}: {tostring(msg)}`)
	end)
	Socket.OnErrorReceived:Connect(function(err: string?)
		error(`Error from {Socket.Socket}: {tostring(err)}`)
	end)
	local Suc1 = Socket.Send("Hello World!") -- First message
	print(`Socket first message {Suc1 == true and "has been sent successfully!" or "has failed to send!"}`)
	local Suc2 = Socket.Send("Hello World!") -- Repeated message
	print(`Socket repeated message {Suc2 == true and "has been sent successfully!" or "has failed to send!"}`)
	local Suc3 = Socket.Send("Goodbye World!") -- Second message
	print(`Socket second message {Suc3 == true and "has been sent successfully!" or "has failed to send!"}`)
	Socket.Disconnect()
	Socket.Send("Hello World!") -- Throws a warning in the output saying you can't send messages to a disconnected socket
	print(`Socket's state is: {Socket.readyState}`) -- CLOSED
	print(`Socket's amount of messages: {#Socket.Messages}`)
else
	warn("Failed to connect to websocket!")
end
```
