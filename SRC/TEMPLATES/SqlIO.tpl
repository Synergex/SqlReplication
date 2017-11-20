<CODEGEN_FILENAME><StructureName>SqlIO.dbl</CODEGEN_FILENAME>
<REQUIRES_CODEGEN_VERSION>5.2.1</REQUIRES_CODEGEN_VERSION>
<PROVIDE_FILE>IsDate.dbl</PROVIDE_FILE>
<PROVIDE_FILE>IsNumeric.dbl</PROVIDE_FILE>
<PROVIDE_FILE>IsTime.dbl</PROVIDE_FILE>
;//*****************************************************************************
;//
;// Title:      SqlIo.tpl
;//
;// Description:Template to generate a collection of Synergy functions which
;//             create and interact with a table in a SQL Server database
;//             whose columns match the fields defined in a Synergy
;//             repository structure.
;//
;// Author:     Steve Ives, Synergex Professional Services Group
;//
;// Copyright   © 2009 Synergex International Corporation.  All rights reserved.
;//
;;*****************************************************************************
;;
;; File:        <StructureName>SqlIO.dbl
;;
;; Type:        Functions
;;
;; Description: Various functions that performs SQL I/O for <STRUCTURE_NAME>
;;
;;*****************************************************************************
;;
;; Copyright (c) 2009, Synergex International, Inc.
;; All rights reserved.
;;
;; Redistribution and use in source and binary forms, with or without
;; modification, are permitted provided that the following conditions are met:
;;
;; * Redistributions of source code must retain the above copyright notice,
;;   this list of conditions and the following disclaimer.
;;
;; * Redistributions in binary form must reproduce the above copyright notice,
;;   this list of conditions and the following disclaimer in the documentation
;;   and/or other materials provided with the distribution.
;;
;; THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
;; AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
;; IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
;; ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
;; LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
;; CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
;; SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
;; INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
;; CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
;; ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
;; POSSIBILITY OF SUCH DAMAGE.
;;
;;*****************************************************************************
;; WARNING: THIS CODE WAS CODE GENERATED AND WILL BE OVERWRITTEN IF CODE
;;          GENERATION IS RE-EXECUTED FOR THIS PROJECT.
;;*****************************************************************************

;;*****************************************************************************
;;; <summary>
;;; Determines if the <StructureName> table exists in the database.
;;; </summary>
;;; <param name="a_dbchn">Connected database channel.</param>
;;; <param name="a_errtxt">Returned error text.</param>
;;; <returns>Returns 1 if the table exists, otherwise a number indicating the type of error.</returns>

function <structure_name>_exists, ^val

	required in  a_dbchn,  i
	optional out a_errtxt, a
	endparams

	.include "CONNECTDIR:ssql.def"

	stack record local_data
		error       ,int    ;;Returned error number
		dberror     ,int    ;;Database error number
		cursor      ,int    ;;Database cursor
		length      ,int    ;;Length of a string
		table_name  ,a128   ;;Retrieved table name
		errtxt      ,a256   ;;Error message text
	endrecord

proc

	init local_data

	;;Open a cursor for the SELECT statement

	if (%ssc_open(a_dbchn,cursor,"SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME='<StructureName>'",SSQL_SELECT)==SSQL_FAILURE)
	begin
		error=-1
		if (%ssc_getemsg(a_dbchn,errtxt,length,,dberror)==SSQL_FAILURE)
			errtxt="Failed to open cursor"
	end

	;;Bind host variables to receive the data

	if (!error)
	begin
		if (%ssc_define(a_dbchn,cursor,1,table_name)==SSQL_FAILURE)
		begin
			error=-1
			if (%ssc_getemsg(a_dbchn,errtxt,length,,dberror)==SSQL_FAILURE)
				errtxt="Failed to bind variable"
		end
	end

	;;Move data to host variables

	if (!error)
	begin
		if (%ssc_move(a_dbchn,cursor,1)==SSQL_NORMAL)
				error = 1 ;; Table exists
	end

	;;Close the database cursor

	if (cursor)
	begin
		if (%ssc_close(a_dbchn,cursor)==SSQL_FAILURE)
		begin
			if (!error)
			begin
				error=-1
				if (%ssc_getemsg(a_dbchn,errtxt,length,,dberror)==SSQL_FAILURE)
					errtxt="Failed to close cursor"
			end
		end
	end

	;;If there was an error message, return it to the calling routine

	if (^passed(a_errtxt))
	begin
		if (error) then
			a_errtxt = errtxt
		else
			a_errtxt = ""
	end

	freturn error

endfunction

;;*****************************************************************************
;;; <summary>
;;; Creates the <StructureName> table in the database.
;;; </summary>
;;; <param name="a_dbchn">Connected database channel.</param>
;;; <param name="a_errtxt">Returned error text.</param>
;;; <returns>Returns true on success, otherwise false.</returns>

function <structure_name>_create, ^val

	required in  a_dbchn,  i
	optional out a_errtxt, a
	endparams

	.include "CONNECTDIR:ssql.def"

	.align
	stack record local_data
		ok          ,boolean    ;;Return status
		dberror     ,int        ;;Database error number
		cursor      ,int        ;;Database cursor
		length      ,int        ;;Length of a string
		transaction ,int        ;;Transaction in process
		errtxt      ,a512       ;;Returned error message text
		sql         ,string     ;;SQL statement
	endrecord

proc

	init local_data
	ok = true

	;;Start a database transaction

	if (%ssc_commit(a_dbchn,SSQL_TXON)==SSQL_NORMAL) then
		transaction=1
	else
	begin
		ok = false
		if (%ssc_getemsg(a_dbchn,errtxt,length,,dberror)==SSQL_FAILURE)
			errtxt="Failed to start transaction"
	end

	;;Create the database table and primary key constraint

	if (ok)
	begin
		sql = 'CREATE TABLE "<StructureName>" ('
		<FIELD_LOOP>
		& + '"<FieldSqlName>" <FIELD_SQLTYPE><IF REQUIRED> NOT NULL</IF><IF LAST><IF STRUCTURE_HAS_UNIQUE_PK>,</IF STRUCTURE_HAS_UNIQUE_PK><ELSE>,</IF LAST>'
		</FIELD_LOOP>
		<IF STRUCTURE_HAS_UNIQUE_PK>
		& + 'CONSTRAINT PK_<StructureName> PRIMARY KEY CLUSTERED(<PRIMARY_KEY><SEGMENT_LOOP>"<SegmentName>" <SEGMENT_ORDER><,></SEGMENT_LOOP></PRIMARY_KEY>)'
		</IF STRUCTURE_HAS_UNIQUE_PK>
		& + ')'

		call open_cursor

		if (ok)
		begin
			call execute_cursor
			call close_cursor
		end
	end

	<IF STRUCTURE_HAS_UNIQUE_PK>
	<ELSE>
	;;The structure has no unique primary key, so no primary key constraint was added to the table. Create an index instead.

	if (ok)
	begin
		sql = '<PRIMARY_KEY>CREATE INDEX IX_<StructureName>_<KeyName> ON "<StructureName>"(<SEGMENT_LOOP>"<SegmentName>" <SEGMENT_ORDER><,></SEGMENT_LOOP>)</PRIMARY_KEY>'

		call open_cursor

		if (ok)
		begin
			call execute_cursor
			call close_cursor
		end
	end

	</IF STRUCTURE_HAS_UNIQUE_PK>
	<ALTERNATE_KEY_LOOP>
	;;Create index <KEY_NUMBER> (<KEY_DESCRIPTION>)

	if (ok)
	begin
		sql = 'CREATE <KEY_UNIQUE> INDEX IX_<StructureName>_<KeyName> ON "<StructureName>"(<SEGMENT_LOOP>"<SegmentName>" <SEGMENT_ORDER><,></SEGMENT_LOOP>)'

		call open_cursor

		if (ok)
		begin
			call execute_cursor
			call close_cursor
		end
	end

	</ALTERNATE_KEY_LOOP>
	;;Grant access permissions

	if (ok)
	begin
		sql = 'GRANT ALL ON "<StructureName>" TO PUBLIC'

		call open_cursor

		if (ok)
		begin
			call execute_cursor
			call close_cursor
		end
	end

	;;Commit or rollback the transaction

	if (transaction)
	begin
		if (ok) then
		begin
			;;Success, commit the transaction
			if (%ssc_commit(a_dbchn,SSQL_TXOFF)==SSQL_FAILURE)
			begin
				ok = false
				if (%ssc_getemsg(a_dbchn,errtxt,length,,dberror)==SSQL_FAILURE)
					errtxt="Failed to commit transaction"
			end
		end
		else
		begin
			;;There was an error, rollback the transaction
			xcall ssc_rollback(a_dbchn,SSQL_TXOFF)
		end
	end

	;;If there was an error message, return it to the calling routine

	if (^passed(a_errtxt))
	begin
		if (ok) then
			a_errtxt = ""
		else
			a_errtxt = errtxt
	end

	freturn ok

