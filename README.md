# Far Cry 2 Docker
A docker container for running a Far Cry 2 server, since the Far Cry 2 Linux server is broken the Windows version is run through Wine.

## Far Cry 2 server files availability
Due to only the broken Linux server that does not include the Fortune's Edition being publicly available from Ubisoft, this container is limited to only official Ubisoft map, not including Fortune's Edition maps.

You may provide the "Data_Win32" folder from the Far Cry 2 game yourself, but it's not already included in this container due to licensing issues.

## Ubisoft backend issues
This docker container resolves the current connection issues with the Ubisoft backand by providing a custom patch similar to that of the FC2MPPatcher available for the game client.
