# cwRsync
This cwRsync script is used to sync (archive) data from a QNAP NAS to an external TerraMaster DAS so that the data can be backed up to a Backblaze WIndows computer backup (Backblaze will not backup mapped network drives but it will back up USB and Thunderbolt direct attached storage). Windows does not have any native rsync capbilities but itefix.net has created a Windows port of rsync. The server portion of the program is a commercial paid product, but the client piece of the software is free.

The client software can he fouind here - https://github.com/itefixnet/cwrsync-client
