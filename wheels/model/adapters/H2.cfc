<cfcomponent extends="Base" output="false">

	<cffunction name="$generatedKey" returntype="string" access="public" output="false">
		<cfreturn "generated_key">
	</cffunction>

	<cffunction name="$randomOrder" returntype="string" access="public" output="false">
		<cfreturn "RAND()">
	</cffunction>

	<cffunction name="$getType" returntype="string" access="public" output="false">
		<cfargument name="type" type="string" required="true">
		<cfscript>
			var loc = {};
			loc.returnValue = "";
			switch(arguments.type)
			{
				case "bigint": case "int8": {loc.returnValue = "cf_sql_bigint"; break;}
				case "binary": case "bytea": case "raw": {loc.returnValue = "cf_sql_binary"; break;}
				case "bit": case "bool": case "boolean": {loc.returnValue = "cf_sql_bit"; break;}
				case "blob": case "tinyblob": case "mediumblob": case "longblob": case "image": case "oid": {loc.returnValue = "cf_sql_blob"; break;}
				case "char": case "character": case "nchar": {loc.returnValue = "cf_sql_char"; break;}
				case "date": {loc.returnValue = "cf_sql_date"; break;}
				case "dec": case "decimal": case "number": case "numeric": {loc.returnValue = "cf_sql_decimal"; break;}
				case "double": {loc.returnValue = "cf_sql_double"; break;}
				case "float": case "float4": case "float8": case "real": {loc.returnValue = "cf_sql_float"; break;}
				case "int": case "int4": case "integer": case "mediumint": case "signed": {loc.returnValue = "cf_sql_integer"; break;}
				case "int2": case "smallint": case "year": {loc.returnValue = "cf_sql_smallint"; break;}
				case "time": {loc.returnValue = "cf_sql_time"; break;}
				case "datetime": case "smalldatetime": case "timestamp": {loc.returnValue = "cf_sql_timestamp"; break;}
				case "tinyint": {loc.returnValue = "cf_sql_tinyint"; break;}
				case "varbinary": case "longvarbinary": {loc.returnValue = "cf_sql_varbinary"; break;}
				case "varchar": case "varchar2": case "longvarchar": case "nvarchar": case "nvarchar2": case "clob": case "nclob": case "text": case "tinytext": case "mediumtext": case "longtext": case "ntext": {loc.returnValue = "cf_sql_varchar"; break;}
			}
		</cfscript>
		<cfreturn loc.returnValue>
	</cffunction>

	<cffunction name="$query" returntype="struct" access="public" output="false">
		<cfargument name="sql" type="array" required="true">
		<cfargument name="limit" type="numeric" required="false" default=0>
		<cfargument name="offset" type="numeric" required="false" default=0>
		<cfargument name="parameterize" type="boolean" required="true">
		<cfargument name="$primaryKey" type="string" required="false" default="">
		<cfscript>
			var loc = {};
			arguments.sql = $removeColumnAliasesInOrderClause(arguments.sql);
			arguments.sql = $addColumnsToSelectAndGroupBy(arguments.sql);
			loc.returnValue = $performQuery(argumentCollection=arguments);
		</cfscript>
		<cfreturn loc.returnValue>
	</cffunction>

	<cffunction name="$identitySelect" returntype="any" access="public" output="false">
		<cfargument name="queryAttributes" type="struct" required="true">
		<cfargument name="result" type="struct" required="true">
		<cfargument name="primaryKey" type="string" required="true">
		<cfset var loc = {}>
		<cfset var query = {}>
		<cfset loc.sql = Trim(arguments.result.sql)>
		<cfif Left(loc.sql, 11) IS "INSERT INTO" AND NOT StructKeyExists(arguments.result, $generatedKey())>
			<cfset loc.startPar = Find("(", loc.sql) + 1>
			<cfset loc.endPar = Find(")", loc.sql)>
			<cfset loc.columnList = ReplaceList(Mid(loc.sql, loc.startPar, (loc.endPar-loc.startPar)), "#Chr(10)#,#Chr(13)#, ", ",,")>
			<cfif NOT ListFindNoCase(loc.columnList, ListFirst(arguments.primaryKey))>
				<cfset loc.returnValue = {}>
				<cfquery attributeCollection="#arguments.queryAttributes#">SELECT LAST_INSERT_ID() AS lastId</cfquery>
				<cfset loc.returnValue[$generatedKey()] = query.name.lastId>
				<cfreturn loc.returnValue>
			</cfif>
		</cfif>
	</cffunction>

