class 'RolesManagerServer'


function RolesManagerServer:__init()
	print("Initializing RolesManagerServer")
	self:DBCheck()
	self:RegisterCommands()
end

function RolesManagerServer:DBCheckTable(name)
	if not SQL:Open() then
			return 0
	end

	m_result = SQL:Query('SELECT count(*) AS "res" FROM sqlite_master WHERE type="table" AND name="'..SQL:Escape(name)..'"')
	if not m_result then
			return 0
	end
	SQL:Close()
	for _, row in pairs(m_result) do
		if row.res == 1 then
			return 1
		else
			return 0
		end
	end
end

function RolesManagerServer:DBCheck()
	if self:DBCheckTable('rm_roles') == 1 and self:DBCheckTable('rm_players') == 1 then
		print('Database found!')
		return
	else
		self:DBRegister()
		return 
	end
end

function RolesManagerServer:DBRegister()
	if not SQL:Open() then
			return
	end
	print('Database begin creation..')
	
	m_query = [[
			CREATE TABLE IF NOT EXISTS `rm_roles` (
				`id`	INTEGER PRIMARY KEY AUTOINCREMENT,
				`name`	TEXT
			)
	]]

	m_result = SQL:Query(m_query)
	if not m_result then
			print('Failed to execute query: ' .. SQL:Error())
			return
	end

	m_query = [[
			CREATE TABLE IF NOT EXISTS `rm_players` (
				`name`	TEXT,
				`guid`	TEXT,
				`role`	TEXT,
				FOREIGN KEY(`role`) REFERENCES `rm_roles`(`name`)
			)
	]]

	m_result = SQL:Query(m_query)
	if not m_result then
			print('Failed to execute query: ' .. SQL:Error())
			return
	end

	m_query = [[
			INSERT INTO `rm_roles` VALUES (1,'admin')
	]]

	m_result = SQL:Query(m_query)
	if not m_result then
			print('Failed to execute query: ' .. SQL:Error())
			return
	end

	m_query = [[
			INSERT INTO `rm_roles` VALUES (2,'user')
	]]

	m_result = SQL:Query(m_query)
	if not m_result then
			print('Failed to execute query: ' .. SQL:Error())
			return
	end

	SQL:Close()
	print('Database successfully created!')
end

function RolesManagerServer:RegisterCommands()
	local m_command_name = 'rm.roles.add'
	local commandAddRole = RCON:RegisterCommand(m_command_name, RemoteCommandFlag.RequiresLogin, "", self.OnAddRole)
	if commandAddRole == 0 then
		print('Failed to register RCON command: '..m_command_name)
	else
		print('Registered new RCON command: '.. m_command_name .. ' ['.. commandAddRole ..']')
	end

	m_command_name = 'rm.roles.rem'
	local commandRemRole = RCON:RegisterCommand(m_command_name, RemoteCommandFlag.RequiresLogin, "", self.OnRemRole)
	if commandRemRole == 0 then
		print('Failed to register RCON command: '..m_command_name)
	else
		print('Registered new RCON command: '.. m_command_name .. ' ['.. commandRemRole ..']')
	end

	m_command_name = 'rm.roles.show'
	local commandShowRoles = RCON:RegisterCommand(m_command_name, RemoteCommandFlag.RequiresLogin, "", self.OnShowRoles)
	if commandShowRoles == 0 then
		print('Failed to register RCON command: '..m_command_name)
	else
		print('Registered new RCON command: '.. m_command_name .. ' ['.. commandShowRoles ..']')
	end

	m_command_name = 'rm.players.add'
	local commandAddPlayer = RCON:RegisterCommand(m_command_name, RemoteCommandFlag.RequiresLogin, "", self.OnAddPlayer)
	if commandAddPlayer == 0 then
		print('Failed to register RCON command: '..m_command_name)
	else
		print('Registered new RCON command: '.. m_command_name .. ' ['.. commandAddPlayer ..']')
	end

	m_command_name = 'rm.players.rem'
	local commandRemPlayer = RCON:RegisterCommand(m_command_name, RemoteCommandFlag.RequiresLogin, "", self.OnRemPlayer)
	if commandRemPlayer == 0 then
		print('Failed to register RCON command: '..m_command_name)
	else
		print('Registered new RCON command: '.. m_command_name .. ' ['.. commandRemPlayer ..']')
	end

	m_command_name = 'rm.players.show'
	local commandShowPlayers = RCON:RegisterCommand(m_command_name, RemoteCommandFlag.RequiresLogin, "", self.OnShowPlayers)
	if commandShowPlayers == 0 then
		print('Failed to register RCON command: '..m_command_name)
	else
		print('Registered new RCON command: '.. m_command_name .. ' ['.. commandShowPlayers ..']')
	end

	m_command_name = 'rm.players.get'
	local commandGetPlayer = RCON:RegisterCommand(m_command_name, RemoteCommandFlag.RequiresLogin, "", self.OnGetPlayer)
	if commandGetPlayer == 0 then
		print('Failed to register RCON command: '..m_command_name)
	else
		print('Registered new RCON command: '.. m_command_name .. ' ['.. commandGetPlayer ..']')
	end