open_cursor,

	if (%ssc_open(a_dbchn,cursor,(a)sql,SSQL_NONSEL)==SSQL_FAILURE)
	begin
		ok = false
		if (%ssc_getemsg(a_dbchn,errtxt,length,,dberror)==SSQL_FAILURE)
			errtxt="Failed to open cursor"
	end

	return

execute_cursor,

	if (%ssc_execute(a_dbchn,cursor,SSQL_STANDARD)==SSQL_FAILURE)
	begin
		ok = false
		if (%ssc_getemsg(a_dbchn,errtxt,length,,dberror)==SSQL_FAILURE)
			errtxt="Failed to execute SQL statement"
	end

	return

close_cursor,

	if (cursor)
	begin
		if (%ssc_close(a_dbchn,cursor)==SSQL_FAILURE)
		begin
			if (ok)
			begin
				ok = false
				if (%ssc_getemsg(a_dbchn,errtxt,length,,dberror)==SSQL_FAILURE)
					errtxt="Failed to close cursor"
			end
		end
		clear cursor
	end

	return

endfunction

;;*****************************************************************************
;;; <summary>
;;; Insert a row into the <StructureName> table.
;;; </summary>
;;; <param name="a_dbchn">Connected database channel.</param>
;;; <param name="a_data">Record to be inserted.</param>
;;; <param name="a_errtxt">Returned error text.</param>
;;; <returns>Returns 1 if the row was inserted, 2 to indicate the row already exists, or 0 if an error occurred.</returns>

function <structure_name>_insert_row, ^val

	required in  a_dbchn,  i
	required in  a_data,   a
	optional out a_errtxt, a
	endparams

	.include "CONNECTDIR:ssql.def"

	.align
	stack record local_data
		ok          ,boolean    ;;OK to continue
		openAndBind	,boolean	;;Should we open the cursor and bind data this time?
		sts         ,int        ;;Return status
		dberror     ,int        ;;Database error number
		transaction ,int        ;;Transaction in progress
		length      ,int        ;;Length of a string
		errtxt      ,a256       ;;Error message text
	endrecord

	literal
		sql         ,a*, "INSERT INTO <StructureName> ("
		<FIELD_LOOP>
		& +              '"<FieldSqlName>"<,>'
		</FIELD_LOOP>
		& +              ") VALUES(<FIELD_LOOP><IF USERTIMESTAMP>CONVERT(DATETIME2,:<FIELD#LOGICAL>,21)<,><ELSE>:<FIELD#LOGICAL><,></IF USERTIMESTAMP></FIELD_LOOP>)"
	endliteral

	.include "<STRUCTURE_NOALIAS>" repository, static record="<structure_name>", end

	static record
		<FIELD_LOOP>
		<IF USERTIMESTAMP>
		tmp<FieldSqlName>, a26     ;;Storage for user-defined timestamp field
		<ELSE>
		<IF TIME_HHMM>
		tmp<FieldSqlName>, a5      ;;Storage for HH:MM time field
		</IF TIME_HHMM>
		<IF TIME_HHMMSS>
		tmp<FieldSqlName>, a7      ;;Storage for HH:MM:SS time field
		</IF TIME_HHMMSS>
		</IF USERTIMESTAMP>
		</FIELD_LOOP>
		,a1                         ;;In case there are no user timestamp, date or JJJJJJ date fields
	endrecord

	global common
		csr_<structure_name>_insert1, i4, 0
	endcommon

proc

	init local_data
	ok = true
	sts = 1
	openAndBind = (csr_<structure_name>_insert1 == 0)

	;;Start a database transaction

	if (%ssc_commit(a_dbchn,SSQL_TXON)==SSQL_NORMAL) then
		transaction=1
	else
	begin
		ok = false
		sts = 0
		if (%ssc_getemsg(a_dbchn,errtxt,length,,dberror)==SSQL_FAILURE)
			errtxt="Failed to start transaction"
	end

	;;Open a cursor for the INSERT statement

	if (ok && openAndBind)
	begin
		if (%ssc_open(a_dbchn,csr_<structure_name>_insert1,sql,SSQL_NONSEL,SSQL_STANDARD)==SSQL_FAILURE)
		begin
			ok = false
			sts = 0
			if (%ssc_getemsg(a_dbchn,errtxt,length,,dberror)==SSQL_FAILURE)
				errtxt="Failed to open cursor"
		end
	end

	;;Bind the host variables for data to be inserted

	<COUNTER_1_RESET>
	<FIELD_LOOP>
	<COUNTER_1_INCREMENT>
	<IF COUNTER_1_EQ_1>
	if (ok && openAndBind)
	begin
		if (%ssc_bind(a_dbchn,csr_<structure_name>_insert1,<REMAINING_INCLUSIVE_MAX_250>,
	</IF COUNTER_1_EQ_1>
		<IF ALPHA>
		&    <field_path><IF NOMORE>)==SSQL_FAILURE)<ELSE><IF COUNTER_1_LT_250>,<ELSE>)==SSQL_FAILURE)</IF COUNTER_1_LT_250></IF NOMORE>
		</IF ALPHA>
		<IF DECIMAL>
		&    <field_path><IF NOMORE>)==SSQL_FAILURE)<ELSE><IF COUNTER_1_LT_250>,<ELSE>)==SSQL_FAILURE)</IF COUNTER_1_LT_250></IF NOMORE>
		</IF DECIMAL>
		<IF INTEGER>
		&    <field_path><IF NOMORE>)==SSQL_FAILURE)<ELSE><IF COUNTER_1_LT_250>,<ELSE>)==SSQL_FAILURE)</IF COUNTER_1_LT_250></IF NOMORE>
		</IF INTEGER>
		<IF DATE>
		&    ^a(<field_path>)<IF NOMORE>)==SSQL_FAILURE)<ELSE><IF COUNTER_1_LT_250>,<ELSE>)==SSQL_FAILURE)</IF COUNTER_1_LT_250></IF NOMORE>
		</IF DATE>
		<IF TIME>
		&    tmp<FieldSqlName><IF NOMORE>)==SSQL_FAILURE)<ELSE><IF COUNTER_1_LT_250>,<ELSE>)==SSQL_FAILURE)</IF COUNTER_1_LT_250></IF NOMORE>
		</IF TIME>
		<IF USER>
		<IF USERTIMESTAMP>
		&    tmp<FieldSqlName><IF NOMORE>)==SSQL_FAILURE)<ELSE><IF COUNTER_1_LT_250>,<ELSE>)==SSQL_FAILURE)</IF COUNTER_1_LT_250></IF NOMORE>
		<ELSE>
		&    <field_path><IF NOMORE>)==SSQL_FAILURE)<ELSE><IF COUNTER_1_LT_250>,<ELSE>)==SSQL_FAILURE)</IF COUNTER_1_LT_250></IF NOMORE>
		</IF USERTIMESTAMP>
		</IF USER>
	<IF COUNTER_1_EQ_250>
		begin
			ok = false
			sts = 0
			if (%ssc_getemsg(a_dbchn,errtxt,length,,dberror)==SSQL_FAILURE)
				errtxt="Failed to bind variables"
		end
	end
	<COUNTER_1_RESET>
	<ELSE>
	<IF NOMORE>
		begin
			ok = false
			sts = 0
			if (%ssc_getemsg(a_dbchn,errtxt,length,,dberror)==SSQL_FAILURE)
				errtxt="Failed to bind variables"
		end
	end
	</IF NOMORE>
	</IF COUNTER_1_EQ_250>
	</FIELD_LOOP>

	;;Insert the row into the database

	if (ok)
	begin
		;;Load data into bound record

		<structure_name> = a_data

		;;Clean up any alpha fields

		<FIELD_LOOP>
		<IF ALPHA>
		<IF NOTPKSEGMENT>
		<field_path> = %atrim(<field_path>)+%char(0)
		</IF NOTPKSEGMENT>
		</IF ALPHA>
		</FIELD_LOOP>

		;;Clean up any decimal fields

		<FIELD_LOOP>
		<IF DECIMAL>
		if ((!<field_path>)||(!%IsNumeric(^a(<field_path>))))
			clear <field_path>
		</IF DECIMAL>
		</FIELD_LOOP>

		;;Clean up any date fields

		<FIELD_LOOP>
		<IF DATE>
		if ((!<field_path>)||(!%IsDate(^a(<field_path>))))
			^a(<field_path>(1:1))=%char(0)
		</IF DATE>
		</FIELD_LOOP>

		;;Clean up any time fields

		<FIELD_LOOP>
		<IF TIME>
		if ((!<field_path>)||(!%IsTime(^a(<field_path>))))
			^a(<field_path>(1:1))=%char(0)
		</IF TIME>
		</FIELD_LOOP>

		;;Assign data to any temporary time or user-defined timestamp fields

		<FIELD_LOOP>
		<IF USERTIMESTAMP>
		tmp<FieldSqlName> = %string(^d(<field_path>),"XXXX-XX-XX XX:XX:XX.XXXXXX")
		<ELSE>
		<IF TIME_HHMM>
		tmp<FieldSqlName> = %string(<field_path>,"XX:XX")
		</IF TIME_HHMM>
		<IF TIME_HHMMSS>
		tmp<FieldSqlName> = %string(<field_path>,"XX:XX:XX")
		</IF TIME_HHMMSS>
		</IF USERTIMESTAMP>
		</FIELD_LOOP>

		;;Execute the INSERT statement

		if (%ssc_execute(a_dbchn,csr_<structure_name>_insert1,SSQL_STANDARD)==SSQL_FAILURE)
		begin
			ok = false
			sts = 0
			if (%ssc_getemsg(a_dbchn,errtxt,length,,dberror)==SSQL_NORMAL) then
			begin
				;;If it's a "row exists" then return 2
				using dberror select
				(-2627),
				begin
					;;Duplicate key
					errtxt = "Duplicate key detected in database!"
					sts = 2
				end
				(),
					nop
				endusing
			end
			else
				errtxt="Failed to execute SQL statement"
		end
	end

	;;Commit or rollback the transaction

	if (transaction)
	begin
		if (ok) then
		begin
			;;Success, commit the transaction
			if (%ssc_commit(a_dbchn,SSQL_TXOFF)==SSQL_FAILURE)
			begin
				ok = false
				sts = 0
				if (%ssc_getemsg(a_dbchn,errtxt,length,,dberror)==SSQL_FAILURE)
					errtxt="Failed to commit transaction"
			end
		end
		else
		begin
			;;There was an error, rollback the transaction
			xcall ssc_rollback(a_dbchn,SSQL_TXOFF)
		end
	end

	;;If there was an error message, return it to the calling routine

	if (^passed(a_errtxt))
	begin
		if (ok) then
			a_errtxt = ""
		else
			a_errtxt = errtxt
	end

	freturn sts

