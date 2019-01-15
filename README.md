# RolesManager
Mod for Battlefield 3 [Venice Unleashed](https://veniceunleashed.net/) made with VeniceExtensions. Roles for players on the server.
## Rcon Commands

* **rm.roles.add <name\>** - Adds a new role
* **rm.roles.rem <name\>** - Deletes an existing role. Defaults roles **Admin** and **User** are not removed! If players have this role then will the role change to **User**!
* **rm.roles.show** - Show all existing roles in database
* **rm.players.add <player_name\> <role_name\>** - Adds or change a role to the player. This is command works if the player on the server!
* **rm.players.rem <guid\>** - Removes the role of the player by **GUID**. Guid format **AAAAAAAA-BBBB-CCCC-DDDD-EEEEEEEEEEEE**
* **rm.players.show** - Show all existing players in database
* **rm.players.get <type\> <value\>** - Types: [ name, guid ]. Shows the role of the player. By default all players have the **User** role. This is command works if the player on the server!