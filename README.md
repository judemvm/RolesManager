# RolesManager
A companion mod for Battlefield 3 [Venice Unleashed](https://veniceunleashed.net/) made with VeniceExtensions.

RolesManager handles roles for users on the server, so that other mods can do role-spesific permissions.

## Rcon Commands

* `rm.roles.add <name>` - Adds a new role.
* `rm.roles.rem <name>` - Deletes an existing role. Players with this role will default to **User**. Defaults roles **Admin** and **User** are not removed! 
* `rm.roles.show` - Show all existing roles in database.
* `rm.players.add <player_name> <role_name>` - Add or change the role of a player. This command only works if the player is connected to the server!
* `rm.players.rem <guid>` - Removes the role of a player by **GUID**. Guid format **AAAAAAAA-BBBB-CCCC-DDDD-EEEEEEEEEEEE**.
* `rm.players.show` - Show all existing players in the database.
* `rm.players.get <type> <value>` - Shows the role of a player. By default all players have the **User** role.

Types: `[ name, guid ]`. The name type only works if the player is connected to the server!