end

function RolesManagerServer:OnAddRole(command, args, loggedIn)
	if command[1] == nil then
		return { 'NO', 'NO ALL ARG! Example: rm.roles.add <name>' }
	end

	m_role_name = string.lower(command[1]);

	if string.match(m_role_name, "name") then
		return { 'NO', 'ARGUMENT ROLE = NAME IS PROHIBITED' }
	end

	if not SQL:Open() then
		return { 'ERROR', 'SQL ERROR' }
	end

	m_result = SQL:Query('SELECT count(*) AS "res" FROM rm_roles WHERE name="'..SQL:Escape(m_role_name)..'"')
 
	if not m_result then
			print('Failed to execute query: ' .. SQL:Error())
			SQL:Close()
			return { 'ERROR', 'SQL ERROR' }
	end

	-- Print the fetched rows.
	m_role_status = 0
	for _, row in pairs(m_result) do
		m_role_status = row.res
	end

	if m_role_status == 1 then
		SQL:Close()
		return { 'NO', 'THIS ROLE ALREADY EXISTS' }
	end

	m_result = SQL:Query('INSERT INTO rm_roles (name) VALUES ("'..SQL:Escape(m_role_name)..'")')
 
	if not m_result then
			print('Failed to execute query: ' .. SQL:Error())
			SQL:Close()
			return { 'ERROR', 'SQL ERROR' }
	end

	SQL:Close()
	return {'OK'}
end

function RolesManagerServer:OnRemRole(command, args, loggedIn)
	if command[1] == nil then
		return { 'NO', 'NO ALL ARG! Example: rm.roles.rem <name>' }
	end

	m_role_name = string.lower(command[1]);

	if string.match(m_role_name, "role") then
		return { 'NO', 'ARGUMENT ROLE = ROLE IS PROHIBITED' }
	end

	if string.match(m_role_name, 'admin') or string.match(m_role_name, 'user') then
		return { 'NO', 'ROLES ADMIN AND USER CANNOT BE REMOVED' }
	end

	if not SQL:Open() then
		return { 'ERROR', 'SQL ERROR' }
	end

	m_result = SQL:Query('SELECT count(*) AS "res" FROM rm_roles WHERE name="'..SQL:Escape(m_role_name)..'"')
 
	if not m_result then
			print('Failed to execute query: ' .. SQL:Error())
			SQL:Close()
			return { 'ERROR', 'SQL ERROR' }
	end

	m_role_status = 0
	for _, row in pairs(m_result) do
		m_role_status = row.res
	end

	if m_role_status == 0 then
		SQL:Close()
		return { 'NO', 'THE ROLE IS NOT FOUND' }
	end

	m_result = SQL:Query('UPDATE rm_players SET role = "user" WHERE role="'..SQL:Escape(m_role_name)..'"')
 
	if not m_result then
			print('Failed to execute query: ' .. SQL:Error())
			SQL:Close()
			return { 'ERROR', 'SQL ERROR' }
	end

	m_result = SQL:Query('DELETE FROM rm_roles WHERE name="'..SQL:Escape(m_role_name)..'"')
 
	if not m_result then
			print('Failed to execute query: ' .. SQL:Error())
			SQL:Close()
			return { 'ERROR', 'SQL ERROR' }
	end

	SQL:Close()
	return {'OK'}
