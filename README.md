# RBXConnectionManager

This is our first open-source release. Please add a ⭐ if you like the idea of this project or if you like to use it.

Consider joining our community aswell! https://discord.gg/8ed3W53kHv/ to see progress on our very advanced projects!

## Overview
RBXConnectionManager is a lightweight and efficient module for managing `RBXScriptConnection` objects in Roblox. It allows for easy connection handling, automatic cleanup, and optional event monitoring.

## Features
- **Efficient Connection Management**: Easily create, store, and disconnect connections by name.
- **Automatic Cleanup**: Removes player-specific connections when a player leaves (server-side only).
- **Batch Disconnection**: Disconnect all connections or those within a specific group.
- **Monitoring**: Logs and displays event calls along with timestamps.
- **Self-Destruction**: Provides a method to completely clean up the manager.

---

## Installation
1. Add `RBXConnectionManager.lua` to your Roblox project.
2. Require the module where needed:
   ```lua
   local RBXConnectionManager = require(path.to.RBXConnectionManager)
   ```
---

## Usage

### Creating an Instance
```lua
local connectionManager = RBXConnectionManager.new()
```

### Adding Connections
```lua
local myEvent = game.ReplicatedStorage.SomeRemoteEvent

connectionManager:Connect("ExampleConnection", myEvent.OnServerEvent, function(player, data)
    print("Event triggered by:", player.Name, "with data:", data)
end, true) -- Enable monitoring
```

### Disconnecting a Specific Connection
```lua
connectionManager:Disconnect("ExampleConnection")
```

### Disconnecting All Connections in a Group
```lua
connectionManager:DisconnectAllInGroup(tostring(player.UserId))
```

### Disconnecting All Connections
```lua
connectionManager:DisconnectAll()
```

### Retrieving Monitoring Logs
```lua
connectionManager:GetAllMonitoringData()
```

### Destroying the Manager
```lua
connectionManager:Destroy()
```

---

## Notes
- On the **server-side**, connections linked to a player will be automatically removed when they leave.
- Monitoring can be useful for debugging event calls, but it may have performance implications if used excessively.
- The module is designed to work efficiently in both **server-side** and **client-side** scripts.

---

## Open-source
This module is open-source and free to use in any Roblox project. Contributions and improvements are welcome!
