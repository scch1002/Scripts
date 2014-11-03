DECLARE @table AS NVARCHAR(MAX)

DECLARE update_cursor CURSOR FOR
	SELECT TABLE_NAME FROM information_schema.tables

OPEN update_cursor

FETCH NEXT FROM update_cursor 
	INTO @table

WHILE @@FETCH_STATUS = 0
BEGIN

	DECLARE @Columns AS NVARCHAR(MAX) = ''
	DECLARE @Column AS NVARCHAR(4000) = ''

	DECLARE column_cursor CURSOR FOR
		SELECT COLUMN_NAME FROM information_schema.Columns WHERE TABLE_NAME = @table

	OPEN column_cursor

	FETCH NEXT FROM column_cursor 
	INTO @Column

	WHILE @@FETCH_STATUS = 0
	BEGIN

		SET @Columns = @Columns + ', ' + @Column

		FETCH NEXT FROM column_cursor 
		INTO @Column
	END

	CLOSE column_cursor
	DEALLOCATE column_cursor
	
	SET @Columns = RIGHT(@Columns, LEN(@Columns) - 2)

	EXEC(' 
		IF OBJECTPROPERTY( OBJECT_ID(''' + @table + '''), ''TableHasIdentity'') = 1
		BEGIN
			SET IDENTITY_INSERT [dbo].[' + @table + '] ON
		END
		TRUNCATE TABLE [dbo].['+ @table + ']
		INSERT INTO [dbo].['+ @table +'] (
		' + @Columns + '
		)
		SELECT
		' + @Columns + '
		FROM [Test1].[dbo].['+ @table +']
	')	
	
	FETCH NEXT FROM update_cursor 
		INTO @table
END

CLOSE update_cursor
DEALLOCATE update_cursor