end

function RolesManagerServer:OnShowRoles(command, args, loggedIn)
	if not SQL:Open() then
		return { 'ERROR', 'SQL ERROR' }
	end

	m_result = SQL:Query('SELECT name FROM rm_roles')
 
	if not m_result then
			print('Failed to execute query: ' .. SQL:Error())
			SQL:Close()
			return { 'ERROR', 'SQL ERROR' }
	end

	SQL:Close()
	return { 'OK', dump(m_result) }
end

function RolesManagerServer:OnAddPlayer(command, args, loggedIn)
	if command[1] == nil or command[2] == nil then
		return { 'NO', 'NO ALL ARG! Example: rm.players.add <player_name> <role_name>' }
	end

	m_player_name = command[1];
	m_role_name = string.lower(command[2]);
	m_Player = nil;

	if string.match(m_role_name, "name") or string.match(m_role_name, "role") then
		return { 'NO', 'ARGUMENT ROLE = NAME OR ROLE = ROLE IS PROHIBITED' }
	end

	local s_Players = PlayerManager:GetPlayers()
	for s_Index, s_Player in pairs(s_Players) do
		if string.match(s_Player.name, m_player_name) then
				m_Player = s_Player
			break
		end
	end

	if m_Player == nil then
		return { 'NO', 'PLAYER NOT FOUND' }
	end

	if not SQL:Open() then
		return { 'ERROR', 'SQL ERROR' }
	end

	m_result = SQL:Query('SELECT count(*) AS "res" FROM rm_roles WHERE name="'..SQL:Escape(m_role_name)..'"')
 
	if not m_result then
			print('Failed to execute query: ' .. SQL:Error())
			SQL:Close()
			return { 'ERROR', 'SQL ERROR' }
	end

	m_role_status = 0
	for _, row in pairs(m_result) do
		m_role_status = row.res
	end

	if m_role_status == 0 then
		SQL:Close()
		return { 'NO', 'THIS ROLE NOT FOUND' }
	end

	m_result = SQL:Query('SELECT count(*) AS "res" FROM rm_players WHERE guid="'..tostring(m_Player.guid)..'" ')
 
	if not m_result then
			print('Failed to execute query: ' .. SQL:Error())
			SQL:Close()
			return { 'ERROR', 'SQL ERROR' }
	end

	m_player_status = 0
	for _, row in pairs(m_result) do
		m_player_status = row.res
	end

	if m_player_status == 1 then
		m_result = SQL:Query('UPDATE rm_players SET role = "'..SQL:Escape(m_role_name)..'" WHERE guid="'..tostring(m_Player.guid)..'"')
		if not m_result then
				print('Failed to execute query: ' .. SQL:Error())
				SQL:Close()
				return { 'ERROR', 'SQL ERROR' }
		end
		SQL:Close()
		return {'OK'}
	end

	m_result = SQL:Query('INSERT INTO rm_players (name, guid, role) VALUES ("'..SQL:Escape(m_Player.name)..'","'..tostring(m_Player.guid)..'","'..SQL:Escape(m_role_name)..'")')
 
	if not m_result then
			print('Failed to execute query: ' .. SQL:Error())
			SQL:Close()
			return { 'ERROR', 'SQL ERROR' }
	end

	SQL:Close()
	return {'OK'}
end