endfunction

;;*****************************************************************************
;;; <summary>
;;; Inserts multiple rows into the <StructureName> table.
;;; </summary>
;;; <param name="a_dbchn">Connected database channel</param>
;;; <param name="a_data">Memory handle containing one or more rows to insert.</param>
;;; <param name="a_errtxt">Returned error text.</param>
;;; <param name="a_exception">Memory handle to load exception data records into.</param>
;;; <param name="a_terminal">Terminal number channel to log errors on.</param>
;;; <returns>Returns true on success, otherwise false.</returns>

function <structure_name>_insert_rows, ^val

	required in  a_dbchn,     i
	required in  a_data,      i
	optional out a_errtxt,    a
	optional out a_exception, i
	optional in  a_terminal,  i
	endparams

	.include "CONNECTDIR:ssql.def"

	.define EXCEPTION_BUFSZ 100

	stack record local_data
		ok          ,boolean    ;;Return status
		openAndBind	,boolean	;;Should we open the cursor and bind data this time?
		dberror     ,int        ;;Database error number
		rows        ,int        ;;Number of rows to insert
		transaction ,int        ;;Transaction in progress
		length      ,int        ;;Length of a string
		ex_ms       ,int        ;;Size of exception array
		ex_mc       ,int        ;;Items in exception array
		continue    ,int        ;;Continue after an error
		errtxt      ,a512       ;;Error message text
	endrecord

	literal
		sql         ,a*, "INSERT INTO <StructureName> ("
		<FIELD_LOOP>
		& +              '"<FieldSqlName>"<,>'
		</FIELD_LOOP>
		& +              ") VALUES(<FIELD_LOOP><IF USERTIMESTAMP>CONVERT(DATETIME2,:<FIELD#LOGICAL>,21)<,><ELSE>:<FIELD#LOGICAL><,></IF USERTIMESTAMP></FIELD_LOOP>)"
	endliteral

	.include "<STRUCTURE_NOALIAS>" repository, structure="INPBUF", nofields, end
	.include "<STRUCTURE_NOALIAS>" repository, static record="<structure_name>", end

	static record
		<FIELD_LOOP>
		<IF USERTIMESTAMP>
		tmp<FieldSqlName>, a26     ;;Storage for user-defined timestamp field
		<ELSE>
		<IF TIME_HHMM>
		tmp<FieldSqlName>, a5      ;;Storage for HH:MM time field
		</IF TIME_HHMM>
		<IF TIME_HHMMSS>
		tmp<FieldSqlName>, a7      ;;Storage for HH:MM:SS time field
		</IF TIME_HHMMSS>
		</IF USERTIMESTAMP>
		</FIELD_LOOP>
		,a1                         ;;In case there are no user timestamp, date or JJJJJJ date fields
	endrecord

	global common
		csr_<structure_name>_insert2, i4
	endcommon

