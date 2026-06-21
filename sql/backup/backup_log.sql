/* Backup de LOG de transacciones - cada hora */
BACKUP LOG DB_PersonasDesaparecidas
TO DISK = 'C:\Backups\DB_PersonasDesaparecidas_LOG.trn'
WITH COMPRESSION,
NAME = 'Backup de Log - DB_PersonasDesaparecidas';
GO
