/* Backup FULL semanal */
BACKUP DATABASE DB_PersonasDesaparecidas
TO DISK = 'C:\Backups\DB_PersonasDesaparecidas_FULL.bak'
WITH FORMAT, INIT, COMPRESSION,
NAME = 'Backup Completo - DB_PersonasDesaparecidas';
GO