proc

	init local_data
	ok = true

	openAndBind = (csr_<structure_name>_insert2 == 0)

	if (^passed(a_exception)&&a_exception)
		clear a_exception

	;;Figure out how many rows to insert

	rows = (%mem_proc(DM_GETSIZE,a_data)/^size(<structure_name>))

	;;Start a database transaction

	if (%ssc_commit(a_dbchn,SSQL_TXON)==SSQL_NORMAL) then
		transaction=1
	else
	begin
		ok = false
		if (%ssc_getemsg(a_dbchn,errtxt,length,,dberror)==SSQL_FAILURE)
			errtxt="Failed to start transaction"
	end

	;;Open a cursor for the INSERT statement

	if (ok && openAndBind)
	begin
		if (%ssc_open(a_dbchn,csr_<structure_name>_insert2,sql,SSQL_NONSEL,SSQL_STANDARD)==SSQL_FAILURE)
		begin
			ok = false
			if (%ssc_getemsg(a_dbchn,errtxt,length,,dberror)==SSQL_FAILURE)
				errtxt="Failed to open cursor"
		end
	end

	;;Bind the host variables for data to be inserted

	<COUNTER_1_RESET>
	<FIELD_LOOP>
	<COUNTER_1_INCREMENT>
	<IF COUNTER_1_EQ_1>
	if (ok && openAndBind)
	begin
		if (%ssc_bind(a_dbchn,csr_<structure_name>_insert2,<REMAINING_INCLUSIVE_MAX_250>,
	</IF COUNTER_1_EQ_1>
		<IF ALPHA>
		&    <field_path><IF NOMORE>)==SSQL_FAILURE)<ELSE><IF COUNTER_1_LT_250>,<ELSE>)==SSQL_FAILURE)</IF COUNTER_1_LT_250></IF NOMORE>
		</IF ALPHA>
		<IF DECIMAL>
		&    <field_path><IF NOMORE>)==SSQL_FAILURE)<ELSE><IF COUNTER_1_LT_250>,<ELSE>)==SSQL_FAILURE)</IF COUNTER_1_LT_250></IF NOMORE>
		</IF DECIMAL>
		<IF INTEGER>
		&    <field_path><IF NOMORE>)==SSQL_FAILURE)<ELSE><IF COUNTER_1_LT_250>,<ELSE>)==SSQL_FAILURE)</IF COUNTER_1_LT_250></IF NOMORE>
		</IF INTEGER>
		<IF DATE>
		&    ^a(<field_path>)<IF NOMORE>)==SSQL_FAILURE)<ELSE><IF COUNTER_1_LT_250>,<ELSE>)==SSQL_FAILURE)</IF COUNTER_1_LT_250></IF NOMORE>
		</IF DATE>
		<IF TIME>
		&    tmp<FieldSqlName><IF NOMORE>)==SSQL_FAILURE)<ELSE><IF COUNTER_1_LT_250>,<ELSE>)==SSQL_FAILURE)</IF COUNTER_1_LT_250></IF NOMORE>
		</IF TIME>
		<IF USER>
		<IF USERTIMESTAMP>
		&    tmp<FieldSqlName><IF NOMORE>)==SSQL_FAILURE)<ELSE><IF COUNTER_1_LT_250>,<ELSE>)==SSQL_FAILURE)</IF COUNTER_1_LT_250></IF NOMORE>
		<ELSE>
		&    <field_path><IF NOMORE>)==SSQL_FAILURE)<ELSE><IF COUNTER_1_LT_250>,<ELSE>)==SSQL_FAILURE)</IF COUNTER_1_LT_250></IF NOMORE>
		</IF USERTIMESTAMP>
		</IF USER>
	<IF COUNTER_1_EQ_250>
		begin
			ok = false
			if (%ssc_getemsg(a_dbchn,errtxt,length,,dberror)==SSQL_FAILURE)
				errtxt="Failed to bind variables"
		end
	end
	<COUNTER_1_RESET>
	<ELSE>
	<IF NOMORE>
		begin
			ok = false
			if (%ssc_getemsg(a_dbchn,errtxt,length,,dberror)==SSQL_FAILURE)
				errtxt="Failed to bind variables"
		end
	end
	</IF NOMORE>
	</IF COUNTER_1_EQ_250>
	</FIELD_LOOP>

	;;Insert the rows into the database

	if (ok)
	begin
		data cnt, int
		for cnt from 1 thru rows
		begin
			;;Load data into bound record

			<structure_name> = ^m(inpbuf[cnt],a_data)

			;;Clean up any alpha variables

			<FIELD_LOOP>
			<IF ALPHA>
			<IF NOTPKSEGMENT>
			<field_path>=%atrim(<field_path>)+%char(0)
			</IF NOTPKSEGMENT>
			</IF ALPHA>
			</FIELD_LOOP>

			;;Clean up any decimal variables

			<FIELD_LOOP>
			<IF DECIMAL>
			if ((!<field_path>)||(!%IsNumeric(^a(<field_path>))))
				clear <field_path>
			</IF DECIMAL>
			</FIELD_LOOP>

			;;Clean up any date variables

			<FIELD_LOOP>
			<IF DATE>
			if ((!<field_path>)||(!%IsDate(^a(<field_path>))))
				^a(<field_path>(1:1))=%char(0)
			</IF DATE>
			</FIELD_LOOP>

			;;Clean up any time variables

			<FIELD_LOOP>
			<IF TIME>
			if ((!<field_path>)||(!%IsTime(^a(<field_path>))))
				^a(<field_path>(1:1))=%char(0)
			</IF TIME>
			</FIELD_LOOP>

			;;Assign any time or user-defined timestamp fields

			<FIELD_LOOP>
			<IF USERTIMESTAMP>
			tmp<FieldSqlName> = %string(^d(<field_path>),"XXXX-XX-XX XX:XX:XX.XXXXXX")
			<ELSE>
			<IF TIME_HHMM>
			tmp<FieldSqlName> = %string(<field_path>,"XX:XX")
			</IF TIME_HHMM>
			<IF TIME_HHMMSS>
			tmp<FieldSqlName> = %string(<field_path>,"XX:XX:XX")
			</IF TIME_HHMMSS>
			</IF USERTIMESTAMP>
			</FIELD_LOOP>

			;;Execute the statement

			if (%ssc_execute(a_dbchn,csr_<structure_name>_insert2,SSQL_STANDARD)==SSQL_FAILURE)
			begin
				if (%ssc_getemsg(a_dbchn,errtxt,length,,dberror)==SSQL_FAILURE)
					errtxt="Failed to execute SQL statement"

				clear continue

				;;Are we logging errors?
				if (^passed(a_terminal)&&(a_terminal))
				begin
					writes(a_terminal,errtxt(1:length))
					continue=1
				end

				;;Are we processing exceptions?
				if (^passed(a_exception))
				begin
					if (ex_mc==ex_ms)
					begin
						if (!a_exception) then
							a_exception = %mem_proc(DM_ALLOC|DM_STATIC,^size(inpbuf)*(ex_ms=EXCEPTION_BUFSZ))
						else
							a_exception = %mem_proc(DM_RESIZ,^size(inpbuf)*(ex_ms+=EXCEPTION_BUFSZ),a_exception)
					end
					^m(inpbuf[ex_mc+=1],a_exception)=<structure_name>
					continue=1
				end

				if (continue) then
					nextloop
				else
				begin
					ok = false
					exitloop
				end
			end
		end
	end

	;;Commit or rollback the transaction

	if (transaction)
	begin
		if (ok) then
		begin
			;;Success, commit the transaction
			if (%ssc_commit(a_dbchn,SSQL_TXOFF)==SSQL_FAILURE)
			begin
				ok = false
				if (%ssc_getemsg(a_dbchn,errtxt,length,,dberror)==SSQL_FAILURE)
					errtxt="Failed to commit transaction"
			end
		end
		else
		begin
			;;There was an error, rollback the transaction
			xcall ssc_rollback(a_dbchn,SSQL_TXOFF)
		end
	end

	;;If we're returning exceptions then resize the buffer to the correct size

	if (^passed(a_exception)&&a_exception)
		a_exception = %mem_proc(DM_RESIZ,^size(inpbuf)*ex_mc,a_exception)

	;;If there was an error message, return it to the calling routine

	if (^passed(a_errtxt))
	begin
		if (ok) then
			a_errtxt = ""
		else
			a_errtxt = %atrim(errtxt)+" [Database error "+%string(dberror)+"]"
	end

	freturn ok

endfunction

;;*****************************************************************************
;;; <summary>
;;; Updates a row in the <StructureName> table.
;;; </summary>
;;; <param name="a_dbchn">Connected database channel.</param>
;;; <param name="a_data">Record containing data to update.</param>
;;; <param name="a_rows">Returned number of rows affected.</param>
;;; <param name="a_errtxt">Returned error text.</param>
;;; <returns>Returns true on success, otherwise false.</returns>

function <structure_name>_update_row, ^val

	required in  a_dbchn,  i
	required in  a_data,   a
	optional out a_rows,   i
	optional out a_errtxt, a
	endparams

	.include "CONNECTDIR:ssql.def"

	stack record local_data
		ok          ,boolean    ;;OK to continue
		openAndBind	,boolean	;;Should we open the cursor and bind data this time?
		transaction ,boolean    ;;Transaction in progress
		dberror     ,int        ;;Database error number
		cursor      ,int        ;;Database cursor
		length      ,int        ;;Length of a string
		rows        ,int        ;;Number of rows updated
		errtxt      ,a256       ;;Error message text
	endrecord

	literal
		sql         ,a*, 'UPDATE <StructureName> SET '
		<COUNTER_1_RESET>
		<COUNTER_2_RESET>
		<FIELD_LOOP>
		<COUNTER_1_INCREMENT>
		<COUNTER_2_INCREMENT>
		<IF USERTIMESTAMP>
		& +              '"<FieldSqlName>"=CONVERT(DATETIME2,:<COUNTER_1_VALUE>,21)<,>'
		<ELSE>
		& +              '"<FieldSqlName>"=:<COUNTER_1_VALUE><,>'
		</IF USERTIMESTAMP>
		</FIELD_LOOP>
		& +              ' WHERE <UNIQUE_KEY><SEGMENT_LOOP><COUNTER_1_INCREMENT>"<SegmentName>"=:<COUNTER_1_VALUE> <AND> </SEGMENT_LOOP></UNIQUE_KEY>'
	endliteral

	.include "<STRUCTURE_NOALIAS>" repository, static record="<structure_name>", end

	static record
		<FIELD_LOOP>
		<IF USERTIMESTAMP>
		tmp<FieldSqlName>, a26     ;;Storage for user-defined timestamp field
		<ELSE>
		<IF TIME_HHMM>
		tmp<FieldSqlName>, a5      ;;Storage for HH:MM time field
		</IF TIME_HHMM>
		<IF TIME_HHMMSS>
		tmp<FieldSqlName>, a7      ;;Storage for HH:MM:SS time field
		</IF TIME_HHMMSS>
		</IF USERTIMESTAMP>
		</FIELD_LOOP>
		,a1                         ;;In case there are no user timestamp, date or JJJJJJ date fields
	endrecord

	global common
		csr_<structure_name>_update, i4
	endcommon
