-------------------------------------------------------------------------------
-- Prints logging information to console
--
-- @author Thiago Costa Ponte (thiago@ideais.com.br)
--
-- @copyright 2004-2013 Kepler Project
--
-------------------------------------------------------------------------------

local logging = uq.logging--require"app.log.logging"

function logging.console(logFlag, logPattern)
	local logger = logging.new( function(self, level, file, line, message)
			local show = false
			if uq.log_config.SHOW_ALL then
				show = true
			end
			if not show and #uq.log_config.SHOW_FLAGS == 0 then
				return false
			end
			for k,v in pairs(uq.log_config.SHOW_FLAGS) do
				if string.find(logFlag, v) then
					show = true
					break
				end
			end
			if not show then return false end
            io.stdout:write(uq.logging.prepareLogMsg(logPattern, require('socket').gettime(), level, file, line, message))
		return true
	end)
	logger:setLevel(uq.log_config.LEVEL)
	return logger
end

return logging.console

