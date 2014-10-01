/*
Agradecimientos a Neeraj Prasad Sharma. Me base en gran parte en un store procedure ya elaborado por el, solo 
lo adecue a las necesidades de mi escenario particular. 

El cambio de nombre a las variables fue hecho para con el unico proposito de facilitar comprension. El 
query original lo tome en su momento del siguiente link:
http://stackoverflow.com/questions/5065357/how-to-generate-an-insert-script-for-an-existing-sql-server-table-that-includes 

Se puede encontrar tambien en :
http://www.sqlservercentral.com/scripts/scripting/94260/
*/ 
SET NOCOUNT ON                  
--VARIABLES-------------------------------------------------------
DECLARE @BaseDeDatos VARCHAR(50)='AdventureWorksDW2008R2'
DECLARE @Esquema CHAR(3)='dbo'
DECLARE @Tabla VARCHAR(100)='DimAccount'
DECLARE @Where VARCHAR(MAX)=' AND AccountCodeAlternateKey>1100 '
/*NOTAS PARA WHERE
-En caso de ser un campo char, varchar o similares	-->	[' AND <campo>=''''<valor>'''' ']
-En caso de ser un campo int, smallint o similares	-->	[' AND <campo>=<valor>			]
-En caso de ser un campo bit (donde <valor> = 0 | 1)-->	[' AND <campo>=<valor>			]
*/
--VARIABLES DE ENTORNO--------------------------------------------
DECLARE @Query VARCHAR(MAX)=''
DECLARE @BDActual VARCHAR(75)=(SELECT DB_NAME())

IF (@Where IS  NULL)
	BEGIN                             
		SET @Where=' '              
	END

SET @Query='
DECLARE @Columnas  TABLE ([N] SMALLINT , Columna VARCHAR(Max) )  
DECLARE @NoColumnas SMALLINT=0                              
DECLARE @Ciclos SMALLINT=1 
DECLARE @InsertInto VARCHAR(MAX)=''''  
DECLARE @InnerQuery VARCHAR(MAX)=''''

USE '+@BaseDeDatos+'
INSERT INTO @Columnas 
SELECT
ORDINAL_POSITION, 
COLUMN_NAME
FROM Information_schema.columns ISC
WHERE TABLE_SCHEMA='''+@Esquema+                              
  ''' AND TABLE_NAME='''+@Tabla+       
  ''' AND TABLE_CATALOG='''+@BaseDeDatos+
  ''' AND COLUMN_NAME NOT IN (''SyncDestination'',''PendingSyncDestination'',''SkuID'',''SaleCreditedto'')
ORDER BY ISC.ORDINAL_POSITION
USE '+@BDActual+'     

SELECT @NoColumnas= MAX([N]) FROM  @Columnas  

WHILE (@Ciclos<=@NoColumnas )                              
	BEGIN                               
		SELECT @InsertInto= @InsertInto+''[''+Columna+''],''            
		FROM @Columnas                              
		WHERE [N]=@Ciclos                          

		SELECT	@InnerQuery=@InnerQuery+'' +CASE WHEN [''+Columna+''] IS NULL THEN ''''Null'''' ELSE ''''''''''''''''+                              
				REPLACE(CONVERT(VARCHAR(MAX),RTRIM([''+Columna+''])) ,'''''''''''''''',''''''''  )                              
				+'''''''''''''''' END+'+'''+'''''','''''''+'                               
		FROM @Columnas                              
		WHERE [N]=@Ciclos                              

		SET @Ciclos=@Ciclos+1                              
	END     
                             
SELECT @InnerQuery=LEFT(@InnerQuery,LEN(@InnerQuery)-4)              
SELECT @InsertInto= SUBSTRING(@InsertInto,0, LEN(@InsertInto))    
SELECT @InnerQuery='' SELECT  ''+''''''INSERT INTO '+@BaseDeDatos+'.'+@Esquema+'.'+@Tabla+ '''+''(''+@InsertInto+'')'' 
                  +'' VALUES ( ''+'''''''' + ''+''+@InnerQuery+''+''+ '''''')'''' AS [BKINSERTS]''
                  +'' FROM  ' +@BaseDeDatos+'.'+@Esquema+'.'+@Tabla+'(NOLOCK) '' 
                  +'' WHERE 1=1 '+@Where+''''+CHAR(13)+               

+' EXEC (@InnerQuery) '  
EXEC(@Query)
SET NOCOUNT OFF  
