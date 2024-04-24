<p align="center">
  <a href="https://github.com/RoSocket/rosocket">
  	<img width="600" src="https://github.com/RoSocket/rosocket/assets/130825965/f795c24e-dcf0-4fe3-b482-98fe7809e923">
  </a>
  <br>
  <code>RoSocket</code> is a Roblox module to emulate a websocket library.<br>
  Http requests must be enabled for the module to work.<br>
  To enable them, head over to the topbar > <b>FILE</b> > <b>Game Settings</b> > <b>Security</b> > <b>Allow HTTP Requests</b>.<br>
  If you are self-hosting, then navigate to the <b>"Reader"</b> module and change "SOCKET_SERVER_URL" to the URL of your server.
</p>

<p align="center">
  <img src="https://img.shields.io/github/license/rosocket/rosocket" alt="GitHub License">
  <img src="https://img.shields.io/github/downloads/RoSocket/rosocket/total" alt="GitHub Downloads">
</p>

---

<p align="center">
  <a href="#api">API documentation</a> •
  <a href="#simple-example">Examples</a> •
  <a href="#self-hosting-the-server">Self-hosting</a>
</p>

## Installation

Wally:

```toml
[dependencies]
Socket = "RoSocket/rosocket@1.0.1"
```

Roblox Model:
Click [here](https://create.roblox.com/store/asset/17132752732/RoSocket) or
Download from [Releases](https://github.com/RoSocket/rosocket/releases)
(we recommend you get the marketplace one which will always be the latest one)

## API

If you want faster replies, then navigate to the **reader module** > **SOCKET_SERVER_UPDATES**, set it to 0.10 or less, minimum is 0.02 before ratelimits start to appear.

**Functions:**

```Lua
function RoSocket.Connect(socket: string): (any?) -> (table)
```

**Keys:**

```Lua
string RoSocket.Version
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

## Self-hosting the server
1. Download the entire RoSocket repository by clicking on **Code** > **Download ZIP**
2. Extract the ZIP file, and cut the "server" folder. Paste the contents of the folder inside a directory of your choice/folder.
3. Open a shell and run:
```npm
npm install express ws
```
4. You're good to go! Optional is to change the default port & default host.<br>

[(Back to top)](#installation)