proc

	init local_data
	ok = true

	openAndBind = (csr_<structure_name>_update == 0)

	if (^passed(a_rows))
		clear a_rows

	;;Load the data into the bound record

	<structure_name> = a_data

	;;Start a database transaction

	if (%ssc_commit(a_dbchn,SSQL_TXON)==SSQL_NORMAL) then
		transaction = true
	else
	begin
		ok = false
		if (%ssc_getemsg(a_dbchn,errtxt,length,,dberror)==SSQL_FAILURE)
			errtxt="Failed to start transaction"
	end

	;;Open a cursor for the UPDATE statement

	if (ok && openAndBind)
	begin
		if (%ssc_open(a_dbchn,csr_<structure_name>_update,sql,SSQL_NONSEL,SSQL_STANDARD)==SSQL_FAILURE)
		begin
			ok = false
			if (%ssc_getemsg(a_dbchn,errtxt,length,,dberror)==SSQL_FAILURE)
				errtxt="Failed to open cursor"
		end
	end

	;;Bind the host variables for data to be updated
	<COUNTER_1_RESET>
	<FIELD_LOOP>
	<COUNTER_1_INCREMENT>
	<IF COUNTER_1_EQ_1>

	if (ok && openAndBind)
	begin
		if (%ssc_bind(a_dbchn,csr_<structure_name>_update,<REMAINING_INCLUSIVE_MAX_250>,
	</IF COUNTER_1_EQ_1>
		<IF ALPHA>
		&    <field_path><IF NOMORE>)==SSQL_FAILURE)<ELSE><IF COUNTER_1_LT_250>,<ELSE>)==SSQL_FAILURE)</IF COUNTER_1_LT_250></IF NOMORE>
		</IF ALPHA>
		<IF DECIMAL>
		&    <field_path><IF NOMORE>)==SSQL_FAILURE)<ELSE><IF COUNTER_1_LT_250>,<ELSE>)==SSQL_FAILURE)</IF COUNTER_1_LT_250></IF NOMORE>
		</IF DECIMAL>
		<IF INTEGER>
		&    <field_path><IF NOMORE>)==SSQL_FAILURE)<ELSE><IF COUNTER_1_LT_250>,<ELSE>)==SSQL_FAILURE)</IF COUNTER_1_LT_250></IF NOMORE>
		</IF INTEGER>
		<IF DATE>
		&    ^a(<field_path>)<IF NOMORE>)==SSQL_FAILURE)<ELSE><IF COUNTER_1_LT_250>,<ELSE>)==SSQL_FAILURE)</IF COUNTER_1_LT_250></IF NOMORE>
		</IF DATE>
		<IF TIME>
		&    tmp<FieldSqlName><IF NOMORE>)==SSQL_FAILURE)<ELSE><IF COUNTER_1_LT_250>,<ELSE>)==SSQL_FAILURE)</IF COUNTER_1_LT_250></IF NOMORE>
		</IF TIME>
		<IF USER>
		<IF USERTIMESTAMP>
		&    tmp<FieldSqlName><IF NOMORE>)==SSQL_FAILURE)<ELSE><IF COUNTER_1_LT_250>,<ELSE>)==SSQL_FAILURE)</IF COUNTER_1_LT_250></IF NOMORE>
		<ELSE>
		&    <field_path><IF NOMORE>)==SSQL_FAILURE)<ELSE><IF COUNTER_1_LT_250>,<ELSE>)==SSQL_FAILURE)</IF COUNTER_1_LT_250></IF NOMORE>
		</IF USERTIMESTAMP>
		</IF USER>
	<IF COUNTER_1_EQ_250>
		begin
			ok = false
			if (%ssc_getemsg(a_dbchn,errtxt,length,,dberror)==SSQL_FAILURE)
				errtxt="Failed to bind variables"
		end
	end
	<COUNTER_1_RESET>
	<ELSE>
	<IF NOMORE>
		begin
			ok = false
			if (%ssc_getemsg(a_dbchn,errtxt,length,,dberror)==SSQL_FAILURE)
				errtxt="Failed to bind variables"
		end
	end
	</IF NOMORE>
	</IF COUNTER_1_EQ_250>
	</FIELD_LOOP>

	;;Bind the host variables for the key segments / WHERE clause

	if (ok && openAndBind)
	begin
		if (%ssc_bind(a_dbchn,csr_<structure_name>_update,<UNIQUE_KEY><KEY_SEGMENTS>,<SEGMENT_LOOP><IF DATEORTIME>^a(</IF DATEORTIME><structure_name>.<segment_name><IF DATEORTIME>)</IF DATEORTIME><,></SEGMENT_LOOP></UNIQUE_KEY>)==SSQL_FAILURE)
		begin
			ok = false
			if (%ssc_getemsg(a_dbchn,errtxt,length,,dberror)==SSQL_FAILURE)
				errtxt="Failed to bind key variables"
		end
	end

	;;Update the row in the database

	if (ok)
	begin
		;;Clean up any alpha fields

		<FIELD_LOOP>
		<IF ALPHA>
		<IF NOTPKSEGMENT>
		<field_path> = %atrim(<field_path>) + %char(0)
		</IF NOTPKSEGMENT>
		</IF ALPHA>
		</FIELD_LOOP>
		
		;;Clean up any decimal fields

		<FIELD_LOOP>
		<IF DECIMAL>
		if ((!<field_path>)||(!%IsNumeric(^a(<field_path>))))
			clear <field_path>
		</IF DECIMAL>
		</FIELD_LOOP>

		;;Clean up any date fields

		<FIELD_LOOP>
		<IF DATE>
		if ((!<field_path>)||(!%IsDate(^a(<field_path>))))
			^a(<field_path>(1:1)) = %char(0)
		</IF DATE>
		</FIELD_LOOP>

		;;Clean up any time fields

		<FIELD_LOOP>
		<IF TIME>
		if ((!<field_path>)||(!%IsTime(^a(<field_path>))))
			^a(<field_path>(1:1)) = %char(0)
		</IF TIME>
		</FIELD_LOOP>

		;;Assign any time and user-defined timestamp fields

		<FIELD_LOOP>
		<IF USERTIMESTAMP>
		tmp<FieldSqlName> = %string(^d(<field_path>),"XXXX-XX-XX XX:XX:XX.XXXXXX")
		<ELSE>
		<IF TIME_HHMM>
		tmp<FieldSqlName> = %string(<field_path>,"XX:XX")
		</IF TIME_HHMM>
		<IF TIME_HHMMSS>
		tmp<FieldSqlName> = %string(<field_path>,"XX:XX:XX")
		</IF TIME_HHMMSS>
		</IF USERTIMESTAMP>
		</FIELD_LOOP>

		if (%ssc_execute(a_dbchn,csr_<structure_name>_update,SSQL_STANDARD,,rows)==SSQL_NORMAL) then
		begin
			if (^passed(a_rows))
				a_rows = rows
		end
		else
		begin
			ok = false
			if (%ssc_getemsg(a_dbchn,errtxt,length,,dberror)==SSQL_FAILURE)
				errtxt="Failed to execute SQL statement"
		end
	end

	;;Commit or rollback the transaction

	if (transaction)
	begin
		if (ok) then
		begin
			;;Success, commit the transaction
			if (%ssc_commit(a_dbchn,SSQL_TXOFF)==SSQL_FAILURE)
			begin
				ok = false
				if (%ssc_getemsg(a_dbchn,errtxt,length,,dberror)==SSQL_FAILURE)
					errtxt="Failed to commit transaction"
			end
		end
		else
		begin
			;;There was an error, rollback the transaction
			xcall ssc_rollback(a_dbchn,SSQL_TXOFF)
		end
	end

	;;Return error message

	if (^passed(a_errtxt))
	begin
		if (ok) then
			a_errtxt = ""
		else
			a_errtxt = errtxt
	end

	freturn ok

