local errors = {}

local function add(error)
	assert(errors[error.code] == nil, string.format("had the same error code[%x], msg[%s]", error.code, error.message))
	errors[error.code] = error.message
	return error.code
end

--系统错误码
SystemError = {
    success = add{code = 0x0000, message = "成功"},
    notExist = add{code = 0x0001, message = ""}
}

SERVICE = {
	THREE_REMOVE 	= "THREE_REMOVE",			--three_remove.lua		三消乐
}