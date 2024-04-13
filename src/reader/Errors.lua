--[[
		- RO SOCKET -
	Module responsible for helping reader module to throw out errors.
	
	• Creator: @binarychunk
]]--

return {
	INVALID_ARGUMENT_TYPE = "Argument \"%s\" expected to be type %s, instead got %s!",
	
	EMPTY_WSS_LINK_TO_VALIDATE = "wss link expected, received none. Regex pattern can't be executed.",
	EMPTY_TEXT_TO_FORMAT = "text expected to be formatted, received none. Text formatting can't operate further more.",
	EMPTY_ID_TO_VALIDATE = "id expected, received none. ID validation can't operate further more.",
	
	INVALID_WSS_LINK = "invalid wss link received. Try connecting with a proper link!",
	
	HTTP_SERVICE_DISABLED = "RoSocket must have HTTP enabled for it to operate correctly. To resolve this problem, navigate to the top left corner, select FILE ➡ Game Settings ➡ Security ➡ <Allow HTTP Requests.",
	INVALID_REQUIREMENT_CONTEXT = "RoSocket must be required from a server-script directly, not a local-script. Please read our docs for further knowledge!"
}