endfunction

;;*****************************************************************************
;;; <summary>
;;; Deletes a row from the <StructureName> table.
;;; </summary>
;;; <param name="a_dbchn">Connected database channel.</param>
;;; <param name="a_key">Unique key of row to be deleted.</param>
;;; <param name="a_errtxt">Returned error text.</param>
;;; <returns>Returns true on success, otherwise false.</returns>

function <structure_name>_delete_row, ^val

	required in  a_dbchn,  i
	required in  a_key,    a
	optional out a_errtxt, a
	endparams

	.include "CONNECTDIR:ssql.def"
	.include "<STRUCTURE_NOALIAS>" repository, stack record="<structureName>"

	external function
		<StructureName>KeyToRecord, a
	endexternal

	stack record local_data
		ok          ,boolean    ;;Return status
		dberror     ,int        ;;Database error number
		cursor      ,int        ;;Database cursor
		length      ,int        ;;Length of a string
		transaction ,int        ;;Transaction in progress
		errtxt      ,a256       ;;Error message text
		sql         ,string     ;;SQL statement
	endrecord

proc

	init local_data
	ok = true

	;;Put the unique key value into the record

	<structureName> = %<StructureName>KeyToRecord(a_key)

	;;Start a database transaction
	if (%ssc_commit(a_dbchn,SSQL_TXON)==SSQL_NORMAL) then
		transaction=1
	else
	begin
		ok = false
		if (%ssc_getemsg(a_dbchn,errtxt,length,,dberror)==SSQL_FAILURE)
			errtxt="Failed to start transaction"
	end

	;;Open a cursor for the DELETE statement

	if (ok)
	begin
		sql = 'DELETE FROM "<StructureName>" WHERE'
		<UNIQUE_KEY>
		<SEGMENT_LOOP>
		<IF ALPHA>
		& + ' "<SegmentName>"=' + "'" + %atrim(^a(<structureName>.<segment_name>)) + "' <AND>"
		<ELSE>
		& + ' "<SegmentName>"=' + "'" + %string(<structureName>.<segment_name>) + "' <AND>"
		</IF ALPHA>
		</SEGMENT_LOOP>
		</UNIQUE_KEY>
		if (%ssc_open(a_dbchn,cursor,(a)sql,SSQL_NONSEL)==SSQL_FAILURE)
		begin
			ok = false
			if (%ssc_getemsg(a_dbchn,errtxt,length,,dberror)==SSQL_FAILURE)
				errtxt="Failed to open cursor"
		end
	end

	;;Execute the query

	if (ok)
	begin
		if (%ssc_execute(a_dbchn,cursor,SSQL_STANDARD)==SSQL_FAILURE)
		begin
			ok = false
			if (%ssc_getemsg(a_dbchn,errtxt,length,,dberror)==SSQL_FAILURE)
				errtxt="Failed to execute SQL statement"
		end
	end

	;;Close the database cursor

	if (cursor)
	begin
		if (%ssc_close(a_dbchn,cursor)==SSQL_FAILURE)
		begin
			if (ok)
			begin
				ok = false
				if (%ssc_getemsg(a_dbchn,errtxt,length,,dberror)==SSQL_FAILURE)
					errtxt="Failed to close cursor"
			end
		end
	end

	;;Commit or rollback the transaction

	if (transaction)
	begin
		if (ok) then
		begin
			;;Success, commit the transaction
			if (%ssc_commit(a_dbchn,SSQL_TXOFF)==SSQL_FAILURE)
			begin
				ok = false
				if (%ssc_getemsg(a_dbchn,errtxt,length,,dberror)==SSQL_FAILURE)
					errtxt="Failed to commit transaction"
			end
		end
		else
		begin
			;;There was an error, rollback the transaction
			xcall ssc_rollback(a_dbchn,SSQL_TXOFF)
		end
	end

	;;If there was an error message, return it to the calling routine

	if (^passed(a_errtxt))
	begin
		if (ok) then
			a_errtxt = ""
		else
			a_errtxt = errtxt
	end

	freturn ok

endfunction

;;*****************************************************************************
;;; <summary>
;;; Deletes all rows from the <StructureName> table.
;;; </summary>
;;; <param name="a_dbchn">Connected database channel.</param>
;;; <param name="a_errtxt">Returned error text.</param>
;;; <returns>Returns true on success, otherwise false.</returns>

function <structure_name>_clear, ^val

	required in  a_dbchn,  i
	optional out a_errtxt, a
	endparams

	.include "CONNECTDIR:ssql.def"

	stack record local_data
		ok          ,boolean    ;;Return status
		dberror     ,int        ;;Database error number
		cursor      ,int        ;;Database cursor
		length      ,int        ;;Length of a string
		transaction ,int        ;;Transaction in process
		errtxt      ,a512       ;;Returned error message text
		sql         ,string     ;;SQL statement
	endrecord

proc

	init local_data
	ok = true

	;;Start a database transaction

	if (%ssc_commit(a_dbchn,SSQL_TXON)==SSQL_NORMAL) then
		transaction=1
	else
	begin
		ok = false
		if (%ssc_getemsg(a_dbchn,errtxt,length,,dberror)==SSQL_FAILURE)
			errtxt="Failed to start transaction"
	end

	;;Open cursor for the SQL statement

	if (ok)
	begin
		sql = 'TRUNCATE TABLE "<StructureName>"'
		if (%ssc_open(a_dbchn,cursor,(a)sql,SSQL_NONSEL)==SSQL_FAILURE)
		begin
			ok = false
			if (%ssc_getemsg(a_dbchn,errtxt,length,,dberror)==SSQL_FAILURE)
				errtxt="Failed to open cursor"
		end
	end

	;;Execute SQL statement

	if (ok)
	begin
		if (%ssc_execute(a_dbchn,cursor,SSQL_STANDARD)==SSQL_FAILURE)
		begin
			ok = false
			if (%ssc_getemsg(a_dbchn,errtxt,length,,dberror)==SSQL_FAILURE)
				errtxt="Failed to execute SQL statement"
		end
	end

	;;Close the database cursor

	if (cursor)
	begin
		if (%ssc_close(a_dbchn,cursor)==SSQL_FAILURE)
		begin
			if (ok)
			begin
				ok = false
				if (%ssc_getemsg(a_dbchn,errtxt,length,,dberror)==SSQL_FAILURE)
					errtxt="Failed to close cursor"
			end
		end
	end

	;;Commit or rollback the transaction

	if (transaction)
	begin
		if (ok) then
		begin
			;;Success, commit the transaction
			if (%ssc_commit(a_dbchn,SSQL_TXOFF)==SSQL_FAILURE)
			begin
				ok = false
				if (%ssc_getemsg(a_dbchn,errtxt,length,,dberror)==SSQL_FAILURE)
					errtxt="Failed to commit transaction"
			end
		end
		else
		begin
			;;There was an error, rollback the transaction
			xcall ssc_rollback(a_dbchn,SSQL_TXOFF)
		end
	end

	;;If there was an error message, return it to the calling routine

	if (^passed(a_errtxt))
	begin
		if (ok) then
			a_errtxt = ""
		else
			a_errtxt = errtxt
	end

	freturn ok

endfunction

;;*****************************************************************************
;;; <summary>
;;; Deletes the <StructureName> table from the database.
;;; </summary>
;;; <param name="a_dbchn">Connected database channel.</param>
;;; <param name="a_errtxt">Returned error text.</param>
;;; <returns>Returns true on success, otherwise false.</returns>

