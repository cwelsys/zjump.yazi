--- @since 26.8.15

local get_cwd = ya.sync(function()
	return tostring(cx.active.current.cwd)
end)

local function notify(msg, level)
	ya.notify({ title = "zjump", content = msg, timeout = 3, level = level or "warn" })
end

local function as_dir(path, cwd)
	local home = os.getenv("HOME") or ""
	if path == "~" then
		path = home
	elseif path:sub(1, 2) == "~/" then
		path = home .. path:sub(2)
	elseif path:sub(1, 1) ~= "/" then
		path = cwd .. "/" .. path
	end
	local url = Url(path)
	local cha = fs.cha(url)
	if cha and cha.is_dir then
		return url
	end
end

return {
	entry = function()
		local input, event = ya.input({
			title = "z:",
			pos = { "top-center", y = 3, w = 50 },
		})
		if event ~= 1 then
			return
		end

		local args = {}
		for word in input:gmatch("%S+") do
			args[#args + 1] = word
		end

		if #args == 0 then
			return ya.emit("cd", { Url(os.getenv("HOME")) })
		end
		if #args == 1 and args[1] == "-" then
			return ya.emit("back", {})
		end

		local cwd = get_cwd()
		if #args == 1 then
			local url = as_dir(args[1], cwd)
			if url then
				return ya.emit("cd", { url })
			end
		end

		local cmd_args = { "query", "--exclude", cwd, "--" }
		for _, a in ipairs(args) do
			cmd_args[#cmd_args + 1] = a
		end
		local out, err = Command("zoxide"):arg(cmd_args):stdout(Command.PIPED):stderr(Command.PIPED):output()
		if not out then
			return notify("Failed to run zoxide: " .. tostring(err), "error")
		end
		if not out.status.success then
			return notify("no match for: " .. input)
		end

		local target = out.stdout:gsub("%s+$", "")
		if target ~= "" then
			ya.emit("cd", { Url(target) })
		end
	end,
}
