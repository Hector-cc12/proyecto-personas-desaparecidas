/* Backup DIFERENCIAL diario */
BACKUP DATABASE DB_PersonasDesaparecidas
TO DISK = 'C:\Backups\DB_PersonasDesaparecidas_DIFF.bak'
WITH DIFFERENTIAL, COMPRESSION,
NAME = 'Backup Diferencial - DB_PersonasDesaparecidas';
GO