function <structure_name>_drop, ^val

	required in  a_dbchn,  i
	optional out a_errtxt, a
	endparams

	.include "CONNECTDIR:ssql.def"

	stack record local_data
		ok          ,boolean    ;;Return status
		dberror     ,int        ;;Database error number
		cursor      ,int        ;;Database cursor
		length      ,int        ;;Length of a string
		transaction ,int        ;;Transaction in progress
		errtxt      ,a256       ;;Returned error message text
	endrecord

proc

	init local_data
	ok = true

	;;Close any open cursors

	xcall <structure_name>_close(a_dbchn)

	;;Start a database transaction

	if (%ssc_commit(a_dbchn,SSQL_TXON)==SSQL_NORMAL) then
		transaction=1
	else
	begin
		ok = false
		if (%ssc_getemsg(a_dbchn,errtxt,length,,dberror)==SSQL_FAILURE)
			errtxt="Failed to start transaction"
	end

	;;Open cursor for DROP TABLE statement

	if (ok)
	begin
		if (%ssc_open(a_dbchn,cursor,"DROP TABLE <StructureName>",SSQL_NONSEL)==SSQL_FAILURE)
		begin
			ok = false
			if (%ssc_getemsg(a_dbchn,errtxt,length,,dberror)==SSQL_FAILURE)
				errtxt="Failed to open cursor"
		end
	end

	;;Execute DROP TABLE statement

	if (ok)
	begin
		if (%ssc_execute(a_dbchn,cursor,SSQL_STANDARD)==SSQL_FAILURE)
		begin
			if (%ssc_getemsg(a_dbchn,errtxt,length,,dberror)==SSQL_NORMAL) then
			begin
				;;Check if the error was that the table did not exist
				if (dberror==-3701) then
					clear errtxt
				else
					ok = false
			end
			else
			begin
				errtxt="Failed to execute SQL statement"
				ok = false
			end
		end
	end

	;;Close the database cursor

	if (cursor)
	begin
		if (%ssc_close(a_dbchn,cursor)==SSQL_FAILURE)
		begin
			if (ok)
			begin
				ok = false
				if (%ssc_getemsg(a_dbchn,errtxt,length,,dberror)==SSQL_FAILURE)
					errtxt="Failed to close cursor"
			end
		end
	end

	;;Commit or rollback the transaction

	if (transaction)
	begin
		if (ok) then
		begin
			;;Success, commit the transaction
			if (%ssc_commit(a_dbchn,SSQL_TXOFF)==SSQL_FAILURE)
			begin
				ok = false
				if (%ssc_getemsg(a_dbchn,errtxt,length,,dberror)==SSQL_FAILURE)
					errtxt="Failed to commit transaction"
			end
		end
		else
		begin
			;;There was an error, rollback the transaction
			xcall ssc_rollback(a_dbchn,SSQL_TXOFF)
		end
	end

	;;If there was an error message, return it to the calling routine

	if (^passed(a_errtxt))
	begin
		if (ok) then
			a_errtxt = ""
		else
			a_errtxt = errtxt
	end

	freturn ok

endfunction

;;*****************************************************************************
;;; <summary>
;;; Load all data from <FILE_NAME> into the <StructureName> table.
;;; </summary>
;;; <param name="a_dbchn">Connected database channel.</param>
;;; <param name="a_errtxt">Returned error text.</param>
;;; <param name="a_logex">Log exception records?</param>
;;; <param name="a_terminal">Terminal channel to log errors on.</param>
;;; <param name="a_added">Total number of successful inserts.</param>
;;; <param name="a_failed">Total number of failed inserts.</param>
;;; <param name="a_progress">Report progress.</param>
;;; <returns>Returns true on success, otherwise false.</returns>

function <structure_name>_load, ^val

	required in  a_dbchn,    i
	optional out a_errtxt,   a
	optional in  a_logex,    i
	optional in  a_terminal, i
	optional out a_added,    n
	optional out a_failed,   n
	optional in  a_progress, n
	endparams

	.include "CONNECTDIR:ssql.def"
	.include "<STRUCTURE_NOALIAS>" repository, structure="<STRUCTURE_NAME>", end
	.include "<STRUCTURE_NOALIAS>" repository, stack record="TMPREC", end
	.include "INC:structureio.def"

	.define BUFFER_ROWS     1000
	.define EXCEPTION_BUFSZ 100

	stack record local_data
		ok          ,boolean    ;;Return status
		firstRecord ,boolean    ;;Is this the first record?
		filechn     ,int        ;;Data file channel
		mh          ,D_HANDLE   ;;Memory handle containing data to insert
		ms          ,int        ;;Size of memory buffer in rows
		mc          ,int        ;;Memory buffer rows currently used
		ex_mh       ,D_HANDLE   ;;Memory buffer for exception records
		ex_mc       ,int        ;;Number of records in returned exception array
		ex_ch       ,int        ;;Exception log file channel
		attempted   ,int        ;;Rows being attempted
		ttl_added   ,int        ;;Total rows added
		ttl_failed  ,int        ;;Total failed inserts
		errnum      ,int        ;;Error number
		errtxt      ,a256       ;;Error message text
	endrecord

proc

	init local_data
	ok = true

	;;If we are logging exceptions, delete any existing exceptions file.
	if (^passed(a_logex) && a_logex)
	begin
		xcall delet("REPLICATOR_LOGDIR:<structure_name>_data_exceptions.log")
	end

	;;Open the data file associated with the structure

	if (%<structure_name>_io(IO_OPEN_INP,filechn)!=IO_OK)
	begin
		ok = false
		errtxt = "Failed to open file <FILE_NAME>"
		clear filechn
	end

	if (ok)
	begin
		;;Allocate memory buffer for the database rows

		mh = %mem_proc(DM_ALLOC,^size(<structure_name>)*(ms=BUFFER_ROWS))

		;;Read records from the input file

		firstRecord = true
		repeat
		begin
			;;Get the next record from the input file
			if (firstRecord) then
			begin
				errnum = %<structure_name>_io(IO_READ_FIRST,filechn,,,tmprec)
				firstRecord = false
			end
			else
				errnum = %<structure_name>_io(IO_READ_NEXT,filechn,,,tmprec)

			using errnum select
			(IO_OK),
				nop
			(IO_EOF),
				exitloop
			(),
			begin
				ok = false
				errtxt = "Unexpected response " + %string(errnum) + " from %<structure_name>_io"
				exitloop
			end
			endusing

			;;Got one, load it into or buffer
			^m(<structure_name>[mc+=1],mh) = tmprec

			;;If the buffer is full, write it to the database
			if (mc==ms)
				call insert_data
		end

		if (mc)
		begin
			mh = %mem_proc(DM_RESIZ,^size(<structure_name>)*mc,mh)
			call insert_data
		end

		;;Deallocate memory buffer

		mh = %mem_proc(DM_FREE,mh)

	end

	;;Close the file

	if (filechn)
		xcall <structure_name>_io(IO_CLOSE,filechn)

	;;Close the exceptions log file

	if (ex_ch)
		close ex_ch

	;;Return the error text

	if (^passed(a_errtxt))
		a_errtxt = errtxt

	;;Return totals

	if (^passed(a_added))
		a_added = ttl_added
	if (^passed(a_failed))
		a_failed = ttl_failed

	freturn ok

insert_data,

	attempted = (%mem_proc(DM_GETSIZE,mh)/^size(<structure_name>))

	if (%<structure_name>_insert_rows(a_dbchn,mh,errtxt,ex_mh,a_terminal))
	begin
		;;Any exceptions?
		if (ex_mh) then
		begin
			;;How many exceptions to log?
			ex_mc = (%mem_proc(DM_GETSIZE,ex_mh)/^size(<structure_name>))
			;;Update totals
			ttl_failed+=ex_mc
			ttl_added+=(attempted-ex_mc)
			;;Are we logging exceptions?
			if (^passed(a_logex)&&a_logex) then
			begin
				data cnt, int
				;;Open the log file
				if (!ex_ch)
					open(ex_ch=0,o:s,"REPLICATOR_LOGDIR:<structure_name>_data_exceptions.log")
				;;Log the exceptions
				for cnt from 1 thru ex_mc
					writes(ex_ch,^m(<structure_name>[cnt],ex_mh))
				if (^passed(a_terminal)&&a_terminal)
					writes(a_terminal,"Exceptions were logged to REPLICATOR_LOGDIR:<structure_name>_data_exceptions.log")
			end
			else
			begin
				;;No, report and error
				ok = false
			end
			;;Release the exception buffer
			ex_mh=%mem_proc(DM_FREE,ex_mh)
		end
		else
		begin
			;;No exceptions
			ttl_added += attempted
			if ^passed(a_terminal) && a_terminal && ^passed(a_progress) && a_progress
				writes(a_terminal," - " + %string(ttl_added) + " rows inserted")
		end
	end

	clear mc

	return

