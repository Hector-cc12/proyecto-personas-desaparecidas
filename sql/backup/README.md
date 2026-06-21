# Plan de Recuperación ante Desastres (DRP) — Paso 2.3

Estrategia de respaldo para `DB_PersonasDesaparecidas` en SQL Server.

## Política de Backups

| Tipo            | Frecuencia       | Retención sugerida |
|-----------------|-------------------|---------------------|
| Completo (FULL) | Semanal           | 4 semanas           |
| Diferencial     | Diario            | 7 días              |
| Log (registros) | Cada hora         | 24 horas            |

## Configuración del modelo de recuperación

```sql
ALTER DATABASE DB_PersonasDesaparecidas SET RECOVERY FULL;
```

## Jobs de SQL Server Agent

Crear 3 jobs en **SQL Server Agent**:

1. **Job_Backup_Full** — semanal (ej. domingo 02:00 AM)
2. **Job_Backup_Diferencial** — diario (excepto el día del full), 02:00 AM
3. **Job_Backup_Log** — cada hora

Ver los scripts T-SQL de ejemplo en `backup_full.sql`, `backup_diferencial.sql` y `backup_log.sql` en esta misma carpeta.

## Restauración (orden)

1. Restaurar el último `FULL` con `NORECOVERY`.
2. Restaurar el `DIFERENCIAL` más reciente posterior al full, con `NORECOVERY`.
3. Restaurar los `LOG` subsecuentes en orden cronológico, el último con `RECOVERY`.