function RolesManagerServer:OnRemPlayer(command, args, loggedIn)
	if command[1] == nil then
		return { 'NO', 'NO ALL ARG! Example: rm.players.rem <guid>' }
	end

	m_player_guid = command[1];

	if not SQL:Open() then
		return { 'ERROR', 'SQL ERROR' }
	end

	m_result = SQL:Query('SELECT count(*) AS "res" FROM rm_players WHERE guid="'..SQL:Escape(m_player_guid)..'" ')
 
	if not m_result then
			print('Failed to execute query: ' .. SQL:Error())
			SQL:Close()
			return { 'ERROR', 'SQL ERROR' }
	end

	-- Print the fetched rows.
	m_player_status = 0
	for _, row in pairs(m_result) do
		m_player_status = row.res
	end

	if m_player_status == 1 then
		m_result = SQL:Query('DELETE FROM rm_players WHERE guid="'..SQL:Escape(m_player_guid)..'"')

		if not m_result then
				print('Failed to execute query: ' .. SQL:Error())
				SQL:Close()
				return { 'ERROR', 'SQL ERROR' }
		end

		SQL:Close()
		return {'OK'}
	end

	SQL:Close()
	return { 'NO', 'PLAYER NOT FOUND' }
end

function RolesManagerServer:OnShowPlayers(command, args, loggedIn)
	if not SQL:Open() then
		return { 'ERROR', 'SQL ERROR' }
	end

	m_result = SQL:Query('SELECT * FROM rm_players')
 
	if not m_result then
			print('Failed to execute query: ' .. SQL:Error())
			SQL:Close()
			return { 'ERROR', 'SQL ERROR' }
	end

	SQL:Close()
	return { 'OK', dump(m_result) }
end

function RolesManagerServer:OnGetPlayer(command, args, loggedIn)
	if command[1] == nil or command[2] == nil then
		return { 'NO', 'NO ALL ARG! Types: [ name, guid ]. Example: rm.players.get <type> <value>' }
	end

	m_type = string.lower(command[1]);
	m_value = command[2];

	if string.match(m_type, 'guid') then
		m_Player = nil;

		local s_Players = PlayerManager:GetPlayers()
		for s_Index, s_Player in pairs(s_Players) do
			if s_Player.guid == Guid(m_value) then
					m_Player = s_Player
				break
			end
		end

		if m_Player == nil then
			return { 'NO', 'PLAYER NOT FOUND' }
		end

		if not SQL:Open() then
			return { 'ERROR', 'SQL ERROR' }
		end

		m_result = SQL:Query('SELECT role FROM rm_players WHERE guid="'..tostring(m_Player.guid)..'" ')
 
		if not m_result then
				print('Failed to execute query: ' .. SQL:Error())
				SQL:Close()
				return { 'ERROR', 'SQL ERROR' }
		end

		SQL:Close()

		for _, row in pairs(m_result) do
			return { row.role}
		end

		return {'user'}
	end

	if string.match(m_type, 'name') then
		m_Player = nil;

		local s_Players = PlayerManager:GetPlayers()
		for s_Index, s_Player in pairs(s_Players) do
			if string.match(s_Player.name, m_value) then
					m_Player = s_Player
				break
			end
		end

		if m_Player == nil then
			return { 'NO', 'PLAYER NOT FOUND' }
		end

		if not SQL:Open() then
			return { 'ERROR', 'SQL ERROR' }
		end

		m_result = SQL:Query('SELECT role FROM rm_players WHERE name="'..SQL:Escape(tostring(m_Player.name))..'" ')
 
		if not m_result then
				print('Failed to execute query: ' .. SQL:Error())
				SQL:Close()
				return { 'ERROR', 'SQL ERROR' }
		end

		SQL:Close()

		for _, row in pairs(m_result) do
			return { row.role}
		end
		return {'user'}
	end
	if string.match(m_type, 'guid') == nil and string.match(m_type, 'name') == nil then
		return { 'NO', 'INVALID FIST ARGUMENT' }
	end
end

function string:split(sep)
	local sep, fields = sep or " ", {}
	local pattern = string.format("([^%s]+)", sep)
	self:gsub(pattern, function(c) fields[#fields+1] = c end)
	return fields
 end
 
 function dump(o)
	if type(o) == 'table' then
	   local s = '{ '
	   for k,v in pairs(o) do
		  if type(k) ~= 'number' then k = '"'..k..'"' end
		  s = s .. '['..k..'] = ' .. dump(v) .. ','
	   end
	   return s .. '} '
	else
	   return tostring(o)
	end
 end

g_RolesManagerServer = RolesManagerServer()