endfunction

;;*****************************************************************************
;;; <summary>
;;; Close cursors associated with the <StructureName> table.
;;; </summary>
;;; <param name="a_dbchn">Connected database channel</param>

subroutine <structure_name>_close

	required in  a_dbchn, i
	endparams

	.include "CONNECTDIR:ssql.def"

	external common
		csr_<structure_name>_insert1, i4
		csr_<structure_name>_insert2, i4
		csr_<structure_name>_update,  i4
	endcommon

proc

	if (csr_<structure_name>_insert1)
	begin
		if (%ssc_close(a_dbchn,csr_<structure_name>_insert1))
			nop
		clear csr_<structure_name>_insert1
	end

	if (csr_<structure_name>_insert2)
	begin
		if (%ssc_close(a_dbchn,csr_<structure_name>_insert2))
			nop
		clear csr_<structure_name>_insert2
	end

	if (csr_<structure_name>_update)
	begin
		if (%ssc_close(a_dbchn,csr_<structure_name>_update))
			nop
		clear csr_<structure_name>_update
	end

	xreturn

endsubroutine

;;*****************************************************************************
;;; <summary>
;;; Exports <FILE_NAME> to a CSV file.
;;; </summary>
;;; <param name="a_errtxt">Returned error text.</param>
;;; <returns>Returns true on success, otherwise false.</returns>

function <structure_name>_create_csv, ^val

	optional out a_errtxt, a
	endparams

	.include "CONNECTDIR:ssql.def"
	.include "<STRUCTURE_NOALIAS>" repository, record="<structure_name>", end
	.include "INC:STRUCTUREIO.DEF"

	.define EXCEPTION_BUFSZ 100

	stack record local_data
		ok          ,boolean    ;;Return status
		firstRecord ,boolean    ;;Is this the first record
		filechn     ,int        ;;Data file channel
		csvchn      ,int        ;;CSV file channel
		errnum      ,int        ;;Error number
		attempted   ,int        ;;Number of records exported
		errtxt      ,a256       ;;Error message text
	endrecord

proc

	init local_data
	ok = true

	;;Open the data file associated with the structure

	if (%<structure_name>_io(IO_OPEN_INP,filechn)!=IO_OK)
	begin
		ok = false
		errtxt = "Failed to open file <FILE_NAME>"
		clear filechn
	end

	;;Open the CSV file

	if (ok)
	begin
		open(csvchn=0,o:s,"REPLICATOR_EXPORT:<structure_name>.csv")
		writes(csvchn,"<FIELD_LOOP><FieldSqlName><IF MORE>|</IF MORE></FIELD_LOOP>")
	end

	if (ok)
	begin
		;;Read records from the input file

		firstRecord = true
		repeat
		begin

			;;Get the next record from the input file

			if (firstRecord) then
			begin
				errnum = %<structure_name>_io(IO_READ_FIRST,filechn,,,<structure_name>)
				firstRecord = false
			end
			else
			begin
				errnum = %<structure_name>_io(IO_READ_NEXT,filechn,,,<structure_name>)
			end

			using errnum select
			(IO_OK),
			begin
				data buff, string, ""
				buff = ""
				<FIELD_LOOP>
				<IF ALPHA>
				&    + %atrim(<field_path>) + "<IF MORE>|</IF MORE>"
				</IF ALPHA>
				<IF DECIMAL>
				&    + %string(<field_path>) + "<IF MORE>|</IF MORE>"
				</IF DECIMAL>
				<IF DATE>
				&    + %atrim(^a(<field_path>)) + "<IF MORE>|</IF MORE>"
				</IF DATE>
				<IF TIME_HHMM>
				&    + %string(<field_path>,"XX:XX") + "<IF MORE>|</IF MORE>"
				</IF TIME>
				<IF TIME_HHMMSS>
				&    + %string(<field_path>,"XX:XX:XX") + "<IF MORE>|</IF MORE>"
				</IF TIME>
				<IF USER>
				<IF USERTIMESTAMP>
				&    + %string(^d(<field_path>),"XXXX-XX-XX XX:XX:XX.XXXXXX") + "<IF MORE>|</IF MORE>"
				<ELSE>
				&    + %atrim(<field_path>) + "<IF MORE>|</IF MORE>"
				</IF USERTIMESTAMP>
				</IF USER>
				</FIELD_LOOP>
				writes(csvchn,buff)
				attempted += 1
			end
			(IO_EOF),
				exitloop
			(),
			begin
				ok = false
				errtxt = "Unexpected response " + %string(errnum) + " from %<structure_name>_io"
				exitloop
			end
			endusing
		end
	end

	;;Close the CSV file

	if (csvchn)
		close csvchn

	;;Create the SQL command file

	if (ok)
	begin
		data csvdir, a128
		data csvlen, i4
		data csvfile, string, ""

		xcall getlog("CSV",csvdir,csvlen)

		if (csvlen)
			csvfile = %atrim(csvdir)

		if (csvfile.EndsWith("\")) then
			csvfile = csvfile + "<structure_name>.csv"
		else
			csvfile = csvfile + "\<structure_name>.csv"

		open(csvchn=0,o:s,"REPLICATOR_EXPORT:<structure_name>.sql")

		writes(csvchn,"")
		writes(csvchn,"/*")
		writes(csvchn,"Use <put database name here>")
		writes(csvchn,"GO")
		writes(csvchn,"*/")
		writes(csvchn,"")
		writes(csvchn,"TRUNCATE TABLE <StructureName>")
		writes(csvchn,"GO")
		writes(csvchn,"")
		writes(csvchn,"BULK INSERT <StructureName>")
		writes(csvchn,"    FROM '" + csvfile + "'")
		writes(csvchn,"    WITH")
		writes(csvchn,"    (")
		writes(csvchn,"        FIRSTROW=2,")
		writes(csvchn,"        FIELDTERMINATOR='|',")
		writes(csvchn,"        ROWTERMINATOR ='\n'")
		writes(csvchn,"    )")
		writes(csvchn,"GO")
		writes(csvchn,"")

		close csvchn
	end

	;;Close the file

	if (filechn)
		xcall <structure_name>_io(IO_CLOSE,filechn)

	;;Return the error text

	if (^passed(a_errtxt))
		a_errtxt = errtxt

	freturn ok

endfunction

;;*****************************************************************************
;;; <summary>
;;; Loads a unique key value into the respective fields in a record.
;;; </summary>
;;; <param name="aKeyValue">Unique key value.</param>
;;; <returns>Returns a record containig only the unique key segment data.</returns>

function <StructureName>KeyToRecord, a

	required in aKeyValue, a
	endparams

	.include "<STRUCTURE_NOALIAS>" repository, stack record="<structureName>", end

	stack record
		segPos, int
	endrecord

proc

	clear <structureName>
	segPos = 1

	<UNIQUE_KEY>
	<SEGMENT_LOOP>
	<IF ALPHA>
	<structureName>.<segment_name> = aKeyValue(segPos:<SEGMENT_LENGTH>)
	</IF ALPHA>
	<IF DECIMAL>
	<structureName>.<segment_name> = ^d(aKeyValue(segPos:<SEGMENT_LENGTH>))
	</IF DECIMAL>
	<IF DATE>
	<structureName>.<segment_name> = ^d(aKeyValue(segPos:<SEGMENT_LENGTH>))
	</IF DATE>
	<IF TIME>
	<structureName>.<segment_name> = ^d(aKeyValue(segPos:<SEGMENT_LENGTH>))
	</IF TIME>
	<IF USER>
	<structureName>.<segment_name> = aKeyValue(segPos:<SEGMENT_LENGTH>)
	</IF USER>
	segPos += <SEGMENT_LENGTH>
	</SEGMENT_LOOP>
	</UNIQUE_KEY>

	freturn <structureName>

endfunction
