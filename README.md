SQL-Server-InsertGen-Script
===========================

Script para SQL Server para generar respaldo de registros de forma condicionada.

Agradecimientos a Neeraj Prasad Sharma. Me base en gran parte en un store procedure ya elaborado por el, solo 
lo adecue a las necesidades de mi escenario particular. 

El cambio de nombre a las variables fue hecho para con el unico proposito de facilitar comprension. El 
query original lo tome en su momento del siguiente link:
http://stackoverflow.com/questions/5065357/how-to-generate-an-insert-script-for-an-existing-sql-server-table-that-includes 

Se puede encontrar tambien en :
http://www.sqlservercentral.com/scripts/scripting/94260/

PARAMETROS Y EJEMPLO:
---------------------

DECLARE @BaseDeDatos='AdventureWorksDW2008R2'
DECLARE @Esquema    ='dbo'
DECLARE @Tabla      ='DimAccount'
DECLARE @Where      =' AND AccountCodeAlternateKey>1100 '

NOTAS:
------
-En caso de ser un campo char, varchar o similares	-->	[' AND <campo>=''''<valor>'''' ']
-En caso de ser un campo int, smallint o similares	-->	[' AND <campo>=<valor>			]
-En caso de ser un campo bit (donde <valor> = 0 | 1)-->	[' AND <campo>=<valor>			]