<!--- 	<cffunction name="$getColumns" returntype="query" access="public" output="false">
		<cfscript>
			var loc = {};
			loc.returnValue = "";

			// get column details using cfdbinfo in the base adapter
			loc.columns = super.$getColumns(argumentCollection=arguments);

			if (application.wheels.serverName NEQ "Railo")
			{
				return loc.columns;
			}

			// since cfdbinfo incorrectly returns information_schema tables we need to create a new query result that excludes these tables
			loc.returnValue = QueryNew(loc.columns.columnList);
			loc.iEnd = loc.columns.recordCount;
			for (loc.i=1; loc.i <= loc.iEnd; loc.i++)
			{
				if (loc.columns["table_schem"][loc.i] != "information_schema")
				{
					QueryAddRow(loc.returnValue);
					loc.jEnd = ListLen(loc.columns.columnList);
					for (loc.j=1; loc.j <= loc.jEnd; loc.j++)
					{
						loc.columnName = ListGetAt(loc.columns.columnList, loc.j);
						QuerySetCell(loc.returnValue, loc.columnName, loc.columns[loc.columnName][loc.i]);
					}
				}
			}
			return loc.returnValue;
		</cfscript>
	</cffunction> --->

	<cffunction name="$getColumnInfo" returntype="query" access="public" output="false">
		<cfargument name="table" type="string" required="true">
		<cfargument name="datasource" type="string" required="true">
		<cfargument name="username" type="string" required="true">
		<cfargument name="password" type="string" required="true">
		<cfscript>
		var loc = {};
		loc.args = duplicate(arguments);
		StructDelete(loc.args, "table");
		if (!Len(loc.args.username))
		{
			StructDelete(loc.args, "username");
		}
		if (!Len(loc.args.password))
		{
			StructDelete(loc.args, "password");
		}
		loc.args.name = "loc.returnValue";
		</cfscript>
		<cfquery attributeCollection="#loc.args#">
		SELECT
			cols.CHARACTER_OCTET_LENGTH  CHARACTER_OCTET_LENGTH
			,cols.COLUMN_DEFAULT  COLUMN_DEFAULT_VALUE
			,cols.COLUMN_NAME  COLUMN_NAME
			,cols.CHARACTER_MAXIMUM_LENGTH COLUMN_SIZE
			,cols.NUMERIC_SCALE DECIMAL_DIGITS
			,CASE WHEN fks.COLUMN_LIST IS NULL THEN 0 ELSE 1 END IS_FOREIGNKEY
			,cols.IS_NULLABLE IS_NULLABLE
			,CASE WHEN pks.COLUMN_LIST IS NULL THEN 0 ELSE 1 END IS_PRIMARYKEY
			,'' REFERENCED_PRIMARYKEY
			,'' REFERENCED_PRIMARYKEY_TABLE
			,cols.ORDINAL_POSITION ORDINAL_POSITION
			,cols.REMARKS REMARKS
			,cols.TYPE_NAME TYPE_NAME
		FROM
			INFORMATION_SCHEMA.COLUMNS cols
			LEFT OUTER JOIN INFORMATION_SCHEMA.CONSTRAINTS pks
				ON pks.table_name = cols.table_name
				AND pks.CONSTRAINT_TYPE = 'PRIMARY KEY'
				AND POSITION(cols.COLUMN_NAME, pks.COLUMN_LIST)
			LEFT OUTER JOIN INFORMATION_SCHEMA.CONSTRAINTS fks
				ON fks.table_name = cols.table_name
				AND fks.CONSTRAINT_TYPE = 'REFERENTIAL'
				AND POSITION(cols.COLUMN_NAME, fks.COLUMN_LIST)
		WHERE
			cols.table_name = '#UCase(arguments.table)#'
			AND cols.TABLE_SCHEMA <> 'INFORMATION_SCHEMA'
		ORDER BY
			cols.ordinal_position
		</cfquery>
		<!---
		wheels catches the error and raises a Wheels.TableNotFound error
		to mimic this we will throw an error if the query result is empty
		 --->
		<cfif !loc.returnValue.RecordCount>
			<cfthrow/>
		</cfif>
		<cfreturn loc.returnValue>
	</cffunction>

	<cfinclude template="../../plugins/injection.cfm">

</cfcomponent>