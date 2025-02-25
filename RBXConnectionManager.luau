local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local RBXConnectionManager = {}
RBXConnectionManager.__index = RBXConnectionManager

-- Constructor
function RBXConnectionManager.new(monitoring_checker_interval: number?, osdate_format: string?)
	local self = setmetatable({}, RBXConnectionManager)
	self._connections = {} :: { [string]: RBXScriptConnection }
	self._internal_connections = {} :: { RBXScriptConnection }
	self._monitoring = {} :: { [string]: any }
	self._osdate_format = osdate_format or "%Y-%m-%d %H:%M:%S"

	-- Cleanup player-specific connections (server-side feature)
	if RunService:IsServer() then
		local globalPlayersRemovingConnection = Players.PlayerRemoving:Connect(function(playerObj: Player)
			self:DisconnectAllInGroup(tostring(playerObj.UserId))
		end)
		table.insert(self._internal_connections, globalPlayersRemovingConnection)
	end

	self:StartMonitoring(monitoring_checker_interval)

	return self
end

-- Add a connection
function RBXConnectionManager:Connect(name: string, event: RBXScriptSignal, callback, monitoring: boolean?): RBXScriptConnection
	if self._connections[name] then
		-- Disconnect and replace the existing connection
		self:Disconnect(name)
		self._connections[name] = nil
	end

	-- Enable monitoring if specified
	if monitoring == true then
		self._monitoring[name] = {}
		local original_callback = callback
		callback = function(...)
			-- Log the data with date time format
			table.insert(self._monitoring[name], {
				date_time = os.date(self._osdate_format),
				arguments = { ... },
			})

			-- Execute the original callback
			original_callback(...)
		end
	end

	-- Create the connection
	local connection = event:Connect(callback)
	self._connections[name] = connection

	return connection
end

-- Disconnect connection by name
function RBXConnectionManager:Disconnect(name: string)
	local connection = self._connections[name]
	if connection and connection.Connected then
		connection:Disconnect()
		self._connections[name] = nil
	end
end

-- Disconnect all connections within a specific group
function RBXConnectionManager:DisconnectAllInGroup(group: string)
	for name, connection in pairs(self._connections) do
		if string.find(name, group) then
			if connection.Connected then
				connection:Disconnect()
			end
			self._connections[name] = nil
		end
	end
end

-- Disconnect all connections
function RBXConnectionManager:DisconnectAll()
	for _, connection in pairs(self._connections) do
		if connection.Connected then
			connection:Disconnect()
		end
	end
	self._connections = {}
end

-- Self-destruct
function RBXConnectionManager:Destroy()
	-- Disconnect the module's internal connections
	for _, connection in pairs(self._internal_connections) do
		if connection.Connected then
			connection:Disconnect()
		end
	end
	self._internal_connections = {}

	self:DisconnectAll()
	setmetatable(self, nil)
end

-- Get monitoring results gathered until now
function RBXConnectionManager:GetAllMonitoringData()
	for connection_name, monitoring_data in self._monitoring do
		if not monitoring_data or type(monitoring_data) ~= "table" then
			warn("Monitoring disabled for " .. connection_name)
		else
			local total_logs = #monitoring_data
			for i, log in ipairs(monitoring_data) do
				warn(
					"Monitoring log for " .. connection_name .. ": #" .. tostring(i) .. "/" .. tostring(total_logs),
					log
				)
			end
		end
	end
end

-- Will show up new monitoring results when collected
function RBXConnectionManager:StartMonitoring(checker_interval: number?)
	task.spawn(function()
		-- Store latest known logs for each connection
		local last_log_counts = {}

		while task.wait(checker_interval or 1) do
			for connection_name, monitoring_data in pairs(self._monitoring) do
				-- Check if monitoring is enabled for this connection
				if type(monitoring_data) == "table" then
					local previous_count = last_log_counts[connection_name] or 0
					local current_count = #monitoring_data

					-- If there are new logs, show them
					if current_count > previous_count then
						for i = previous_count + 1, current_count do
							local log = monitoring_data[i]
							warn(
								"Monitoring log for "
									.. connection_name
									.. ": #"
									.. tostring(i)
									.. "/"
									.. tostring(current_count),
								log
							)
						end

						-- Update latest known log count
						last_log_counts[connection_name] = current_count
					end
				end
			end
		end
	end)
end

return RBXConnectionManager
