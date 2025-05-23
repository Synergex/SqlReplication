<CODEGEN_FILENAME><StructureName>SqlIO.dbl</CODEGEN_FILENAME>
<REQUIRES_CODEGEN_VERSION>5.6.3</REQUIRES_CODEGEN_VERSION>
;//****************************************************************************
;//
;// Guard against REPLICATOR_EXCLUDE being used on key segments
;//
<COUNTER_1_RESET>
<FIELD_LOOP>
  <IF CUSTOM_REPLICATOR_EXCLUDE AND KEYSEGMENT>
    <COUNTER_1_INCREMENT>
    <IF COUNTER_1_EQ_1>
*****************************************************************************
CODE GENERATION EXCEPTIONS:

    </IF COUNTER_1_EQ_1>
Field <FIELD_NAME> may not be excluded via REPLICATOR_EXCLUDE because it is a key segment!

  </IF CUSTOM_REPLICATOR_EXCLUDE>
</FIELD_LOOP>
;//
;//*****************************************************************************
;//
;// Title:       SqlIO.tpl
;//
;// Description: Template to generate a collection of Synergy functions which
;//              create and interact with a table in a SQL Server database
;//              whose columns match the fields defined in a Synergy
;//              repository structure.
;//
;// Author:      Steve Ives, Synergex Professional Services Group
;//
;// Copyright    (c) 2009 Synergex International Corporation.
;//              All rights reserved.
;//
;// Redistribution and use in source and binary forms, with or without
;// modification, are permitted provided that the following conditions are met:
;//
;// * Redistributions of source code must retain the above copyright notice,
;//   this list of conditions and the following disclaimer.
;//
;// * Redistributions in binary form must reproduce the above copyright notice,
;//   this list of conditions and the following disclaimer in the documentation
;//   and/or other materials provided with the distribution.
;//
;// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
;// AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
;// IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
;// ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
;// LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
;// CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
;// SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
;// INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
;// CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
;// ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
;// POSSIBILITY OF SUCH DAMAGE.
;//
;*****************************************************************************
;
; File:        <StructureName>SqlIO.dbl
;
; Description: Various functions that performs SQL I/O for <STRUCTURE_NAME>
;
;*****************************************************************************
; WARNING: THIS CODE WAS CODE GENERATED AND WILL BE OVERWRITTEN IF CODE
;          GENERATION IS RE-EXECUTED FOR THIS PROJECT.
;*****************************************************************************

import ReplicationLibrary
import Synergex.SynergyDE.Select

.ifndef str<StructureName>
.include "<STRUCTURE_NOALIAS>" repository, structure="str<StructureName>", end
.endc

;*****************************************************************************
;;; <summary>
;;; Determines if the <StructureName> table exists in the database.
;;; </summary>
;;; <param name="a_dbchn">Connected database channel.</param>
;;; <param name="a_commit_mode">What commit mode are we using?</param>
;;; <param name="a_temp_table">Use TEMP table?</param>
;;; <param name="a_errtxt">Returned error text.</param>
;;; <returns>Returns 1 if the table exists, otherwise a number indicating the type of error.</returns>

function <StructureName>Exists, ^val

    required in  a_dbchn,  i
    required in  a_commit_mode, i
    required in  a_temp_table, i
    optional out a_errtxt, a
    endparams

    .include "CONNECTDIR:ssql.def"

    stack record local_data
        sql         ,string ;SQL statement
        error       ,int    ;Returned error number
        dberror     ,int    ;Database error number
        cursor      ,int    ;Database cursor
        length      ,int    ;Length of a string
        table_name  ,a128   ;Retrieved table name
        errtxt      ,a512   ;Error message text
    endrecord

proc

    init local_data

    if (a_temp_table) then
        sql = "SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME='<StructureName>TEMP'"
    else
        sql = "SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME='<StructureName>'"

    ;Open a cursor for the SELECT statement

    if (%ssc_open(a_dbchn,cursor,sql,SSQL_SELECT)==SSQL_FAILURE)
    begin
        error=-1
        if (%ssc_getemsg(a_dbchn,errtxt,length,,dberror)==SSQL_FAILURE) then
            errtxt="Failed to open cursor"
        else
            xcall ThrowOnCommunicationError("<StructureName>Exists",dberror,errtxt)
    end

    ;Bind host variables to receive the data

    if (!error)
    begin
        if (%ssc_define(a_dbchn,cursor,1,table_name)==SSQL_FAILURE)
        begin
            error=-1
            if (%ssc_getemsg(a_dbchn,errtxt,length,,dberror)==SSQL_FAILURE) then
                errtxt="Failed to bind variable"
            else
                xcall ThrowOnCommunicationError("<StructureName>Exists",dberror,errtxt)
        end
    end

    ;Move data to host variables

    if (!error)
    begin
        if (%ssc_move(a_dbchn,cursor,1)==SSQL_NORMAL) then
        begin
            error = 1 ;Table exists
        end
        else
        begin
            if (%ssc_getemsg(a_dbchn,errtxt,length,,dberror)==SSQL_FAILURE) then
                errtxt="Failed to execute SQL Statement"
            else
                xcall ThrowOnCommunicationError("<StructureName>Exists",dberror,errtxt)
        end
    end

    ;Close the database cursor

    if (cursor)
    begin
        if (%ssc_close(a_dbchn,cursor)==SSQL_FAILURE)
        begin
            if (!error)
            begin
                error=-1
                if (%ssc_getemsg(a_dbchn,errtxt,length,,dberror)==SSQL_FAILURE) then
                    errtxt="Failed to close cursor"
                else
                    xcall ThrowOnCommunicationError("<StructureName>Exists",dberror,errtxt)
            end
        end
    end

    ;If there was an error message, return it to the calling routine

    if (^passed(a_errtxt))
    begin
        if (error) then
            a_errtxt = errtxt
        else
            clear a_errtxt
    end

    freturn error

endfunction

;*****************************************************************************
;;; <summary>
;;; Creates the <StructureName> table in the database.
;;; </summary>
;;; <param name="a_dbchn">Connected database channel.</param>
;;; <param name="a_commit_mode">What commit mode are we using?</param>
;;; <param name="a_data_compression">Data compression mode</param>
;;; <param name="a_temp_table">Use TEMP table?</param>
;;; <param name="a_errtxt">Returned error text.</param>
;;; <returns>Returns true on success, otherwise false.</returns>

function <StructureName>Create, ^val

    required in  a_dbchn,  i
    required in  a_commit_mode, i
    required in  a_data_compression, i
    required in  a_temp_table, i
    optional out a_errtxt, a
    endparams

    .include "CONNECTDIR:ssql.def"

    .align
    stack record local_data
        ok          ,boolean    ;Return status
        dberror     ,int        ;Database error number
        cursor      ,int        ;Database cursor
        length      ,int        ;Length of a string
        transaction ,int        ;Transaction in process
        errtxt      ,a512       ;Returned error message text
        tableName   ,string     ;Table name
        sql         ,string     ;SQL statement
    endrecord

proc

    init local_data
    ok = true

    ;Start a database transaction

    if (a_commit_mode==3)
    begin
        if (%ssc_commit(a_dbchn,SSQL_TXON)==SSQL_NORMAL) then
            transaction=1
        else
        begin
            ok = false
            if (%ssc_getemsg(a_dbchn,errtxt,length,,dberror)==SSQL_FAILURE) then
                errtxt="Failed to start transaction"
            else
                xcall ThrowOnCommunicationError("<StructureName>Create",dberror,errtxt)
        end
    end

    ;Create the database table and primary key constraint

    if (ok)
    begin
        if (a_temp_table) then
            tableName = "<StructureName>TEMP"
        else
            tableName = "<StructureName>"

        sql = 'CREATE TABLE ' + tableName + ' ('
;//
;// Columns
;//
<IF STRUCTURE_RELATIVE>
        & + '"RecordNumber" INT NOT NULL,'
</IF STRUCTURE_RELATIVE>
<FIELD_LOOP>
  <IF CUSTOM_NOT_REPLICATOR_EXCLUDE>
    <IF DEFINED_ASA_TIREMAX>
      <IF STRUCTURE_ISAM AND USER>
        & + '"<FieldSqlName>" DATE<IF REQUIRED> NOT NULL</IF><IF LAST><IF STRUCTURE_HAS_UNIQUE_PK>,</IF STRUCTURE_HAS_UNIQUE_PK><ELSE>,</IF LAST>'
      <ELSE STRUCTURE_ISAM AND NOT USER>
        & + '"<FieldSqlName>" <FIELD_CUSTOM_SQL_TYPE><IF REQUIRED> NOT NULL</IF><IF LAST><IF STRUCTURE_HAS_UNIQUE_PK>,</IF STRUCTURE_HAS_UNIQUE_PK><ELSE>,</IF LAST>'
      <ELSE STRUCTURE_RELATIVE AND USER>
        & + '"<FieldSqlName>" DATE<IF REQUIRED> NOT NULL</IF><,>'
      <ELSE STRUCTURE_RELATIVE AND NOT USER>
        & + '"<FieldSqlName>" <FIELD_CUSTOM_SQL_TYPE><IF REQUIRED> NOT NULL</IF><,>'
      </IF STRUCTURE_ISAM>
    <ELSE>
      <IF STRUCTURE_ISAM>
        & + '"<FieldSqlName>" <FIELD_CUSTOM_SQL_TYPE><IF REQUIRED> NOT NULL</IF><IF LAST><IF STRUCTURE_HAS_UNIQUE_PK>,</IF STRUCTURE_HAS_UNIQUE_PK><ELSE>,</IF LAST>'
      <ELSE STRUCTURE_RELATIVE>
        & + '"<FieldSqlName>" <FIELD_CUSTOM_SQL_TYPE><IF REQUIRED> NOT NULL</IF><,>'
      </IF STRUCTURE_ISAM>
    </IF DEFINED_ASA_TIREMAX>
  </IF CUSTOM_NOT_REPLICATOR_EXCLUDE>
</FIELD_LOOP>
;//
;// Primary key constraint
;//
<IF STRUCTURE_ISAM AND STRUCTURE_HAS_UNIQUE_PK>
        & + 'CONSTRAINT PK_' + tableName + ' PRIMARY KEY CLUSTERED(<PRIMARY_KEY><SEGMENT_LOOP>"<FieldSqlName>" <SEGMENT_ORDER><,></SEGMENT_LOOP></PRIMARY_KEY>)'
<ELSE STRUCTURE_RELATIVE>
        & + 'CONSTRAINT PK_' + tableName + ' PRIMARY KEY CLUSTERED("RecordNumber" ASC)'
</IF STRUCTURE_ISAM>
        & + ')'

        using a_data_compression select
        (2),
            sql = sql + " WITH(DATA_COMPRESSION=ROW)"
        (3),
            sql = sql + " WITH(DATA_COMPRESSION=PAGE)"
        endusing

        call open_cursor

        if (ok)
        begin
            call execute_cursor
            call close_cursor
        end
    end

    ;Grant access permissions

    if (ok)
    begin
        sql = 'GRANT ALL ON ' + tableName + ' TO PUBLIC'

        call open_cursor

        if (ok)
        begin
            call execute_cursor
            call close_cursor
        end
    end

    ;Commit or rollback the transaction

    if ((a_commit_mode==3) && transaction)
    begin
        if (ok) then
        begin
            ;Success, commit the transaction
            if (%ssc_commit(a_dbchn,SSQL_TXOFF)==SSQL_FAILURE)
            begin
                ok = false
                if (%ssc_getemsg(a_dbchn,errtxt,length,,dberror)==SSQL_FAILURE) then
                    errtxt="Failed to commit transaction"
                else
                    xcall ThrowOnCommunicationError("<StructureName>Create",dberror,errtxt)
            end
        end
        else
        begin
            ;There was an error, rollback the transaction
            if (%ssc_rollback(a_dbchn,SSQL_TXOFF) == SSQL_FAILURE)
            begin
                ok = false
                if (%ssc_getemsg(a_dbchn,errtxt,length,,dberror)==SSQL_FAILURE) then
                    errtxt="Failed to rollback transaction"
                else
                    xcall ThrowOnCommunicationError("<StructureName>Create",dberror,errtxt)
            end
        end
    end

    ;If there was an error message, return it to the calling routine

    if (^passed(a_errtxt))
    begin
        if (ok) then
            clear a_errtxt
        else
            a_errtxt = errtxt
    end

    freturn ok

open_cursor,

    if (%ssc_open(a_dbchn,cursor,(a)sql,SSQL_NONSEL)==SSQL_FAILURE)
    begin
        ok = false
        if (%ssc_getemsg(a_dbchn,errtxt,length,,dberror)==SSQL_FAILURE) then
            errtxt="Failed to open cursor"
        else
            xcall ThrowOnCommunicationError("<StructureName>Create",dberror,errtxt)
    end

    return

execute_cursor,

    if (%ssc_execute(a_dbchn,cursor,SSQL_STANDARD)==SSQL_FAILURE)
    begin
        ok = false
        if (%ssc_getemsg(a_dbchn,errtxt,length,,dberror)==SSQL_FAILURE) then
            errtxt="Failed to execute SQL statement"
        else
            xcall ThrowOnCommunicationError("<StructureName>Create",dberror,errtxt)
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
                if (%ssc_getemsg(a_dbchn,errtxt,length,,dberror)==SSQL_FAILURE) then
                    errtxt="Failed to close cursor"
                else
                    xcall ThrowOnCommunicationError("<StructureName>Create",dberror,errtxt)
            end
        end
        clear cursor
    end

    return

endfunction

<IF STRUCTURE_ISAM>
;*****************************************************************************
;;; <summary>
;;; Add alternate key indexes to the <StructureName> table if they do not exist.
;;; </summary>
;;; <param name="a_dbchn">Connected database channel.</param>
;;; <param name="a_commit_mode">What commit mode are we using?</param>
;;; <param name="a_db_timeout">Database timeout in seconds.</param>
;;; <param name="a_bl_timeout">Bulk load timeout in seconds.</param>
;;; <param name="a_data_compression">Data compression mode.</param>
;;; <param name="a_logchannel">Log file channel to log messages on.</param>
;;; <param name="a_errtxt">Returned error text.</param>
;;; <returns>Returns true on success, otherwise false.</returns>

function <StructureName>Index, ^val

    required in  a_dbchn,  i
    required in  a_commit_mode, i
    required in  a_db_timeout, n
    required in  a_bl_timeout, n
    required in  a_data_compression, n
    optional in  a_logchannel, n
    optional out a_errtxt, a
    endparams

    .include "CONNECTDIR:ssql.def"

    .align
    stack record local_data
        ok                  ,boolean    ;Return status
        dberror             ,int        ;Database error number
        cursor              ,int        ;Database cursor
        length              ,int        ;Length of a string
        transaction         ,int        ;Transaction in process
        keycount            ,int        ;Total number of keys
        errtxt              ,a512       ;Returned error message text
        now                 ,a20        ;Current date and time
        sql                 ,string     ;SQL statement
    endrecord

proc
    init local_data
    ok = true

    ;Start a database transaction

    if (a_commit_mode==3)
    begin
        if (%ssc_commit(a_dbchn,SSQL_TXON)==SSQL_NORMAL) then
            transaction=1
        else
        begin
            ok = false
            if (%ssc_getemsg(a_dbchn,errtxt,length,,dberror)==SSQL_FAILURE) then
                errtxt="Failed to start transaction"
            else
                xcall ThrowOnCommunicationError("<StructureName>Index",dberror,errtxt)
        end
    end

    ;Set the SQL statement execution timeout to the bulk load value

    if (ok)
    begin
        now = %datetime
        Logger.VerboseLog("Setting database timeout to " + %string(a_bl_timeout) + " seconds")
        if (%ssc_cmd(a_dbchn,,SSQL_TIMEOUT,%string(a_bl_timeout))==SSQL_FAILURE)
        begin
            ok = false
            if (%ssc_getemsg(a_dbchn,errtxt,length,,dberror)==SSQL_FAILURE) then
                errtxt="Failed to set database timeout"
            else
                xcall ThrowOnCommunicationError("<StructureName>Index",dberror,errtxt)
        end
    end

  <IF NOT STRUCTURE_HAS_UNIQUE_PK>
    ;The structure has no unique primary key, so no primary key constraint was added to the table. Create an index instead.

    if (ok && !IndexExists(a_dbchn,"IX_<StructureName>_<PRIMARY_KEY><KeyName></PRIMARY_KEY>",errtxt))
    begin
        sql = '<PRIMARY_KEY>CREATE INDEX IX_<StructureName>_<KeyName> ON "<StructureName>"(<SEGMENT_LOOP>"<FieldSqlName>" <SEGMENT_ORDER><,></SEGMENT_LOOP>)</PRIMARY_KEY>'

        using a_data_compression select
        (2),
            sql = sql + " WITH(DATA_COMPRESSION=ROW)"
        (3),
            sql = sql + " WITH(DATA_COMPRESSION=PAGE)"
        endusing

        call open_cursor

        if (ok)
        begin
            call execute_cursor
            call close_cursor
        end

        now = %datetime

        if (ok) then
        begin
            Logger.VerboseLog("Added index IX_<StructureName>_<PRIMARY_KEY><KeyName></PRIMARY_KEY>")
        end
        else
        begin
            Logger.ErrorLog("Failed to add index IX_<StructureName>_<PRIMARY_KEY><KeyName></PRIMARY_KEY>")
            ok = true
        end
    end

  </IF STRUCTURE_HAS_UNIQUE_PK>
  <ALTERNATE_KEY_LOOP>
    ;Create index <KEY_NUMBER> (<KEY_DESCRIPTION>)

    if (ok && !%IndexExists(a_dbchn,"IX_<StructureName>_<KeyName>",errtxt))
    begin
        sql = 'CREATE <IF FIRST_UNIQUE_KEY>CLUSTERED<ELSE><KEY_UNIQUE></IF FIRST_UNIQUE_KEY> INDEX IX_<StructureName>_<KeyName> ON "<StructureName>"(<SEGMENT_LOOP>"<FieldSqlName>" <SEGMENT_ORDER><,></SEGMENT_LOOP>)'

        using a_data_compression select
        (2),
            sql = sql + " WITH(DATA_COMPRESSION=ROW)"
        (3),
            sql = sql + " WITH(DATA_COMPRESSION=PAGE)"
        endusing

        call open_cursor

        if (ok)
        begin
            call execute_cursor
            call close_cursor
        end

        now = %datetime

        if (ok) then
        begin
            Logger.VerboseLog("Added index IX_<StructureName>_<KeyName>")
        end
        else
        begin
            Logger.ErrorLog("Failed to add index IX_<StructureName>_<KeyName>s")
            ok = true
        end
    end

  </ALTERNATE_KEY_LOOP>

    ;Commit or rollback the transaction

    if ((a_commit_mode==3) && transaction)
    begin
        if (ok) then
        begin
            ;Success, commit the transaction
            if (%ssc_commit(a_dbchn,SSQL_TXOFF)==SSQL_FAILURE)
            begin
                ok = false
                if (%ssc_getemsg(a_dbchn,errtxt,length,,dberror)==SSQL_FAILURE) then
                    errtxt="Failed to commit transaction"
                else
                    xcall ThrowOnCommunicationError("<StructureName>Index",dberror,errtxt)
            end
        end
        else
        begin
            ;There was an error, rollback the transaction
            if (%ssc_rollback(a_dbchn,SSQL_TXOFF) == SSQL_FAILURE)
            begin
                ok = false
                if (%ssc_getemsg(a_dbchn,errtxt,length,,dberror)==SSQL_FAILURE) then
                    errtxt="Failed to rollback transaction"
                else
                    xcall ThrowOnCommunicationError("<StructureName>Index",dberror,errtxt)
            end
        end
    end

    ;Set the database timeout back to the regular value

    now = %datetime
    Logger.VerboseLog("Resetting database timeout to " + %string(a_db_timeout) + " seconds")
    if (%ssc_cmd(a_dbchn,,SSQL_TIMEOUT,%string(a_db_timeout))==SSQL_FAILURE)
        nop

    ;If there was an error message, return it to the calling routine

    if (^passed(a_errtxt))
    begin
        if (ok) then
            clear a_errtxt
        else
            a_errtxt = errtxt
    end

    freturn ok

open_cursor,

    if (%ssc_open(a_dbchn,cursor,(a)sql,SSQL_NONSEL)==SSQL_FAILURE)
    begin
        ok = false
        if (%ssc_getemsg(a_dbchn,errtxt,length,,dberror)==SSQL_FAILURE) then
            errtxt="Failed to open cursor"
        else
            xcall ThrowOnCommunicationError("<StructureName>Index",dberror,errtxt)
    end

    return

execute_cursor,

    if (%ssc_execute(a_dbchn,cursor,SSQL_STANDARD)==SSQL_FAILURE)
    begin
        ok = false
        if (%ssc_getemsg(a_dbchn,errtxt,length,,dberror)==SSQL_FAILURE) then
            errtxt="Failed to execute SQL statement"
        else
            xcall ThrowOnCommunicationError("<StructureName>Index",dberror,errtxt)
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
                if (%ssc_getemsg(a_dbchn,errtxt,length,,dberror)==SSQL_FAILURE) then
                    errtxt="Failed to close cursor"
                else
                    xcall ThrowOnCommunicationError("<StructureName>Index",dberror,errtxt)
            end
        end
        clear cursor
    end

    return

endfunction

;*****************************************************************************
;;; <summary>
;;; Removes alternate key indexes from the <StructureName> table in the database.
;;; </summary>
;;; <param name="a_dbchn">Connected database channel.</param>
;;; <param name="a_commit_mode">What commit mode are we using?</param>
;;; <param name="a_errtxt">Returned error text.</param>
;;; <returns>Returns true on success, otherwise false.</returns>

function <StructureName>UnIndex, ^val

    required in  a_dbchn,  i
    required in  a_commit_mode, i
    optional out a_errtxt, a
    endparams

    .include "CONNECTDIR:ssql.def"

    .align
    stack record local_data
        ok          ,boolean    ;Return status
        dberror     ,int        ;Database error number
        cursor      ,int        ;Database cursor
        length      ,int        ;Length of a string
        transaction ,int        ;Transaction in process
        keycount    ,int        ;Total number of keys
        errtxt      ,a512       ;Returned error message text
        sql         ,string     ;SQL statement
    endrecord

proc
    init local_data
    ok = true

    ;Start a database transaction

    if (a_commit_mode==3)
    begin
        if (%ssc_commit(a_dbchn,SSQL_TXON)==SSQL_NORMAL) then
            transaction=1
        else
        begin
            ok = false
            if (%ssc_getemsg(a_dbchn,errtxt,length,,dberror)==SSQL_FAILURE) then
                errtxt="Failed to start transaction"
            else
                xcall ThrowOnCommunicationError("<StructureName>UnIndex",dberror,errtxt)
        end
    end

  <IF NOT STRUCTURE_HAS_UNIQUE_PK>
    if (ok)
    begin
;// Note: IF EXISTS only works for SQL Server 2016 and later. Remove it for earlier databases.
        sql = '<PRIMARY_KEY>DROP INDEX IF EXISTS IX_<StructureName>_<KeyName></PRIMARY_KEY> ON "<StructureName>"'

        call open_cursor

        if (ok)
        begin
            call execute_cursor
            call close_cursor
        end
    end

  </IF STRUCTURE_HAS_UNIQUE_PK>
  <ALTERNATE_KEY_LOOP>
    ;Drop index <KEY_NUMBER> (<KEY_DESCRIPTION>)

    if (ok)
    begin
;// Note: IF EXISTS only works for SQL Server 2016 and later. Remove it for earlier databases.
        sql = 'DROP INDEX IF EXISTS IX_<StructureName>_<KeyName> ON "<StructureName>"'

        call open_cursor

        if (ok)
        begin
            call execute_cursor
            call close_cursor
        end
    end

  </ALTERNATE_KEY_LOOP>
    ;Commit or rollback the transaction

    if ((a_commit_mode==3) && transaction)
    begin
        if (ok) then
        begin
            ;Success, commit the transaction
            if (%ssc_commit(a_dbchn,SSQL_TXOFF)==SSQL_FAILURE)
            begin
                ok = false
                if (%ssc_getemsg(a_dbchn,errtxt,length,,dberror)==SSQL_FAILURE) then
                    errtxt="Failed to commit transaction"
                else
                    xcall ThrowOnCommunicationError("<StructureName>UnIndex",dberror,errtxt)
            end
        end
        else
        begin
            ;There was an error, rollback the transaction
            if (%ssc_rollback(a_dbchn,SSQL_TXOFF) == SSQL_FAILURE)
            begin
                ok = false
                if (%ssc_getemsg(a_dbchn,errtxt,length,,dberror)==SSQL_FAILURE) then
                    errtxt="Failed to rollback transaction"
                else
                    xcall ThrowOnCommunicationError("<StructureName>UnIndex",dberror,errtxt)
            end
        end
    end

    ;If there was an error message, return it to the calling routine

    if (^passed(a_errtxt))
    begin
        if (ok) then
            clear a_errtxt
        else
            a_errtxt = errtxt
    end

    freturn ok

open_cursor,

    if (%ssc_open(a_dbchn,cursor,(a)sql,SSQL_NONSEL)==SSQL_FAILURE)
    begin
        ok = false
        if (%ssc_getemsg(a_dbchn,errtxt,length,,dberror)==SSQL_FAILURE) then
            errtxt="Failed to open cursor"
        else
            xcall ThrowOnCommunicationError("<StructureName>UnIndex",dberror,errtxt)
    end

    return

execute_cursor,

    if (%ssc_execute(a_dbchn,cursor,SSQL_STANDARD)==SSQL_FAILURE)
    begin
        ok = false
        if (%ssc_getemsg(a_dbchn,errtxt,length,,dberror)==SSQL_FAILURE) then
            errtxt="Failed to execute SQL statement"
        else
            xcall ThrowOnCommunicationError("<StructureName>UnIndex",dberror,errtxt)
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
                if (%ssc_getemsg(a_dbchn,errtxt,length,,dberror)==SSQL_FAILURE) then
                    errtxt="Failed to close cursor"
                else
                    xcall ThrowOnCommunicationError("<StructureName>UnIndex",dberror,errtxt)
            end
        end
        clear cursor
    end

    return

endfunction

</IF STRUCTURE_ISAM>
;*****************************************************************************
;;; <summary>
;;; Insert a row into the <StructureName> table.
;;; </summary>
;;; <param name="a_dbchn">Connected database channel.</param>
;;; <param name="a_commit_mode">What commit mode are we using?</param>
<IF STRUCTURE_RELATIVE>
;;; <param name="a_recnum">Relative record number to be inserted.</param>
</IF STRUCTURE_RELATIVE>
;;; <param name="a_data">Record to be inserted.</param>
;;; <param name="a_errtxt">Returned error text.</param>
;;; <returns>Returns 1 if the row was inserted, 2 to indicate the row already exists, or 0 if an error occurred.</returns>

function <StructureName>Insert, ^val

    required in  a_dbchn,  i
    required in  a_commit_mode, i
<IF STRUCTURE_RELATIVE>
    required in  a_recnum, n
</IF STRUCTURE_RELATIVE>
    required in  a_data,   a
    optional out a_errtxt, a
    endparams

    .include "CONNECTDIR:ssql.def"

<IF DEFINED_ASA_TIREMAX>
    external function
        TmJulianToYYYYMMDD, a
    endexternal

</IF DEFINED_ASA_TIREMAX>
    .align
    stack record local_data
        ok          ,boolean    ;OK to continue
        openAndBind ,boolean    ;Should we open the cursor and bind data this time?
        sts         ,int        ;Return status
        dberror     ,int        ;Database error number
        transaction ,int        ;Transaction in progress
        length      ,int        ;Length of a string
        errtxt      ,a512       ;Error message text
<IF STRUCTURE_RELATIVE>
        recordNumber,d28        ;Relative record number
</IF STRUCTURE_RELATIVE>
    endrecord

    literal
        sql         ,a*, "INSERT INTO <StructureName> ("
<COUNTER_1_RESET>
<IF STRUCTURE_RELATIVE>
        & +              '"RecordNumber",'
<COUNTER_1_INCREMENT>
</IF STRUCTURE_RELATIVE>
<FIELD_LOOP>
  <IF CUSTOM_NOT_REPLICATOR_EXCLUDE>
        & +              '"<FieldSqlName>"<,>'
  </IF CUSTOM_NOT_REPLICATOR_EXCLUDE>
</FIELD_LOOP>
        & +              ") VALUES(<IF STRUCTURE_RELATIVE>:1,</IF STRUCTURE_RELATIVE><FIELD_LOOP><IF CUSTOM_NOT_REPLICATOR_EXCLUDE><COUNTER_1_INCREMENT><IF USERTIMESTAMP>CONVERT(DATETIME2,:<COUNTER_1_VALUE>,21)<,><ELSE>:<COUNTER_1_VALUE><,></IF USERTIMESTAMP></IF CUSTOM_NOT_REPLICATOR_EXCLUDE></FIELD_LOOP>)"
    endliteral

    static record
        <structure_name>, str<StructureName>
<FIELD_LOOP>
  <IF CUSTOM_NOT_REPLICATOR_EXCLUDE>
    <IF USERTIMESTAMP>
        tmp<FieldSqlName>, a26     ;Storage for user-defined timestamp field
    <ELSE>
      <IF TIME_HHMM>
        tmp<FieldSqlName>, a5      ;Storage for HH:MM time field
      </IF TIME_HHMM>
      <IF TIME_HHMMSS>
        tmp<FieldSqlName>, a8      ;Storage for HH:MM:SS time field
      </IF TIME_HHMMSS>
      <IF DEFINED_ASA_TIREMAX>
        <IF USER>
        tmp<FieldSqlName>, a8      ;Storage for user defined JJJJJJ date field
        </IF USER>
      </IF DEFINED_ASA_TIREMAX>
      <IF CUSTOM_DBL_TYPE>
        tmp<FieldSqlName>, <FIELD_CUSTOM_DBL_TYPE>
      </IF CUSTOM_DBL_TYPE>
    </IF USERTIMESTAMP>
  </IF CUSTOM_NOT_REPLICATOR_EXCLUDE>
</FIELD_LOOP>
    endrecord

    global common
        c1<StructureName>, i4, 0
    endcommon

;//If any fields have a custom data type, declare the functions that convert the value
<COUNTER_1_RESET><FIELD_LOOP><IF CUSTOM_CONVERT_FUNCTION><COUNTER_1_INCREMENT></IF></FIELD_LOOP>
<IF COUNTER_1>
    external function
  <FIELD_LOOP>
    <IF CUSTOM_CONVERT_FUNCTION>
        <FIELD_CUSTOM_CONVERT_FUNCTION>, <FIELD_CUSTOM_DBL_TYPE>
    </IF>
  </FIELD_LOOP>
    endexternal
</IF>
proc

    init local_data
    ok = true
    sts = 1
<IF STRUCTURE_RELATIVE>
    recordNumber = a_recnum
</IF STRUCTURE_RELATIVE>
    openAndBind = (c1<StructureName> == 0)

    ;Start a database transaction

    if (a_commit_mode==3)
    begin
        if (%ssc_commit(a_dbchn,SSQL_TXON)==SSQL_NORMAL) then
            transaction=1
        else
        begin
            ok = false
            sts = 0
            if (%ssc_getemsg(a_dbchn,errtxt,length,,dberror)==SSQL_FAILURE) then
                errtxt="Failed to start transaction"
            else
                xcall ThrowOnCommunicationError("<StructureName>Insert",dberror,errtxt)
        end
    end

    ;Open a cursor for the INSERT statement

    if (ok && openAndBind)
    begin
        if (%ssc_open(a_dbchn,c1<StructureName>,sql,SSQL_NONSEL,SSQL_STANDARD)==SSQL_FAILURE)
        begin
            ok = false
            sts = 0
            if (%ssc_getemsg(a_dbchn,errtxt,length,,dberror)==SSQL_FAILURE) then
                errtxt="Failed to open cursor"
            else
                xcall ThrowOnCommunicationError("<StructureName>Insert",dberror,errtxt)
        end
    end

    ;Bind the host variables for data to be inserted

<IF STRUCTURE_RELATIVE>
    if (ok && openAndBind)
    begin
        if (%ssc_bind(a_dbchn,c1<StructureName>,1,recordNumber)==SSQL_FAILURE)
        begin
            ok = false
            sts = 0
            if (%ssc_getemsg(a_dbchn,errtxt,length,,dberror)==SSQL_FAILURE) then
                errtxt="Failed to bind variables"
            else
                xcall ThrowOnCommunicationError("<StructureName>Insert",dberror,errtxt)
        end
    end

</IF STRUCTURE_RELATIVE>
<COUNTER_1_RESET>
<FIELD_LOOP>
  <IF CUSTOM_NOT_REPLICATOR_EXCLUDE>
    <COUNTER_1_INCREMENT>
    <IF COUNTER_1_EQ_1>
    if (ok && openAndBind)
    begin
        if (%ssc_bind(a_dbchn,c1<StructureName>,<REPLICATION_REMAINING_INCLUSIVE_MAX_250>,
    </IF COUNTER_1_EQ_1>
    <IF CUSTOM_DBL_TYPE>
        &    tmp<FieldSqlName><IF NOMORE>)==SSQL_FAILURE)<ELSE><IF COUNTER_1_LT_250>,<ELSE>)==SSQL_FAILURE)</IF COUNTER_1_LT_250></IF NOMORE>
    <ELSE ALPHA>
        &    <structure_name>.<field_original_name_modified><IF NOMORE>)==SSQL_FAILURE)<ELSE><IF COUNTER_1_LT_250>,<ELSE>)==SSQL_FAILURE)</IF COUNTER_1_LT_250></IF NOMORE>
    <ELSE DECIMAL>
        &    <structure_name>.<field_original_name_modified><IF NOMORE>)==SSQL_FAILURE)<ELSE><IF COUNTER_1_LT_250>,<ELSE>)==SSQL_FAILURE)</IF COUNTER_1_LT_250></IF NOMORE>
    <ELSE INTEGER>
        &    <structure_name>.<field_original_name_modified><IF NOMORE>)==SSQL_FAILURE)<ELSE><IF COUNTER_1_LT_250>,<ELSE>)==SSQL_FAILURE)</IF COUNTER_1_LT_250></IF NOMORE>
    <ELSE DATE>
        &    ^a(<structure_name>.<field_original_name_modified>)<IF NOMORE>)==SSQL_FAILURE)<ELSE><IF COUNTER_1_LT_250>,<ELSE>)==SSQL_FAILURE)</IF COUNTER_1_LT_250></IF NOMORE>
    <ELSE TIME>
        &    tmp<FieldSqlName><IF NOMORE>)==SSQL_FAILURE)<ELSE><IF COUNTER_1_LT_250>,<ELSE>)==SSQL_FAILURE)</IF COUNTER_1_LT_250></IF NOMORE>
    <ELSE USER AND USERTIMESTAMP>
        &    tmp<FieldSqlName><IF NOMORE>)==SSQL_FAILURE)<ELSE><IF COUNTER_1_LT_250>,<ELSE>)==SSQL_FAILURE)</IF COUNTER_1_LT_250></IF NOMORE>
    <ELSE USER AND NOT USERTIMESTAMP>
      <IF DEFINED_ASA_TIREMAX>
        &    tmp<FieldSqlName><IF NOMORE>)==SSQL_FAILURE)<ELSE><IF COUNTER_1_LT_250>,<ELSE>)==SSQL_FAILURE)</IF COUNTER_1_LT_250></IF NOMORE>
      <ELSE>
        &    <structure_name>.<field_original_name_modified><IF NOMORE>)==SSQL_FAILURE)<ELSE><IF COUNTER_1_LT_250>,<ELSE>)==SSQL_FAILURE)</IF COUNTER_1_LT_250></IF NOMORE>
      </IF DEFINED_ASA_TIREMAX>
    </IF CUSTOM_DBL_TYPE>
    <IF COUNTER_1_EQ_250>
        begin
            ok = false
            sts = 0
            if (%ssc_getemsg(a_dbchn,errtxt,length,,dberror)==SSQL_FAILURE) then
                errtxt="Failed to bind variables"
            else
                xcall ThrowOnCommunicationError("<StructureName>Insert",dberror,errtxt)
        end
    end
      <COUNTER_1_RESET>
    <ELSE NOMORE>
        begin
            ok = false
            sts = 0
            if (%ssc_getemsg(a_dbchn,errtxt,length,,dberror)==SSQL_FAILURE) then
                errtxt="Failed to bind variables"
            else
                xcall ThrowOnCommunicationError("<StructureName>Insert",dberror,errtxt)
        end
    end
    </IF COUNTER_1_EQ_250>
  </IF CUSTOM_NOT_REPLICATOR_EXCLUDE>
</FIELD_LOOP>

    ;Insert the row into the database

    if (ok)
    begin
<IF STRUCTURE_MAPPED>
        ;Map the file data into the table data record

        <structure_name> = %<structure_name>_map(a_data)
<ELSE>
        ;Load the data into the bound record

        <structure_name> = a_data
</IF STRUCTURE_MAPPED>

<IF DEFINED_CLEAN_DATA>
        ;Clean up any alpha fields

  <FIELD_LOOP>
    <IF ALPHA AND CUSTOM_NOT_REPLICATOR_EXCLUDE>
      <IF NOT FIRST_UNIQUE_KEY_SEGMENT>
        <structure_name>.<field_original_name_modified> = %atrim(<structure_name>.<field_original_name_modified>)+%char(0)
      </IF FIRST_UNIQUE_KEY_SEGMENT>
    </IF ALPHA>
  </FIELD_LOOP>

        ;Clean up any decimal fields

  <FIELD_LOOP>
    <IF DECIMAL AND CUSTOM_NOT_REPLICATOR_EXCLUDE>
        if ((!<structure_name>.<field_original_name_modified>)||(!<IF NEGATIVE_ALLOWED>%IsDecimalNegatives<ELSE>%IsDecimalNoNegatives</IF NEGATIVE_ALLOWED>(<structure_name>.<field_original_name_modified>)))
            clear <structure_name>.<field_original_name_modified>
    </IF DECIMAL>
  </FIELD_LOOP>

        ;Clean up any date fields

  <FIELD_LOOP>
    <IF DATE AND CUSTOM_NOT_REPLICATOR_EXCLUDE>
        if ((!<structure_name>.<field_original_name_modified>)||(!%IsDate(^a(<structure_name>.<field_original_name_modified>))))
      <IF FIRST_UNIQUE_KEY_SEGMENT>
            ^a(<structure_name>.<field_original_name_modified>) = "17530101"
      <ELSE>
            ^a(<structure_name>.<field_original_name_modified>(1:1)) = %char(0)
      </IF FIRST_UNIQUE_KEY_SEGMENT>
    </IF DATE>
  </FIELD_LOOP>

        ;Clean up any time fields

  <FIELD_LOOP>
    <IF TIME AND CUSTOM_NOT_REPLICATOR_EXCLUDE>
        if ((!<structure_name>.<field_original_name_modified>)||(!%IsTime(^a(<structure_name>.<field_original_name_modified>))))
            ^a(<structure_name>.<field_original_name_modified>(1:1))=%char(0)
    </IF TIME>
  </FIELD_LOOP>

</IF DEFINED_CLEAN_DATA>
        ;Assign data to any temporary time or user-defined timestamp fields

<FIELD_LOOP>
  <IF CUSTOM_NOT_REPLICATOR_EXCLUDE>
    <IF USERTIMESTAMP>
        tmp<FieldSqlName> = %string(^d(<structure_name>.<field_original_name_modified>),"XXXX-XX-XX XX:XX:XX.XXXXXX")
    <ELSE TIME_HHMM>
        tmp<FieldSqlName> = %string(<structure_name>.<field_original_name_modified>,"XX:XX")
    <ELSE TIME_HHMMSS>
        tmp<FieldSqlName> = %string(<structure_name>.<field_original_name_modified>,"XX:XX:XX")
    <ELSE DEFINED_ASA_TIREMAX AND USER>
        tmp<FieldSqlName> = %TmJulianToYYYYMMDD(<field_path>)
    </IF USERTIMESTAMP>
  </IF CUSTOM_NOT_REPLICATOR_EXCLUDE>
</FIELD_LOOP>

        ;Assign values to temp fields for any fields with custom data types

<FIELD_LOOP>
  <IF CUSTOM_DBL_TYPE>
        tmp<FieldSqlName> = %<FIELD_CUSTOM_CONVERT_FUNCTION>(<field_path>,<structure_name>)
  </IF CUSTOM_DBL_TYPE>
</FIELD_LOOP>

        ;Execute the INSERT statement

        if (%ssc_execute(a_dbchn,c1<StructureName>,SSQL_STANDARD)==SSQL_FAILURE)
        begin
            ok = false
            sts = 0
            if (%ssc_getemsg(a_dbchn,errtxt,length,,dberror)==SSQL_NORMAL) then
            begin
                ;If it's a "row exists" then return 2
                using dberror select
                (-2627),
                begin
                    ;Duplicate key
                    errtxt = "Duplicate key detected in database!"
                    sts = 2
                end
                (),
                begin
                    xcall ThrowOnCommunicationError("<StructureName>Insert",dberror,errtxt)
                end
                endusing
            end
            else
            begin
                errtxt="Failed to execute SQL statement"
            end
        end
    end

    ;Commit or rollback the transaction

    if ((a_commit_mode==3) && transaction)
    begin
        if (ok) then
        begin
            ;Success, commit the transaction
            if (%ssc_commit(a_dbchn,SSQL_TXOFF)==SSQL_FAILURE)
            begin
                ok = false
                sts = 0
                if (%ssc_getemsg(a_dbchn,errtxt,length,,dberror)==SSQL_FAILURE) then
                    errtxt="Failed to commit transaction"
                else
                    xcall ThrowOnCommunicationError("<StructureName>Insert",dberror,errtxt)
            end
        end
        else
        begin
            ;There was an error, rollback the transaction
            if (%ssc_rollback(a_dbchn,SSQL_TXOFF) == SSQL_FAILURE)
            begin
                ok = false
                if (%ssc_getemsg(a_dbchn,errtxt,length,,dberror)==SSQL_FAILURE) then
                    errtxt="Failed to rollback transaction"
                else
                    xcall ThrowOnCommunicationError("<StructureName>Insert",dberror,errtxt)
            end
        end
    end

    ;If there was an error message, return it to the calling routine

    if (^passed(a_errtxt))
    begin
        if (ok) then
            clear a_errtxt
        else
            a_errtxt = errtxt
    end

    freturn sts

endfunction

;*****************************************************************************
;;; <summary>
;;; Inserts multiple rows into the <StructureName> table.
;;; </summary>
;;; <param name="a_dbchn">Connected database channel</param>
;;; <param name="a_commit_mode">What commit mode are we using?</param>
;;; <param name="a_data">Memory handle containing one or more rows to insert.</param>
;;; <param name="a_errtxt">Returned error text.</param>
;;; <param name="a_exception">Memory handle to load exception data records into.</param>
;;; <param name="a_terminal">Terminal number channel to log errors on.</param>
;;; <returns>Returns true on success, otherwise false.</returns>

function <StructureName>InsertRows, ^val

    required in  a_dbchn,     i
    required in  a_commit_mode, i
    required in  a_data,      i
    optional out a_errtxt,    a
    optional out a_exception, i
    optional in  a_terminal,  i
    endparams

    .include "CONNECTDIR:ssql.def"

<IF DEFINED_ASA_TIREMAX>
    external function
        TmJulianToYYYYMMDD, a
    endexternal

</IF DEFINED_ASA_TIREMAX>
    .define EXCEPTION_BUFSZ 100

    stack record local_data
        ok          ,boolean    ;Return status
        openAndBind ,boolean    ;Should we open the cursor and bind data this time?
        dberror     ,int        ;Database error number
        rows        ,int        ;Number of rows to insert
        transaction ,int        ;Transaction in progress
        length      ,int        ;Length of a string
        ex_ms       ,int        ;Size of exception array
        ex_mc       ,int        ;Items in exception array
        continue    ,int        ;Continue after an error
        errtxt      ,a512       ;Error message text
<IF STRUCTURE_RELATIVE>
        recordNumber,d28
</IF STRUCTURE_RELATIVE>
    endrecord

<COUNTER_1_RESET>
    literal
        sql         ,a*, "INSERT INTO <StructureName> ("
<IF STRUCTURE_RELATIVE>
  <COUNTER_1_INCREMENT>
        & +              '"RecordNumber",' ;#<COUNTER_1_VALUE>
</IF STRUCTURE_RELATIVE>
<FIELD_LOOP>
  <IF CUSTOM_NOT_REPLICATOR_EXCLUDE>
    <COUNTER_1_INCREMENT>
        & +              '"<FieldSqlName>"<,>' ;#<COUNTER_1_VALUE>
  </IF CUSTOM_NOT_REPLICATOR_EXCLUDE>
</FIELD_LOOP>
<COUNTER_1_RESET>
        & +              ") VALUES(<IF STRUCTURE_RELATIVE>:1,<COUNTER_1_INCREMENT></IF STRUCTURE_RELATIVE><FIELD_LOOP><IF CUSTOM_NOT_REPLICATOR_EXCLUDE><COUNTER_1_INCREMENT><IF USERTIMESTAMP>CONVERT(DATETIME2,:<COUNTER_1_VALUE>,21)<,><ELSE>:<COUNTER_1_VALUE><,></IF USERTIMESTAMP></IF CUSTOM_NOT_REPLICATOR_EXCLUDE></FIELD_LOOP>)"
    endliteral

<IF STRUCTURE_ISAM>
    .include "<STRUCTURE_NOALIAS>" repository, structure="inpbuf", nofields, end
<ELSE STRUCTURE_RELATIVE>
    structure inpbuf
        recnum, d28
        .include "<STRUCTURE_NOALIAS>" repository, group="inprec", nofields
    endstructure
</IF STRUCTURE_ISAM>
    .include "<STRUCTURE_NOALIAS>" repository, static record="<structure_name>", end

    static record
<FIELD_LOOP>
  <IF CUSTOM_NOT_REPLICATOR_EXCLUDE>
    <IF CUSTOM_DBL_TYPE>
        tmp<FieldSqlName>, <FIELD_CUSTOM_DBL_TYPE>
    <ELSE USERTIMESTAMP>
        tmp<FieldSqlName>, a26     ;Storage for user-defined timestamp field
    <ELSE TIME_HHMM>
        tmp<FieldSqlName>, a5      ;Storage for HH:MM time field
    <ELSE TIME_HHMMSS>
        tmp<FieldSqlName>, a8      ;Storage for HH:MM:SS time field
    <ELSE DEFINED_ASA_TIREMAX AND USER>
        tmp<FieldSqlName>, a8      ;Storage for user defined JJJJJJ date field
    </IF CUSTOM_DBL_TYPE>
  </IF CUSTOM_NOT_REPLICATOR_EXCLUDE>
</FIELD_LOOP>
        ,a1                         ;In case there are no user timestamp, date or JJJJJJ date fields
    endrecord

    global common
        c2<StructureName>, i4
    endcommon

;//If any fields have a custom data type, declare the functions that convert the value
<COUNTER_1_RESET><FIELD_LOOP><IF CUSTOM_CONVERT_FUNCTION><COUNTER_1_INCREMENT></IF></FIELD_LOOP><IF COUNTER_1>
    external function
  <FIELD_LOOP>
    <IF CUSTOM_CONVERT_FUNCTION>
        <FIELD_CUSTOM_CONVERT_FUNCTION>, <FIELD_CUSTOM_DBL_TYPE>
    </IF>
  </FIELD_LOOP>
    endexternal
</IF>
proc

    init local_data
    ok = true

    openAndBind = (c2<StructureName> == 0)

    if (^passed(a_exception)&&a_exception)
        clear a_exception

    ;Figure out how many rows to insert

    rows = (%mem_proc(DM_GETSIZE,a_data)/^size(inpbuf))

    ;If enabled, disable auto-commit

    if (a_commit_mode==1)
    begin
        if (%ssc_cmd(a_dbchn,,SSQL_ODBC_AUTOCOMMIT,"no")!=SSQL_NORMAL)
        begin
            data dberrtxt, a1024
            xcall ssc_getemsg(a_dbchn,dberrtxt,length)
            errtxt = "Failed to disable auto-commit. Error was: " + dberrtxt(1,length)
            ok = false
        end
    end

    ;Start a database transaction

    if (ok)
    begin
        if (%ssc_commit(a_dbchn,SSQL_TXON)==SSQL_NORMAL) then
            transaction=1
        else
        begin
            ok = false
            if (%ssc_getemsg(a_dbchn,errtxt,length,,dberror)==SSQL_FAILURE) then
                errtxt="Failed to start transaction"
            else
                xcall ThrowOnCommunicationError("<StructureName>InsertRows",dberror,errtxt)
        end
    end

    ;Open a cursor for the INSERT statement

    if (ok && openAndBind)
    begin
        if (%ssc_open(a_dbchn,c2<StructureName>,sql,SSQL_NONSEL,SSQL_STANDARD)==SSQL_FAILURE)
        begin
            ok = false
            if (%ssc_getemsg(a_dbchn,errtxt,length,,dberror)==SSQL_FAILURE) then
                errtxt="Failed to open cursor"
            else
                xcall ThrowOnCommunicationError("<StructureName>InsertRows",dberror,errtxt)
        end
    end

    ;Bind the host variables for data to be inserted

<IF STRUCTURE_RELATIVE>
    if (ok && openAndBind)
    begin
        if (%ssc_bind(a_dbchn,c2<StructureName>,1,recordNumber)==SSQL_FAILURE)
        begin
            ok = false
            if (%ssc_getemsg(a_dbchn,errtxt,length,,dberror)==SSQL_FAILURE) then
                errtxt="Failed to bind variables"
            else
                xcall ThrowOnCommunicationError("<StructureName>InsertRows",dberror,errtxt)
        end
    end

</IF STRUCTURE_RELATIVE>
<COUNTER_1_RESET>
<FIELD_LOOP>
  <IF CUSTOM_NOT_REPLICATOR_EXCLUDE>
    <COUNTER_1_INCREMENT>
    <IF COUNTER_1_EQ_1>
    if (ok && openAndBind)
    begin
        if (%ssc_bind(a_dbchn,c2<StructureName>,<REPLICATION_REMAINING_INCLUSIVE_MAX_250>,
    </IF COUNTER_1_EQ_1>
    <IF CUSTOM_DBL_TYPE>
        &    tmp<FieldSqlName><IF NOMORE>)==SSQL_FAILURE)<ELSE><IF COUNTER_1_LT_250>,<ELSE>)==SSQL_FAILURE)</IF COUNTER_1_LT_250></IF NOMORE>
    <ELSE ALPHA>
        &    <structure_name>.<field_original_name_modified><IF NOMORE>)==SSQL_FAILURE)<ELSE><IF COUNTER_1_LT_250>,<ELSE>)==SSQL_FAILURE)</IF COUNTER_1_LT_250></IF NOMORE>
    <ELSE DECIMAL>
        &    <structure_name>.<field_original_name_modified><IF NOMORE>)==SSQL_FAILURE)<ELSE><IF COUNTER_1_LT_250>,<ELSE>)==SSQL_FAILURE)</IF COUNTER_1_LT_250></IF NOMORE>
    <ELSE INTEGER>
        &    <structure_name>.<field_original_name_modified><IF NOMORE>)==SSQL_FAILURE)<ELSE><IF COUNTER_1_LT_250>,<ELSE>)==SSQL_FAILURE)</IF COUNTER_1_LT_250></IF NOMORE>
    <ELSE DATE>
        &    ^a(<structure_name>.<field_original_name_modified>)<IF NOMORE>)==SSQL_FAILURE)<ELSE><IF COUNTER_1_LT_250>,<ELSE>)==SSQL_FAILURE)</IF COUNTER_1_LT_250></IF NOMORE>
    <ELSE TIME>
        &    tmp<FieldSqlName><IF NOMORE>)==SSQL_FAILURE)<ELSE><IF COUNTER_1_LT_250>,<ELSE>)==SSQL_FAILURE)</IF COUNTER_1_LT_250></IF NOMORE>
    <ELSE USER AND USERTIMESTAMP>
        &    tmp<FieldSqlName><IF NOMORE>)==SSQL_FAILURE)<ELSE><IF COUNTER_1_LT_250>,<ELSE>)==SSQL_FAILURE)</IF COUNTER_1_LT_250></IF NOMORE>
    <ELSE USER AND NOT USERTIMESTAMP AND NOT DEFINED_ASA_TIREMAX>
        &    <structure_name>.<field_original_name_modified><IF NOMORE>)==SSQL_FAILURE)<ELSE><IF COUNTER_1_LT_250>,<ELSE>)==SSQL_FAILURE)</IF COUNTER_1_LT_250></IF NOMORE>
    <ELSE USER AND NOT USERTIMESTAMP AND DEFINED_ASA_TIREMAX>
        &    tmp<FieldSqlName><IF NOMORE>)==SSQL_FAILURE)<ELSE><IF COUNTER_1_LT_250>,<ELSE>)==SSQL_FAILURE)</IF COUNTER_1_LT_250></IF NOMORE>
    </IF CUSTOM_DBL_TYPE>
    <IF COUNTER_1_EQ_250>
        begin
            ok = false
            if (%ssc_getemsg(a_dbchn,errtxt,length,,dberror)==SSQL_FAILURE) then
                errtxt="Failed to bind variables"
            else
                xcall ThrowOnCommunicationError("<StructureName>InsertRows",dberror,errtxt)
        end
    end
      <COUNTER_1_RESET>
    <ELSE NOMORE>
        begin
            ok = false
            if (%ssc_getemsg(a_dbchn,errtxt,length,,dberror)==SSQL_FAILURE) then
                errtxt="Failed to bind variables"
            else
                xcall ThrowOnCommunicationError("<StructureName>InsertRows",dberror,errtxt)
        end
    end
    </IF COUNTER_1_EQ_250>
  </IF CUSTOM_NOT_REPLICATOR_EXCLUDE>
</FIELD_LOOP>

    ;Insert the rows into the database

    if (ok)
    begin
        data cnt, int
        for cnt from 1 thru rows
        begin
            ;Load data into bound record

<IF STRUCTURE_ISAM AND STRUCTURE_MAPPED>
            <structure_name> = %<structure_name>_map(^m(inpbuf[cnt],a_data))
<ELSE STRUCTURE_ISAM AND NOT STRUCTURE_MAPPED>
            <structure_name> = ^m(inpbuf[cnt],a_data)
<ELSE STRUCTURE_RELATIVE AND STRUCTURE_MAPPED>
            recordNumber = ^m(inpbuf[cnt].recnum,a_data)
            <structure_name> = %<structure_name>_map(^m(inpbuf[cnt].inprec,a_data))
<ELSE STRUCTURE_RELATIVE AND NOT STRUCTURE_MAPPED>
            recordNumber = ^m(inpbuf[cnt].recnum,a_data)
            <structure_name> = ^m(inpbuf[cnt].inprec,a_data)
</IF STRUCTURE_ISAM>

<IF DEFINED_CLEAN_DATA>
            ;Clean up any alpha variables

  <FIELD_LOOP>
    <IF ALPHA AND CUSTOM_NOT_REPLICATOR_EXCLUDE AND NOT FIRST_UNIQUE_KEY_SEGMENT>
            <structure_name>.<field_original_name_modified> = %atrim(<structure_name>.<field_original_name_modified>)+%char(0)
    </IF ALPHA>
  </FIELD_LOOP>

            ;Clean up any decimal variables

  <FIELD_LOOP>
    <IF DECIMAL AND CUSTOM_NOT_REPLICATOR_EXCLUDE>
            if ((!<structure_name>.<field_original_name_modified>)||(!<IF NEGATIVE_ALLOWED>%IsDecimalNegatives<ELSE>%IsDecimalNoNegatives</IF NEGATIVE_ALLOWED>(<structure_name>.<field_original_name_modified>)))
                clear <structure_name>.<field_original_name_modified>
    </IF DECIMAL>
  </FIELD_LOOP>

            ;Clean up any date variables

  <FIELD_LOOP>
    <IF DATE AND CUSTOM_NOT_REPLICATOR_EXCLUDE>
            if ((!<structure_name>.<field_original_name_modified>)||(!%IsDate(^a(<structure_name>.<field_original_name_modified>))))
      <IF FIRST_UNIQUE_KEY_SEGMENT>
                ^a(<structure_name>.<field_original_name_modified>) = "17530101"
      <ELSE>
                ^a(<structure_name>.<field_original_name_modified>(1:1))=%char(0)
      </IF FIRST_UNIQUE_KEY_SEGMENT>
    </IF DATE>
  </FIELD_LOOP>

            ;Clean up any time variables

  <FIELD_LOOP>
    <IF TIME AND CUSTOM_NOT_REPLICATOR_EXCLUDE>
            if ((!<structure_name>.<field_original_name_modified>)||(!%IsTime(^a(<structure_name>.<field_original_name_modified>))))
                ^a(<structure_name>.<field_original_name_modified>(1:1))=%char(0)
    </IF TIME>
  </FIELD_LOOP>

</IF DEFINED_CLEAN_DATA>
            ;Assign any time or user-defined timestamp fields

<FIELD_LOOP>
  <IF CUSTOM_NOT_REPLICATOR_EXCLUDE>
    <IF USERTIMESTAMP>
            tmp<FieldSqlName> = %string(^d(<structure_name>.<field_original_name_modified>),"XXXX-XX-XX XX:XX:XX.XXXXXX")
    <ELSE TIME_HHMM>
            tmp<FieldSqlName> = %string(<structure_name>.<field_original_name_modified>,"XX:XX")
    <ELSE TIME_HHMMSS>
            tmp<FieldSqlName> = %string(<structure_name>.<field_original_name_modified>,"XX:XX:XX")
    <ELSE DEFINED_ASA_TIREMAX AND USER>
            tmp<FieldSqlName> = %TmJulianToYYYYMMDD(<field_path>)
    </IF USERTIMESTAMP>
  </IF CUSTOM_NOT_REPLICATOR_EXCLUDE>
</FIELD_LOOP>

        ;Assign values to temp fields for any fields with custom data types

<FIELD_LOOP>
  <IF CUSTOM_DBL_TYPE>
            tmp<FieldSqlName> = %<FIELD_CUSTOM_CONVERT_FUNCTION>(<field_path>,<structure_name>)
  </IF CUSTOM_DBL_TYPE>
</FIELD_LOOP>

            ;Execute the statement

            if (%ssc_execute(a_dbchn,c2<StructureName>,SSQL_STANDARD)==SSQL_FAILURE)
            begin
                if (%ssc_getemsg(a_dbchn,errtxt,length,,dberror)==SSQL_FAILURE) then
                    errtxt="Failed to execute SQL statement"
                else
                    xcall ThrowOnCommunicationError("<StructureName>InsertRows",dberror,errtxt)

                clear continue

                ;Are we logging errors?
                if (^passed(a_terminal)&&(a_terminal))
                begin
                    writes(a_terminal,errtxt(1:length))
                    continue=1
                end

                ;Are we processing exceptions?
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

    ;Commit or rollback the transaction

    if (transaction)
    begin
        if (ok) then
        begin
            ;Success, commit the transaction
            if (%ssc_commit(a_dbchn,SSQL_TXOFF)==SSQL_FAILURE)
            begin
                ok = false
                if (%ssc_getemsg(a_dbchn,errtxt,length,,dberror)==SSQL_FAILURE) then
                    errtxt="Failed to commit transaction"
                else
                    xcall ThrowOnCommunicationError("<StructureName>InsertRows",dberror,errtxt)
            end
        end
        else
        begin
            ;There was an error, rollback the transaction
            if (%ssc_rollback(a_dbchn,SSQL_TXOFF) == SSQL_FAILURE)
            begin
                ok = false
                if (%ssc_getemsg(a_dbchn,errtxt,length,,dberror)==SSQL_FAILURE) then
                    errtxt="Failed to rollback transaction"
                else
                    xcall ThrowOnCommunicationError("<StructureName>InsertRows",dberror,errtxt)
            end
        end
    end

    ;If necessary, re-enable auto-commit

    if (a_commit_mode==1)
    begin
        if (%ssc_cmd(a_dbchn,,SSQL_ODBC_AUTOCOMMIT,"yes")!=SSQL_NORMAL)
        begin
            data dberrtxt, a1024
            xcall ssc_getemsg(a_dbchn,dberrtxt,length)
            errtxt = "Failed to enable auto-commit. Error was: " + dberrtxt(1,length)
            ok = false
        end
    end

    ;If we're returning exceptions then resize the buffer to the correct size

    if (^passed(a_exception)&&a_exception)
        a_exception = %mem_proc(DM_RESIZ,^size(inpbuf)*ex_mc,a_exception)

    ;If there was an error message, return it to the calling routine

    if (^passed(a_errtxt))
    begin
        if (ok) then
            clear a_errtxt
        else
            a_errtxt = %atrim(errtxt)+" [Database error "+%string(dberror)+"]"
    end

    freturn ok

endfunction

;*****************************************************************************
;;; <summary>
;;; Updates a row in the <StructureName> table.
;;; </summary>
;;; <param name="a_dbchn">Connected database channel.</param>
;;; <param name="a_commit_mode">What commit mode are we using?</param>
<IF STRUCTURE_RELATIVE>
;;; <param name="a_recnum">record number.</param>
</IF STRUCTURE_RELATIVE>
;;; <param name="a_data">Record containing data to update.</param>
;;; <param name="a_rows">Returned number of rows affected.</param>
;;; <param name="a_errtxt">Returned error text.</param>
;;; <returns>Returns true on success, otherwise false.</returns>

function <StructureName>Update, ^val

    required in  a_dbchn,  i
    required in  a_commit_mode, i
<IF STRUCTURE_RELATIVE>
    required in  a_recnum, n
</IF STRUCTURE_RELATIVE>
    required in  a_data,   a
    optional out a_rows,   i
    optional out a_errtxt, a
    endparams

    .include "CONNECTDIR:ssql.def"

<IF DEFINED_ASA_TIREMAX>
    external function
        TmJulianToYYYYMMDD, a
    endexternal

</IF DEFINED_ASA_TIREMAX>
    stack record local_data
        ok          ,boolean    ;OK to continue
        openAndBind ,boolean    ;Should we open the cursor and bind data this time?
        transaction ,boolean    ;Transaction in progress
        dberror     ,int        ;Database error number
        cursor      ,int        ;Database cursor
        length      ,int        ;Length of a string
        rows        ,int        ;Number of rows updated
        errtxt      ,a512       ;Error message text
    endrecord

    literal
        sql         ,a*, 'UPDATE <StructureName> SET '
<COUNTER_1_RESET>
<COUNTER_2_RESET>
<FIELD_LOOP>
  <IF CUSTOM_NOT_REPLICATOR_EXCLUDE>
    <COUNTER_1_INCREMENT>
    <COUNTER_2_INCREMENT>
    <IF USERTIMESTAMP>
        & +              '"<FieldSqlName>"=CONVERT(DATETIME2,:<COUNTER_1_VALUE>,21)<,>'
    <ELSE>
        & +              '"<FieldSqlName>"=:<COUNTER_1_VALUE><,>'
    </IF USERTIMESTAMP>
  </IF CUSTOM_NOT_REPLICATOR_EXCLUDE>
</FIELD_LOOP>
<IF STRUCTURE_ISAM>
        & +              ' WHERE <UNIQUE_KEY><SEGMENT_LOOP><COUNTER_1_INCREMENT>"<FieldSqlName>"=:<COUNTER_1_VALUE> <AND> </SEGMENT_LOOP></UNIQUE_KEY>'
<ELSE STRUCTURE_RELATIVE>
        & +              ' WHERE "RecordNumber"=:<COUNTER_1_INCREMENT><COUNTER_1_VALUE>'
</IF STRUCTURE_ISAM>
    endliteral

    static record
        <structure_name>, str<StructureName>
<FIELD_LOOP>
  <IF CUSTOM_NOT_REPLICATOR_EXCLUDE>
    <IF CUSTOM_DBL_TYPE>
        tmp<FieldSqlName>, <FIELD_CUSTOM_DBL_TYPE>
    <ELSE USERTIMESTAMP>
        tmp<FieldSqlName>, a26     ;Storage for user-defined timestamp field
    <ELSE TIME_HHMM>
        tmp<FieldSqlName>, a5      ;Storage for HH:MM time field
    <ELSE TIME_HHMMSS>
        tmp<FieldSqlName>, a8      ;Storage for HH:MM:SS time field
    <ELSE DEFINED_ASA_TIREMAX AND USER>
        tmp<FieldSqlName>, a8      ;Storage for user defined JJJJJJ date field
    </IF CUSTOM_DBL_TYPE>
  </IF CUSTOM_NOT_REPLICATOR_EXCLUDE>
</FIELD_LOOP>
    endrecord

    global common
        c3<StructureName>, i4
    endcommon

;//If any fields have a custom data type, declare the functions that convert the value
<COUNTER_1_RESET><FIELD_LOOP><IF CUSTOM_CONVERT_FUNCTION><COUNTER_1_INCREMENT></IF></FIELD_LOOP><IF COUNTER_1>
    external function
  <FIELD_LOOP>
    <IF CUSTOM_CONVERT_FUNCTION>
        <FIELD_CUSTOM_CONVERT_FUNCTION>, <FIELD_CUSTOM_DBL_TYPE>
    </IF>
  </FIELD_LOOP>
    endexternal
</IF>
proc

    init local_data
    ok = true

    openAndBind = (c3<StructureName> == 0)

    if (^passed(a_rows))
        clear a_rows

    ;Load the data into the bound record

    <IF STRUCTURE_MAPPED>
    <structure_name> = %<structure_name>_map(a_data)
    <ELSE>
    <structure_name> = a_data
    </IF STRUCTURE_MAPPED>

    ;Start a database transaction

    if (a_commit_mode==3)
    begin
        if (%ssc_commit(a_dbchn,SSQL_TXON)==SSQL_NORMAL) then
            transaction = true
        else
        begin
            ok = false
            if (%ssc_getemsg(a_dbchn,errtxt,length,,dberror)==SSQL_FAILURE) then
                errtxt="Failed to start transaction"
            else
                xcall ThrowOnCommunicationError("<StructureName>Update",dberror,errtxt)
        end
    end

    ;Open a cursor for the UPDATE statement

    if (ok && openAndBind)
    begin
        if (%ssc_open(a_dbchn,c3<StructureName>,sql,SSQL_NONSEL,SSQL_STANDARD)==SSQL_FAILURE)
        begin
            ok = false
            if (%ssc_getemsg(a_dbchn,errtxt,length,,dberror)==SSQL_FAILURE) then
                errtxt="Failed to open cursor"
            else
                xcall ThrowOnCommunicationError("<StructureName>Update",dberror,errtxt)
        end
    end

    ;Bind the host variables for data to be updated
<COUNTER_1_RESET>
<FIELD_LOOP>
  <IF CUSTOM_NOT_REPLICATOR_EXCLUDE>
    <COUNTER_1_INCREMENT>
    <IF COUNTER_1_EQ_1>

    if (ok && openAndBind)
    begin
        if (%ssc_bind(a_dbchn,c3<StructureName>,<REPLICATION_REMAINING_INCLUSIVE_MAX_250>,
    </IF COUNTER_1_EQ_1>
    <IF CUSTOM_DBL_TYPE>
        &    tmp<FieldSqlName><IF NOMORE>)==SSQL_FAILURE)<ELSE><IF COUNTER_1_LT_250>,<ELSE>)==SSQL_FAILURE)</IF COUNTER_1_LT_250></IF NOMORE>
    <ELSE ALPHA>
        &    <structure_name>.<field_original_name_modified><IF NOMORE>)==SSQL_FAILURE)<ELSE><IF COUNTER_1_LT_250>,<ELSE>)==SSQL_FAILURE)</IF COUNTER_1_LT_250></IF NOMORE>
    <ELSE DECIMAL>
        &    <structure_name>.<field_original_name_modified><IF NOMORE>)==SSQL_FAILURE)<ELSE><IF COUNTER_1_LT_250>,<ELSE>)==SSQL_FAILURE)</IF COUNTER_1_LT_250></IF NOMORE>
    <ELSE INTEGER>
        &    <structure_name>.<field_original_name_modified><IF NOMORE>)==SSQL_FAILURE)<ELSE><IF COUNTER_1_LT_250>,<ELSE>)==SSQL_FAILURE)</IF COUNTER_1_LT_250></IF NOMORE>
    <ELSE DATE>
        &    ^a(<structure_name>.<field_original_name_modified>)<IF NOMORE>)==SSQL_FAILURE)<ELSE><IF COUNTER_1_LT_250>,<ELSE>)==SSQL_FAILURE)</IF COUNTER_1_LT_250></IF NOMORE>
    <ELSE TIME>
        &    tmp<FieldSqlName><IF NOMORE>)==SSQL_FAILURE)<ELSE><IF COUNTER_1_LT_250>,<ELSE>)==SSQL_FAILURE)</IF COUNTER_1_LT_250></IF NOMORE>
    <ELSE USER AND USERTIMESTAMP>
        &    tmp<FieldSqlName><IF NOMORE>)==SSQL_FAILURE)<ELSE><IF COUNTER_1_LT_250>,<ELSE>)==SSQL_FAILURE)</IF COUNTER_1_LT_250></IF NOMORE>
    <ELSE USER AND NOT USERTIMESTAMP AND NOT DEFINED_ASA_TIREMAX>
        &    <structure_name>.<field_original_name_modified><IF NOMORE>)==SSQL_FAILURE)<ELSE><IF COUNTER_1_LT_250>,<ELSE>)==SSQL_FAILURE)</IF COUNTER_1_LT_250></IF NOMORE>
    <ELSE USER AND NOT USERTIMESTAMP AND DEFINED_ASA_TIREMAX>
        &    tmp<FieldSqlName><IF NOMORE>)==SSQL_FAILURE)<ELSE><IF COUNTER_1_LT_250>,<ELSE>)==SSQL_FAILURE)</IF COUNTER_1_LT_250></IF NOMORE>
    </IF CUSTOM_DBL_TYPE>
    <IF COUNTER_1_EQ_250>
        begin
            ok = false
            if (%ssc_getemsg(a_dbchn,errtxt,length,,dberror)==SSQL_FAILURE) then
                errtxt="Failed to bind variables"
            else
                xcall ThrowOnCommunicationError("<StructureName>Update",dberror,errtxt)
        end
    end
      <COUNTER_1_RESET>
    <ELSE NOMORE>
        begin
            ok = false
            if (%ssc_getemsg(a_dbchn,errtxt,length,,dberror)==SSQL_FAILURE) then
                errtxt="Failed to bind variables"
            else
                xcall ThrowOnCommunicationError("<StructureName>Update",dberror,errtxt)
        end
    end
    </IF COUNTER_1_EQ_250>
  </IF CUSTOM_NOT_REPLICATOR_EXCLUDE>
</FIELD_LOOP>

    ;Bind the host variables for the key segments / WHERE clause

    if (ok && openAndBind)
    begin
<IF STRUCTURE_ISAM>
        if (%ssc_bind(a_dbchn,c3<StructureName>,<UNIQUE_KEY><KEY_SEGMENTS>,<SEGMENT_LOOP><IF DATEORTIME>^a(</IF DATEORTIME><structure_name>.<segment_name><IF DATEORTIME>)</IF DATEORTIME><,></SEGMENT_LOOP></UNIQUE_KEY>)==SSQL_FAILURE)
<ELSE STRUCTURE_RELATIVE>
        if (%ssc_bind(a_dbchn,c3<StructureName>,1,a_recnum)==SSQL_FAILURE)
</IF STRUCTURE_ISAM>
        begin
            ok = false
            if (%ssc_getemsg(a_dbchn,errtxt,length,,dberror)==SSQL_FAILURE) then
                errtxt="Failed to bind key variables"
            else
                xcall ThrowOnCommunicationError("<StructureName>Update",dberror,errtxt)
        end
    end

    ;Update the row in the database

    if (ok)
    begin
<IF DEFINED_CLEAN_DATA>
        ;Clean up any alpha fields

  <FIELD_LOOP>
    <IF ALPHA AND CUSTOM_NOT_REPLICATOR_EXCLUDE AND NOT FIRST_UNIQUE_KEY_SEGMENT>
        <structure_name>.<field_original_name_modified> = %atrim(<structure_name>.<field_original_name_modified>)+%char(0)
    </IF ALPHA>
  </FIELD_LOOP>

        ;Clean up any decimal fields

  <FIELD_LOOP>
    <IF DECIMAL AND CUSTOM_NOT_REPLICATOR_EXCLUDE>
        if ((!<structure_name>.<field_original_name_modified>)||(!<IF NEGATIVE_ALLOWED>%IsDecimalNegatives<ELSE>%IsDecimalNoNegatives</IF NEGATIVE_ALLOWED>(<structure_name>.<field_original_name_modified>)))
            clear <structure_name>.<field_original_name_modified>
    </IF DECIMAL>
  </FIELD_LOOP>

        ;Clean up any date fields

  <FIELD_LOOP>
    <IF DATE AND CUSTOM_NOT_REPLICATOR_EXCLUDE>
        if ((!<structure_name>.<field_original_name_modified>)||(!%IsDate(^a(<structure_name>.<field_original_name_modified>))))
        <IF FIRST_UNIQUE_KEY_SEGMENT>
            ^a(<structure_name>.<field_original_name_modified>) = "17530101"
        <ELSE>
            ^a(<structure_name>.<field_original_name_modified>(1:1)) = %char(0)
        </IF FIRST_UNIQUE_KEY_SEGMENT>
    </IF DATE>
  </FIELD_LOOP>

        ;Clean up any time fields

  <FIELD_LOOP>
    <IF TIME AND CUSTOM_NOT_REPLICATOR_EXCLUDE>
        if ((!<structure_name>.<field_original_name_modified>)||(!%IsTime(^a(<structure_name>.<field_original_name_modified>))))
            ^a(<structure_name>.<field_original_name_modified>(1:1)) = %char(0)
    </IF TIME>
  </FIELD_LOOP>

</IF DEFINED_CLEAN_DATA>
        ;Assign any time and user-defined timestamp fields

<FIELD_LOOP>
  <IF CUSTOM_NOT_REPLICATOR_EXCLUDE>
    <IF USERTIMESTAMP>
        tmp<FieldSqlName> = %string(^d(<structure_name>.<field_original_name_modified>),"XXXX-XX-XX XX:XX:XX.XXXXXX")
    <ELSE TIME_HHMM>
        tmp<FieldSqlName> = %string(<structure_name>.<field_original_name_modified>,"XX:XX")
    <ELSE TIME_HHMMSS>
        tmp<FieldSqlName> = %string(<structure_name>.<field_original_name_modified>,"XX:XX:XX")
    <ELSE DEFINED_ASA_TIREMAX AND USER>
        tmp<FieldSqlName> = %TmJulianToYYYYMMDD(<field_path>)
    </IF USERTIMESTAMP>
  </IF CUSTOM_NOT_REPLICATOR_EXCLUDE>
</FIELD_LOOP>

        ;Assign values to temp fields for any fields with custom data types

<FIELD_LOOP>
  <IF CUSTOM_DBL_TYPE>
        tmp<FieldSqlName> = %<FIELD_CUSTOM_CONVERT_FUNCTION>(<field_path>,<structure_name>)
  </IF CUSTOM_DBL_TYPE>
</FIELD_LOOP>

        if (%ssc_execute(a_dbchn,c3<StructureName>,SSQL_STANDARD,,rows)==SSQL_NORMAL) then
        begin
            if (^passed(a_rows))
                a_rows = rows
        end
        else
        begin
            ok = false
            if (%ssc_getemsg(a_dbchn,errtxt,length,,dberror)==SSQL_FAILURE) then
                errtxt="Failed to execute SQL statement"
            else
                xcall ThrowOnCommunicationError("<StructureName>Update",dberror,errtxt)
        end
    end

    ;Commit or rollback the transaction

    if ((a_commit_mode==3) && transaction)
    begin
        if (ok) then
        begin
            ;Success, commit the transaction
            if (%ssc_commit(a_dbchn,SSQL_TXOFF)==SSQL_FAILURE)
            begin
                ok = false
                if (%ssc_getemsg(a_dbchn,errtxt,length,,dberror)==SSQL_FAILURE) then
                    errtxt="Failed to commit transaction"
                else
                    xcall ThrowOnCommunicationError("<StructureName>Update",dberror,errtxt)
            end
        end
        else
        begin
            ;There was an error, rollback the transaction
            if (%ssc_rollback(a_dbchn,SSQL_TXOFF) == SSQL_FAILURE)
            begin
                ok = false
                if (%ssc_getemsg(a_dbchn,errtxt,length,,dberror)==SSQL_FAILURE) then
                    errtxt="Failed to rollback transaction"
                else
                    xcall ThrowOnCommunicationError("<StructureName>Update",dberror,errtxt)
            end
        end
    end

    ;Return error message

    if (^passed(a_errtxt))
    begin
        if (ok) then
            clear a_errtxt
        else
            a_errtxt = errtxt
    end

    freturn ok

endfunction

<IF STRUCTURE_ISAM>
;*****************************************************************************
;;; <summary>
;;; Deletes a row from the <StructureName> table.
;;; </summary>
;;; <param name="a_dbchn">Connected database channel.</param>
;;; <param name="a_commit_mode">What commit mode are we using?</param>
;;; <param name="a_key">Unique key of row to be deleted.</param>
;;; <param name="a_errtxt">Returned error text.</param>
;;; <returns>Returns true on success, otherwise false.</returns>

function <StructureName>Delete, ^val

    required in  a_dbchn,  i
    required in  a_commit_mode, i
    required in  a_key,    a
    optional out a_errtxt, a
    endparams

    .include "CONNECTDIR:ssql.def"
    .include "<STRUCTURE_NOALIAS>" repository, stack record="<structureName>"

    external function
        <StructureName>KeyToRecord, a
<IF DEFINED_ASA_TIREMAX>
        TmJulianToYYYYMMDD, a
</IF DEFINED_ASA_TIREMAX>
    endexternal

    stack record local_data
        ok          ,boolean    ;Return status
        dberror     ,int        ;Database error number
        cursor      ,int        ;Database cursor
        length      ,int        ;Length of a string
        transaction ,int        ;Transaction in progress
        errtxt      ,a512       ;Error message text
        sql         ,string     ;SQL statement
    endrecord

proc

    init local_data
    ok = true

    ;Put the unique key value into the record

    <structureName> = %<StructureName>KeyToRecord(a_key)

    ;Start a database transaction

    if (a_commit_mode==3)
    begin
        if (%ssc_commit(a_dbchn,SSQL_TXON)==SSQL_NORMAL) then
            transaction=1
        else
        begin
            ok = false
            if (%ssc_getemsg(a_dbchn,errtxt,length,,dberror)==SSQL_FAILURE) then
                errtxt="Failed to start transaction"
            else
                xcall ThrowOnCommunicationError("<StructureName>Delete",dberror,errtxt)
        end
    end

    ;Open a cursor for the DELETE statement

    if (ok)
    begin
        sql = 'DELETE FROM "<StructureName>" WHERE'
  <UNIQUE_KEY>
    <SEGMENT_LOOP>
      <IF ALPHA>
        & + ' "<FieldSqlName>"=' + "'" + %atrim(<structureName>.<segment_name>) + "' <AND>"
      <ELSE NOT DEFINED_ASA_TIREMAX>
        & + ' "<FieldSqlName>"=' + "'" + %string(<structureName>.<segment_name>) + "' <AND>"
      <ELSE DEFINED_ASA_TIREMAX AND USER>
        & + " <SegmentName>='" + %TmJulianToYYYYMMDD(<structureName>.<segment_name>) + "' <AND>"
      <ELSE DEFINED_ASA_TIREMAX AND NOT USER>
        & + ' "<FieldSqlName>"=' + "'" + %string(<structureName>.<segment_name>) + "' <AND>"
      </IF ALPHA>
    </SEGMENT_LOOP>
  </UNIQUE_KEY>
        if (%ssc_open(a_dbchn,cursor,(a)sql,SSQL_NONSEL)==SSQL_FAILURE)
        begin
            ok = false
            if (%ssc_getemsg(a_dbchn,errtxt,length,,dberror)==SSQL_FAILURE) then
                errtxt="Failed to open cursor"
            else
                xcall ThrowOnCommunicationError("<StructureName>Delete",dberror,errtxt)
        end
    end

    ;Execute the query

    if (ok)
    begin
        if (%ssc_execute(a_dbchn,cursor,SSQL_STANDARD)==SSQL_FAILURE)
        begin
            ok = false
            if (%ssc_getemsg(a_dbchn,errtxt,length,,dberror)==SSQL_FAILURE) then
                errtxt="Failed to execute SQL statement"
            else
                xcall ThrowOnCommunicationError("<StructureName>Delete",dberror,errtxt)
        end
    end

    ;Close the database cursor

    if (cursor)
    begin
        if (%ssc_close(a_dbchn,cursor)==SSQL_FAILURE)
        begin
            if (ok)
            begin
                ok = false
                if (%ssc_getemsg(a_dbchn,errtxt,length,,dberror)==SSQL_FAILURE) then
                    errtxt="Failed to close cursor"
                else
                    xcall ThrowOnCommunicationError("<StructureName>Delete",dberror,errtxt)
            end
        end
    end

    ;Commit or rollback the transaction

    if ((a_commit_mode==3) && transaction)
    begin
        if (ok) then
        begin
            ;Success, commit the transaction
            if (%ssc_commit(a_dbchn,SSQL_TXOFF)==SSQL_FAILURE)
            begin
                ok = false
                if (%ssc_getemsg(a_dbchn,errtxt,length,,dberror)==SSQL_FAILURE) then
                    errtxt="Failed to commit transaction"
                else
                    xcall ThrowOnCommunicationError("<StructureName>Delete",dberror,errtxt)
            end
        end
        else
        begin
            ;There was an error, rollback the transaction
            if (%ssc_rollback(a_dbchn,SSQL_TXOFF) == SSQL_FAILURE)
            begin
                ok = false
                if (%ssc_getemsg(a_dbchn,errtxt,length,,dberror)==SSQL_FAILURE) then
                    errtxt="Failed to rollback transaction"
                else
                    xcall ThrowOnCommunicationError("<StructureName>Delete",dberror,errtxt)
            end
        end
    end

    ;If there was an error message, return it to the calling routine

    if (^passed(a_errtxt))
    begin
        if (ok) then
            clear a_errtxt
        else
            a_errtxt = errtxt
    end

    freturn ok

endfunction

</IF STRUCTURE_ISAM>
;*****************************************************************************
;;; <summary>
;;; Deletes all rows from the <StructureName> table.
;;; </summary>
;;; <param name="a_dbchn">Connected database channel.</param>
;;; <param name="a_commit_mode">What commit mode are we using?</param>
;;; <param name="a_temp_table">Use TEMP table?</param>
;;; <param name="a_errtxt">Returned error text.</param>
;;; <returns>Returns true on success, otherwise false.</returns>

function <StructureName>Clear, ^val

    required in  a_dbchn,  i
    required in  a_commit_mode, i
    required in  a_temp_table, i
    optional out a_errtxt, a
    endparams

    .include "CONNECTDIR:ssql.def"

    stack record local_data
        ok          ,boolean    ;Return status
        dberror     ,int        ;Database error number
        cursor      ,int        ;Database cursor
        length      ,int        ;Length of a string
        transaction ,int        ;Transaction in process
        errtxt      ,a512       ;Returned error message text
        sql         ,string     ;SQL statement
    endrecord

proc

    init local_data
    ok = true

    ;Start a database transaction

    if (a_commit_mode==3)
    begin
        if (%ssc_commit(a_dbchn,SSQL_TXON)==SSQL_NORMAL) then
            transaction=1
        else
        begin
            ok = false
            if (%ssc_getemsg(a_dbchn,errtxt,length,,dberror)==SSQL_FAILURE) then
                errtxt="Failed to start transaction"
            else
                xcall ThrowOnCommunicationError("<StructureName>Clear",dberror,errtxt)
        end
    end

    ;Open cursor for the SQL statement

    if (ok)
    begin
        if (a_temp_table) then
            sql = 'TRUNCATE TABLE <StructureName>TEMP'
        else
            sql = 'TRUNCATE TABLE <StructureName>'

        if (%ssc_open(a_dbchn,cursor,(a)sql,SSQL_NONSEL)==SSQL_FAILURE)
        begin
            ok = false
            if (%ssc_getemsg(a_dbchn,errtxt,length,,dberror)==SSQL_FAILURE) then
                errtxt="Failed to open cursor"
            else
                xcall ThrowOnCommunicationError("<StructureName>Clear",dberror,errtxt)
        end
    end

    ;Execute SQL statement

    if (ok)
    begin
        if (%ssc_execute(a_dbchn,cursor,SSQL_STANDARD)==SSQL_FAILURE)
        begin
            ok = false
            if (%ssc_getemsg(a_dbchn,errtxt,length,,dberror)==SSQL_FAILURE) then
                errtxt="Failed to execute SQL statement"
            else
                xcall ThrowOnCommunicationError("<StructureName>Clear",dberror,errtxt)
        end
    end

    ;Close the database cursor

    if (cursor)
    begin
        if (%ssc_close(a_dbchn,cursor)==SSQL_FAILURE)
        begin
            if (ok)
            begin
                ok = false
                if (%ssc_getemsg(a_dbchn,errtxt,length,,dberror)==SSQL_FAILURE) then
                    errtxt="Failed to close cursor"
                else
                    xcall ThrowOnCommunicationError("<StructureName>Clear",dberror,errtxt)
            end
        end
    end

    ;Commit or rollback the transaction

    if ((a_commit_mode==3) && transaction)
    begin
        if (ok) then
        begin
            ;Success, commit the transaction
            if (%ssc_commit(a_dbchn,SSQL_TXOFF)==SSQL_FAILURE)
            begin
                ok = false
                if (%ssc_getemsg(a_dbchn,errtxt,length,,dberror)==SSQL_FAILURE) then
                    errtxt="Failed to commit transaction"
                else
                    xcall ThrowOnCommunicationError("<StructureName>Clear",dberror,errtxt)
            end
        end
        else
        begin
            ;There was an error, rollback the transaction
            if (%ssc_rollback(a_dbchn,SSQL_TXOFF) == SSQL_FAILURE)
            begin
                ok = false
                if (%ssc_getemsg(a_dbchn,errtxt,length,,dberror)==SSQL_FAILURE) then
                    errtxt="Failed to rollback transaction"
                else
                    xcall ThrowOnCommunicationError("<StructureName>Clear",dberror,errtxt)
            end
        end
    end

    ;If there was an error message, return it to the calling routine

    if (^passed(a_errtxt))
    begin
        if (ok) then
            clear a_errtxt
        else
            a_errtxt = errtxt
    end

    freturn ok

endfunction

;*****************************************************************************
;;; <summary>
;;; Deletes the <StructureName> table from the database.
;;; </summary>
;;; <param name="a_dbchn">Connected database channel.</param>
;;; <param name="a_commit_mode">What commit mode are we using?</param>
;;; <param name="a_temp_table">Use TEMP table?</param>
;;; <param name="a_errtxt">Returned error text.</param>
;;; <returns>Returns true on success, otherwise false.</returns>

function <StructureName>Drop, ^val

    required in  a_dbchn,  i
    required in  a_commit_mode, i
    required in  a_temp_table, i
    optional out a_errtxt, a
    endparams

    .include "CONNECTDIR:ssql.def"

    stack record local_data
        ok          ,boolean    ;Return status
        sql         ,string     ;SQL statement
        dberror     ,int        ;Database error number
        cursor      ,int        ;Database cursor
        length      ,int        ;Length of a string
        transaction ,int        ;Transaction in progress
        errtxt      ,a512       ;Returned error message text
    endrecord

proc

    init local_data
    ok = true

    ;Close any open cursors

    xcall <StructureName>Close(a_dbchn)

    ;Start a database transaction

    if (a_commit_mode==3)
    begin
        if (%ssc_commit(a_dbchn,SSQL_TXON)==SSQL_NORMAL) then
            transaction=1
        else
        begin
            ok = false
            if (%ssc_getemsg(a_dbchn,errtxt,length,,dberror)==SSQL_FAILURE) then
                errtxt="Failed to start transaction"
            else
                xcall ThrowOnCommunicationError("<StructureName>Drop",dberror,errtxt)
        end
    end

    ;Open cursor for DROP TABLE statement

    if (ok)
    begin
        sql = "DROP TABLE <StructureName>"

        if (a_temp_table)
            sql = sql + "TEMP"

        if (%ssc_open(a_dbchn,cursor,sql,SSQL_NONSEL)==SSQL_FAILURE)
        begin
            ok = false
            if (%ssc_getemsg(a_dbchn,errtxt,length,,dberror)==SSQL_FAILURE) then
                errtxt="Failed to open cursor"
            else
                xcall ThrowOnCommunicationError("<StructureName>Drop",dberror,errtxt)
        end
    end

    ;Execute DROP TABLE statement

    if (ok)
    begin
        if (%ssc_execute(a_dbchn,cursor,SSQL_STANDARD)==SSQL_FAILURE)
        begin
            if (%ssc_getemsg(a_dbchn,errtxt,length,,dberror)==SSQL_NORMAL) then
            begin
                ;Check if the error was that the table did not exist
                if (dberror==-3701) then
                    clear errtxt
                else
                begin
                    ok = false
                    xcall ThrowOnCommunicationError("<StructureName>Drop",dberror,errtxt)
                end
            end
            else
            begin
                errtxt="Failed to execute SQL statement"
                ok = false
            end
        end
    end

    ;Close the database cursor

    if (cursor)
    begin
        if (%ssc_close(a_dbchn,cursor)==SSQL_FAILURE)
        begin
            if (ok)
            begin
                ok = false
                if (%ssc_getemsg(a_dbchn,errtxt,length,,dberror)==SSQL_FAILURE) then
                    errtxt="Failed to close cursor"
                else
                    xcall ThrowOnCommunicationError("<StructureName>Drop",dberror,errtxt)
            end
        end
    end

    ;Commit or rollback the transaction

    if ((a_commit_mode==3) && transaction)
    begin
        if (ok) then
        begin
            ;Success, commit the transaction
            if (%ssc_commit(a_dbchn,SSQL_TXOFF)==SSQL_FAILURE)
            begin
                ok = false
                if (%ssc_getemsg(a_dbchn,errtxt,length,,dberror)==SSQL_FAILURE) then
                    errtxt="Failed to commit transaction"
                else
                    xcall ThrowOnCommunicationError("<StructureName>Drop",dberror,errtxt)
            end
        end
        else
        begin
            ;There was an error, rollback the transaction
            if (%ssc_rollback(a_dbchn,SSQL_TXOFF) == SSQL_FAILURE)
            begin
                ok = false
                if (%ssc_getemsg(a_dbchn,errtxt,length,,dberror)==SSQL_FAILURE) then
                    errtxt="Failed to rollback transaction"
                else
                    xcall ThrowOnCommunicationError("<StructureName>Drop",dberror,errtxt)
            end
        end
    end

    ;If there was an error message, return it to the calling routine

    if (^passed(a_errtxt))
    begin
        if (ok) then
            clear a_errtxt
        else
            a_errtxt = errtxt
    end

    freturn ok

endfunction

;*****************************************************************************
;;; <summary>
;;; Load all data from <IF STRUCTURE_MAPPED><MAPPED_FILE><ELSE><FILE_NAME></IF STRUCTURE_MAPPED> into the <StructureName> table.
;;; </summary>
;;; <param name="a_dbchn">Connected database channel.</param>
;;; <param name="a_commit_mode">What commit mode are we using?</param>
;;; <param name="a_errtxt">Returned error text.</param>
;;; <param name="a_logex">Log exception records?</param>
;;; <param name="a_terminal">Terminal channel to log errors on.</param>
;;; <param name="a_added">Total number of successful inserts.</param>
;;; <param name="a_failed">Total number of failed inserts.</param>
;;; <param name="a_progress">Report progress.</param>
;;; <returns>Returns true on success, otherwise false.</returns>

function <StructureName>Load, ^val

    required in    a_dbchn,         i
    required in    a_commit_mode,   i
    optional out   a_errtxt,        a
    optional in    a_logex,	        i
    optional in    a_terminal,      i
    optional inout a_added,         n
    optional out   a_failed,        n
    optional in    a_progress,      n
    endparams

    .include "CONNECTDIR:ssql.def"
<IF STRUCTURE_ISAM AND STRUCTURE_MAPPED>
    .include "<MAPPED_STRUCTURE>" repository, structure="inpbuf", end
<ELSE STRUCTURE_ISAM AND NOT STRUCTURE_MAPPED>
    .include "<STRUCTURE_NOALIAS>" repository, structure="inpbuf", end
<ELSE STRUCTURE_RELATIVE AND STRUCTURE_MAPPED>
    structure inpbuf
        recnum, d28
        .include "<MAPPED_STRUCTURE>" repository, group="inprec"
<ELSE STRUCTURE_RELATIVE AND NOT STRUCTURE_MAPPED>
    structure inpbuf
        recnum, d28
        .include "<STRUCTURE_NOALIAS>" repository, group="inprec"
    endstructure
    .include "<STRUCTURE_NOALIAS>" repository, structure="<STRUCTURE_NAME>", end
</IF STRUCTURE_ISAM>
<IF STRUCTURE_MAPPED>
    .include "<MAPPED_STRUCTURE>" repository, stack record="tmprec", end
<ELSE>
    .include "<STRUCTURE_NOALIAS>" repository, stack record="tmprec", end
</IF STRUCTURE_MAPPED>

    .define BUFFER_ROWS     1000
    .define EXCEPTION_BUFSZ 100

    stack record local_data
        ok          ,boolean    ;Return status
        firstRecord ,boolean    ;Is this the first record?
        filechn     ,int        ;Data file channel
        mh          ,D_HANDLE   ;Memory handle containing data to insert
        ms          ,int        ;Size of memory buffer in rows
        mc          ,int        ;Memory buffer rows currently used
        ex_mh       ,D_HANDLE   ;Memory buffer for exception records
        ex_mc       ,int        ;Number of records in returned exception array
        ex_ch       ,int        ;Exception log file channel
        attempted   ,int        ;Rows being attempted
        done_records,int        ;Records loaded
        max_records ,int        ;Maximum records to load
        ttl_added   ,int        ;Total rows added
        ttl_failed  ,int        ;Total failed inserts
        errnum      ,int        ;Error number
        errtxt      ,a512       ;Error message text
<IF STRUCTURE_RELATIVE>
        recordNumber,d28
</IF STRUCTURE_RELATIVE>
    endrecord

proc

    init local_data
    ok = true
<IF STRUCTURE_RELATIVE>
    recordNumber = 0
</IF STRUCTURE_RELATIVE>

    ;If we are logging exceptions, delete any existing exceptions file.
    if (^passed(a_logex) && a_logex)
    begin
        xcall delet("REPLICATOR_LOGDIR:<structure_name>_data_exceptions.log")
    end

    ;Open the data file associated with the structure

    if (!(filechn = %<StructureName>OpenInput))
    begin
        ok = false
        errtxt = "Failed to open data file!"
    end

    ;Were we passed a max # records to load

    max_records = (^passed(a_added) && a_added > 0) ? a_added : 0
    done_records = 0

    if (ok)
    begin
        ;Allocate memory buffer for the database rows

        mh = %mem_proc(DM_ALLOC,^size(inpbuf)*(ms=BUFFER_ROWS))

        ;Read records from the input file

        firstRecord = true
        repeat
        begin
            ;Get the next record from the input file
            try
            begin
;//
;// First record processing
;//
                if (firstRecord) then
                begin
<IF STRUCTURE_TAGS>
                    find(filechn,,^FIRST)
                    repeat
                    begin
                        reads(filechn,tmprec)
                        if (<TAG_LOOP><TAGLOOP_CONNECTOR_C>tmprec.<TAGLOOP_FIELD_NAME><TAGLOOP_OPERATOR_C><TAGLOOP_TAG_VALUE></TAG_LOOP>)
                            exitloop
                    end
<ELSE>
                    read(filechn,tmprec,^FIRST)
</IF STRUCTURE_TAGS>
                    firstRecord = false
                end
;//
;// Subsequent record processing
;//
                else
                begin
<IF STRUCTURE_TAGS>
                    repeat
                    begin
                        reads(filechn,tmprec)
                        if (<TAG_LOOP><TAGLOOP_CONNECTOR_C>tmprec.<TAGLOOP_FIELD_NAME><TAGLOOP_OPERATOR_C><TAGLOOP_TAG_VALUE></TAG_LOOP>)
                            exitloop
                    end
<ELSE>
                    reads(filechn,tmprec)
</IF STRUCTURE_TAGS>
                end
            end
            catch (ex, @EndOfFileException)
            begin
                exitloop
            end
            catch (ex, @Exception)
            begin
                ok = false
                errtxt = "Unexpected error while reading data file: " + ex.Message
                exitloop
            end
            endtry

            ;Got one, load it into or buffer
<IF STRUCTURE_ISAM>
            ^m(inpbuf[mc+=1],mh) = tmprec
<ELSE STRUCTURE_RELATIVE>
            ^m(inpbuf[mc+=1].recnum,mh) = recordNumber += 1
            ^m(inpbuf[mc].inprec,mh) = tmprec
</IF STRUCTURE_ISAM>

            incr done_records

            ;If the buffer is full, write it to the database
            if (mc==ms)
            begin
                call insert_data
            end

            if (max_records && (done_records == max_records))
            begin
                exitloop
            end
        end

        if (mc)
        begin
            mh = %mem_proc(DM_RESIZ,^size(inpbuf)*mc,mh)
            call insert_data
        end

        ;Deallocate memory buffer

        mh = %mem_proc(DM_FREE,mh)

    end

    ;Close the file

    if (filechn && %chopen(filechn))
        close filechn

    ;Close the exceptions log file

    if (ex_ch && %chopen(ex_ch))
        close ex_ch

    ;Return the error text

    if (^passed(a_errtxt))
        a_errtxt = errtxt

    ;Return totals

    if (^passed(a_added))
        a_added = ttl_added
    if (^passed(a_failed))
        a_failed = ttl_failed

    freturn ok

insert_data,

    attempted = (%mem_proc(DM_GETSIZE,mh)/^size(inpbuf))

    if (%<StructureName>InsertRows(a_dbchn,a_commit_mode,mh,errtxt,ex_mh,a_terminal))
    begin
        ;Any exceptions?
        if (ex_mh) then
        begin
            ;How many exceptions to log?
            ex_mc = (%mem_proc(DM_GETSIZE,ex_mh)/^size(inpbuf))
            ;Update totals
            ttl_failed+=ex_mc
            ttl_added+=(attempted-ex_mc)
            ;Are we logging exceptions?
            if (^passed(a_logex)&&a_logex) then
            begin
                data cnt, int
                ;Open the log file
                if (!ex_ch)
                    open(ex_ch=0,o:s,"REPLICATOR_LOGDIR:<structure_name>_data_exceptions.log")
                ;Log the exceptions
                for cnt from 1 thru ex_mc
                    writes(ex_ch,^m(inpbuf[cnt],ex_mh))
                if (^passed(a_terminal)&&a_terminal)
                    writes(a_terminal,"Exceptions were logged to REPLICATOR_LOGDIR:<structure_name>_data_exceptions.log")
            end
            else
            begin
                ;No, report and error
                ok = false
            end
            ;Release the exception buffer
            ex_mh=%mem_proc(DM_FREE,ex_mh)
        end
        else
        begin
            ;No exceptions
            ttl_added += attempted
            if ^passed(a_terminal) && a_terminal && ^passed(a_progress) && a_progress
                writes(a_terminal,%string(ttl_added) + " rows inserted")
        end
    end

    clear mc

    return

endfunction

;*****************************************************************************
;;; <summary>
;;; Bulk load data from <IF STRUCTURE_MAPPED><MAPPED_FILE><ELSE><FILE_NAME></IF STRUCTURE_MAPPED> into the <StructureName> table via a CSV file.
;;; </summary>
;;; <param name="a_dbchn">Connected database channel.</param>
;;; <param name="a_commit_mode">What commit mode are we using?</param>
;;; <param name="a_localpath">Path to local export directory</param>
;;; <param name="a_server">Server name or IP</param>
;;; <param name="a_port">Server IP port</param>
;;; <param name="a_temp_table">Use temp table</param>
;;; <param name="a_db_timeout">Database timeout in seconds.</param>
;;; <param name="a_bl_timeout">Bulk load timeout in seconds.</param>
;;; <param name="a_bl_batchsz">Bulk load batch size in rows.</param>
;;; <param name="a_logchannel">Log file channel to log messages on.</param>
;;; <param name="a_records">Total number of records processed</param>
;;; <param name="a_exceptions">Total number of exception records detected</param>
;;; <param name="a_errtxt">Returned error text.</param>
;;; <returns>Returns true on success, otherwise false.</returns>

function <StructureName>BulkLoad, ^val

    required in  a_dbchn,      i
    required in  a_commit_mode,i
    required in  a_localpath,  a
    required in  a_server,     a
    required in  a_port,       i
    required in  a_temp_table, n
    required in  a_db_timeout, n
    required in  a_bl_timeout, n
    required in  a_bl_batchsz, n
    optional in  a_logchannel, n
    optional in  a_ttchannel,  n
    optional out a_records,    n
    optional out a_exceptions, n
    optional out a_errtxt,     a
    endparams

    .include "CONNECTDIR:ssql.def"

     stack record local_data
        ok,                     boolean    ;Return status
        transaction,            boolean
        cursorOpen,             boolean
        remoteBulkLoad,         boolean
        sql,                    string
        localCsvFile,           string
        localExceptionsFile,    string
        localExceptionsLog,     string
        remoteCsvFile,          string
        remoteExceptionsFile,   string
        remoteExceptionsLog,    string
        copyTarget,             string
        fileToLoad,             string
        errorFile,              string
        cursor,                 int
        length,                 int
        dberror,                int
        recordCount,            int	        ;# records to load / loaded
        exceptionCount,         int
        errtxt,                 a512        ;Error message text
        fsc,                    @FileServiceClient
        now,                    a20
    endrecord

proc

    init local_data
    ok = true

    ;If we're doing a remote bulk load, create an instance of the FileService client and verify that we can access the FileService server

    if (remoteBulkLoad = (a_server.nes." "))
    begin
        fsc = new FileServiceClient(a_server,a_port)

        Logger.VerboseLog("Verifying FileService connection")

        if (!fsc.Ping(errtxt))
        begin
            Logger.ErrorLog(errtxt = "No response from FileService, bulk upload cancelled")
            ok = false
        end
    end

    if (ok)
    begin
        ;Determine temporary file names

        .ifdef OS_WINDOWS7
        localCsvFile = a_localpath + "\<StructureName>.csv"
        .endc
        .ifdef OS_UNIX
        localCsvFile = a_localpath + "/<StructureName>.csv"
        .endc
        .ifdef OS_VMS
        localCsvFile = a_localpath + "<StructureName>.csv"
        .endc
        localExceptionsFile  = localCsvFile + "_err"
        localExceptionsLog   = localExceptionsFile + ".Error.Txt"

        if (remoteBulkLoad)
        begin
            remoteCsvFile = "<StructureName>.csv"
            remoteExceptionsFile = remoteCsvFile + "_err"
            remoteExceptionsLog  = remoteExceptionsFile + ".Error.Txt"
        end

        ;Make sure there are no files left over from previous operations

        ;Delete local files

        Logger.VerboseLog("Deleting local files")

        xcall delet(localCsvFile)
        xcall delet(localExceptionsFile)
        xcall delet(localExceptionsLog)

        ;Delete remote files

        if (remoteBulkLoad)
        begin
            Logger.VerboseLog("Deleting remote files")

            fsc.Delete(remoteCsvFile)
            fsc.Delete(remoteExceptionsFile)
            fsc.Delete(remoteExceptionsLog)
        end

        ;Were we asked to load a specific number of records?

        recordCount =  (^passed(a_records) && a_records > 0) ? a_records : 0

        ;And export the data

        Logger.Log("Exporting <StructureName> to delimited file")

        ok = %<StructureName>Csv(localCsvFile,recordCount,errtxt)

    end

    if (ok)
    begin
        ;If necessary, upload the exported file to the database server

        if (remoteBulkLoad) then
        begin
            Logger.VerboseLog("Uploading delimited file to database host")
            ok = fsc.UploadChunked(localCsvFile,remoteCsvFile,320,fileToLoad,errtxt)
        end
        else
        begin
            fileToLoad  = localCsvFile
        end
    end

    if (ok)
    begin
        ;Bulk load the database table

        ;Start a database transaction

        if (a_commit_mode==3)
        begin
            Logger.VerboseLog("Starting transaction")

            if (%ssc_commit(a_dbchn,SSQL_TXON)==SSQL_NORMAL) then
                transaction = true
            else
            begin
                ok = false
                if (%ssc_getemsg(a_dbchn,errtxt,length,,dberror)==SSQL_FAILURE) then
                    errtxt="Failed to start transaction"
                else
                    xcall ThrowOnCommunicationError("<StructureName>BulkLoad",dberror,errtxt)
            end
        end

        ;Open a cursor for the statement

        if (ok)
        begin
            Logger.VerboseLog("Opening cursor")

            errorFile = fileToLoad + "_err"

            sql = "BULK INSERT <StructureName>"

            if (a_temp_table)
                sql = sql + "TEMP"

            sql = sql + " FROM '" + fileToLoad + "' WITH (FIRSTROW=2,FIELDTERMINATOR='|',ROWTERMINATOR='\n',MAXERRORS=100000000,ERRORFILE='" + errorFile + "'"

            if (a_bl_batchsz > 0)
            begin
                sql = sql + ",BATCHSIZE=" + %string(a_bl_batchsz)
            end

           sql = sql + ")"

            if (%ssc_open(a_dbchn,cursor,sql,SSQL_NONSEL,SSQL_STANDARD)==SSQL_NORMAL) then
                cursorOpen = true
            else
            begin
                ok = false
                if (%ssc_getemsg(a_dbchn,errtxt,length,,dberror)==SSQL_FAILURE) then
                    errtxt="Failed to open cursor"
                else
                    xcall ThrowOnCommunicationError("<StructureName>BulkLoad",dberror,errtxt)
            end
        end

        ;Set the SQL statement execution timeout to the bulk load value

        if (ok)
        begin
            Logger.VerboseLog("Setting database timeout to " + %string(a_bl_timeout) + " seconds")

            if (%ssc_cmd(a_dbchn,,SSQL_TIMEOUT,%string(a_bl_timeout))==SSQL_FAILURE)
            begin
                ok = false
                if (%ssc_getemsg(a_dbchn,errtxt,length,,dberror)==SSQL_FAILURE) then
                    errtxt="Failed to set database timeout"
                else
                    xcall ThrowOnCommunicationError("<StructureName>BulkLoad",dberror,errtxt)
            end
        end

        ;Execute the statement

        if (ok)
        begin
            Logger.VerboseLog("Executing BULK INSERT")
            if (%ssc_execute(a_dbchn,cursor,SSQL_STANDARD)==SSQL_FAILURE)
            begin
                if (%ssc_getemsg(a_dbchn,errtxt,length,,dberror)==SSQL_NORMAL) then
                begin
                    xcall ThrowOnCommunicationError("<StructureName>BulkLoad",dberror,errtxt)

                    Logger.ErrorLog("Bulk insert error")

                    using dberror select
                    (-4864),
                    begin
                        ;Bulk load data conversion error
                        Logger.ErrorLog("Data conversion errors were reported")
                        clear dberror, errtxt
                        call GetExceptionDetails
                    end
                    (),
                    begin
                        errtxt = %string(dberror) + " " + errtxt
                        ok = false
                    end
                    endusing
                end
                else
                begin
                    errtxt="Failed to execute SQL statement"
                    ok = false
                end
            end

;            ;Delete temporary files
;
;            ;Delete local files
;
;            Logger.VerboseLog(Deleting local files")
;
;            xcall delet(localCsvFile)
;            xcall delet(localExceptionsFile)
;            xcall delet(localExceptionsLog)
;
;            ;Delete remote files
;
;            if (remoteBulkLoad)
;            begin
;                Logger.VerboseLog("Deleting remote files")
;                fsc.Delete(remoteCsvFile)
;                fsc.Delete(remoteExceptionsFile)
;                fsc.Delete(remoteExceptionsLog)
;            end
        end

        ;Commit or rollback the transaction

        if ((a_commit_mode==3) && transaction)
        begin
            if (ok) then
            begin
                Logger.VerboseLog("Commiting transaction")
                if (%ssc_commit(a_dbchn,SSQL_TXOFF)==SSQL_FAILURE)
                begin
                    ok = false
                    if (%ssc_getemsg(a_dbchn,errtxt,length,,dberror)==SSQL_FAILURE) then
                        errtxt="Failed to commit transaction"
                    else
                        xcall ThrowOnCommunicationError("<StructureName>BulkLoad",dberror,errtxt)
                end
            end
            else
            begin
                ;There was an error, rollback the transaction
                Logger.VerboseLog("Rolling back transaction")
                if (%ssc_rollback(a_dbchn,SSQL_TXOFF) == SSQL_FAILURE)
                begin
                    ok = false
                    if (%ssc_getemsg(a_dbchn,errtxt,length,,dberror)==SSQL_FAILURE) then
                        errtxt="Failed to rollback transaction"
                    else
                        xcall ThrowOnCommunicationError("<StructureName>BulkLoad",dberror,errtxt)
                end
            end
        end

        ;Set the database timeout back to the regular value

        Logger.VerboseLog("Resetting database timeout to " + %string(a_db_timeout) + " seconds")
        if (%ssc_cmd(a_dbchn,,SSQL_TIMEOUT,%string(a_db_timeout))==SSQL_FAILURE)
            nop

        ;Close the cursor

        if (cursorOpen)
        begin
            Logger.VerboseLog("Closing cursor")
            if (%ssc_close(a_dbchn,cursor)==SSQL_FAILURE)
            begin
                if (%ssc_getemsg(a_dbchn,errtxt,length,,dberror)==SSQL_FAILURE) then
                    errtxt="Failed to close cursor"
                else
                    xcall ThrowOnCommunicationError("<StructureName>BulkLoad",dberror,errtxt)
            end
        end
    end

    ;Return the record and cleared field counts

    if (^passed(a_records))
        a_records = recordCount

    if (^passed(a_exceptions))
        a_exceptions = exceptionCount

    ;Return the error text

    if (^passed(a_errtxt))
        a_errtxt = errtxt

    freturn ok

GetExceptionDetails,

    ;If we get here then the bulk load reported one or more "data conversion error" issues
    ;There should be two files on the server

    Logger.ErrorLog("Data conversion errors, processing exceptions")

    if (remoteBulkLoad) then
    begin
        data fileExists, boolean
        data tmpmsg, string

        if (fsc.Exists(remoteExceptionsFile,fileExists,tmpmsg)) then
        begin
            if (fileExists) then
            begin
                ;Download the error file
                data exceptionRecords, [#]string
                data errorMessage, string

                Logger.Log("Downloading remote exceptions data file")

                if (fsc.DownloadText(remoteExceptionsFile,exceptionRecords,errorMessage))
                begin
                    data ex_ch, int
                    data exceptionRecord, string

                    open(ex_ch=0,o:s,localExceptionsFile)

                    foreach exceptionRecord in exceptionRecords
                        writes(ex_ch,exceptionRecord)

                    close ex_ch

                    exceptionCount = exceptionRecords.Length

                    Logger.Log(%string(exceptionCount) + " items saved to " + localExceptionsFile)
                end
            end
            else
            begin
                ;Error file does not exist! In theory this should not happen, because we got here due to "data conversion error" being reported
                Logger.ErrorLog("Remote exceptions data file not found!")
            end
        end
        else
        begin
            ;Failed to determine if file exists
            Logger.ErrorLog("Failed to determine if remote exceptions data file exists. Error was " + tmpmsg)
        end

        ;Now check for and retrieve the associated exceptions log

        if (fsc.Exists(remoteExceptionsLog,fileExists,tmpmsg)) then
        begin
            if (fileExists) then
            begin
                ;Download the error file
                data exceptionRecords, [#]string
                data errorMessage, string

                Logger.VerboseLog("Downloading remote exceptions log file")

                if (fsc.DownloadText(remoteExceptionsLog,exceptionRecords,errorMessage))
                begin
                    data ex_ch, int
                    data exceptionRecord, string

                    open(ex_ch=0,o:s,localExceptionsLog)

                    foreach exceptionRecord in exceptionRecords
                        writes(ex_ch,exceptionRecord)

                    close ex_ch

                    Logger.VerboseLog(%string(exceptionRecords.Length) + " items saved to " + localExceptionsLog)
                end
            end
            else
            begin
                ;Error file does not exist! In theory this should not happen, because we got here due to "data conversion error" being reported
                Logger.ErrorLog("Remote exceptions file not found!")
            end
        end
        else
        begin
            ;Failed to determine if file exists
            Logger.ErrorLog("Failed to determine if remote exceptions log file exists. Error was " + tmpmsg)
        end
    end
    else
    begin
        ;Local bulk load

        if (File.Exists(localExceptionsFile)) then
        begin
            data ex_ch, int
            data tmprec, a65535
            open(ex_ch=0,i:s,localExceptionsFile)
            repeat
            begin
                reads(ex_ch,tmprec,eof)
                exceptionCount += 1
            end
eof,        close ex_ch
            Logger.Log(%string(exceptionCount) + " exception items are in " + localExceptionsFile)
        end
        else
        begin
            ;Error file does not exist! In theory this should not happen, because we got here due to "data conversion error" being reported
            Logger.ErrorLog("Exceptions data file not found!")
        end
    end

    return

endfunction

;*****************************************************************************
;;; <summary>
;;; Close cursors associated with the <StructureName> table.
;;; </summary>
;;; <param name="a_dbchn">Connected database channel</param>
;;; <param name="a_commit_mode">What commit mode are we using?</param>

subroutine <StructureName>Close
    required in  a_dbchn, i
    endparams

    .include "CONNECTDIR:ssql.def"

    external common
<IF STRUCTURE_ISAM>
        c1<StructureName>, i4
        c2<StructureName>, i4
</IF STRUCTURE_ISAM>
        c3<StructureName>,  i4
    endcommon

proc

<IF STRUCTURE_ISAM>
    if (c1<StructureName>)
    begin
        try
        begin
            if (%ssc_close(a_dbchn,c1<StructureName>))
                nop
        end
        catch (ex, @Exception)
        begin
            nop
        end
        finally
        begin
            clear c1<StructureName>
        end
        endtry
    end

    if (c2<StructureName>)
    begin
        try
        begin
            if (%ssc_close(a_dbchn,c2<StructureName>))
                nop
        end
        catch (ex, @Exception)
        begin
            nop
        end
        finally
        begin
            clear c2<StructureName>
        end
        endtry
    end

</IF STRUCTURE_ISAM>
    if (c3<StructureName>)
    begin
        try
        begin
            if (%ssc_close(a_dbchn,c3<StructureName>))
                nop
        end
        catch (ex, @Exception)
        begin
            nop
        end
        finally
        begin
            clear c3<StructureName>
        end
        endtry
    end

    xreturn

endsubroutine

;*****************************************************************************
;;; <summary>
;;; Exports <IF STRUCTURE_MAPPED><MAPPED_FILE><ELSE><FILE_NAME></IF STRUCTURE_MAPPED> to a CSV file.
;;; </summary>
;;; <param name="fileSpec">File to create</param>
;;; <param name="recordCount">Passed number of records to export, returned number of records exported.</param>
;;; <param name="errorMessage">Returned error text.</param>
;;; <returns>Returns true on success, otherwise false.</returns>

function <StructureName>Csv, boolean
    required in    fileSpec, a
    optional inout recordCount, n
    optional out   errorMessage, a

    .include "<STRUCTURE_NOALIAS>" repository, record="<structure_name>", end

    .define EXCEPTION_BUFSZ 100

    external function
        IsDecimalNo,                    boolean
        MakeDateForCsv,                 a
        MakeDecimalForCsvNegatives,     a
        MakeDecimalForCsvNoNegatives,   a
        MakeTimeForCsv,                 a
<IF DEFINED_ASA_TIREMAX>
        TmJulianToYYYYMMDD,             a
        TmJulianToCsvDate,              a
</IF DEFINED_ASA_TIREMAX>
    endexternal

.align
    stack record local_data
        ok,                             boolean     ;Return status
        filechn,                        int         ;Data file channel
        outchn,                         int         ;CSV file channel
        outrec,                         string      ;A CSV file record
        records,                        int         ;Number of records exported
        pos,                            int         ;Position in a string
        recordsMax,                     int         ;Max # or records to export
        errtxt,                         a512        ;Error message text
    endrecord

;//If any fields have a custom data type, declare the functions that convert the value to a string
;//<COUNTER_1_RESET><FIELD_LOOP><IF CUSTOM_STRING_FUNCTION><COUNTER_1_INCREMENT></IF></FIELD_LOOP><IF COUNTER_1>
;//    external function
;//  <FIELD_LOOP>
;//    <IF CUSTOM_STRING_FUNCTION>
;//        <FIELD_CUSTOM_STRING_FUNCTION>, string
;//    </IF>
;//  </FIELD_LOOP>
;//    endexternal
;//</IF>
proc

    ok = true
    clear records, errtxt

    ;Were we given a max # or records to export?

    recordsMax = (^passed(recordCount) && recordCount > 0) ? recordCount : 0

    ;Open the data file associated with the structure

    if (!(filechn=%<StructureName>OpenInput))
    begin
        ok = false
        errtxt = "Failed to open data file!"
    end

    ;Create the local CSV file

    if (ok)
    begin
        .ifdef OS_WINDOWS7
        open(outchn=0,o:s,fileSpec)
        .endc
        .ifdef OS_UNIX
        open(outchn=0,o,fileSpec)
        .endc
        .ifdef OS_VMS
        open(outchn=0,o,fileSpec,OPTIONS:"/stream")
        .endc

        ;Add a row of column headers
        .ifdef OS_WINDOWS7
        writes(outchn,"<IF STRUCTURE_RELATIVE>RecordNumber|</IF STRUCTURE_RELATIVE><FIELD_LOOP><IF CUSTOM_NOT_REPLICATOR_EXCLUDE><FieldSqlName><IF MORE>|</IF MORE></IF CUSTOM_NOT_REPLICATOR_EXCLUDE></FIELD_LOOP>")
        .else
        puts(outchn,"<IF STRUCTURE_RELATIVE>RecordNumber|</IF STRUCTURE_RELATIVE><FIELD_LOOP><IF CUSTOM_NOT_REPLICATOR_EXCLUDE><FieldSqlName><IF MORE>|</IF MORE></IF CUSTOM_NOT_REPLICATOR_EXCLUDE></FIELD_LOOP>" + %char(13) + %char(10))
        .endc

        ;Read and add data file records
        foreach <structure_name> in new Select(new From(filechn,Q_NO_GRFA,0,<structure_name>)<IF STRUCTURE_TAGS>,(Where)(<TAG_LOOP><TAGLOOP_CONNECTOR_C>(<structure_name>.<tagloop_field_name><TAGLOOP_OPERATOR_DBL><TAGLOOP_TAG_VALUE>)</TAG_LOOP>)</IF STRUCTURE_TAGS>)
        begin
            ;Make sure there are no | characters in the data
            while (pos = %instr(1,<structure_name>,"|"))
            begin
                clear <structure_name>(pos:1)
            end

            incr records

            if (recordsmax && (records > recordsMax))
            begin
                decr records
                exitloop
            end

            outrec = ""
  <FIELD_LOOP>
    <IF CUSTOM_NOT_REPLICATOR_EXCLUDE>
      <IF STRUCTURE_RELATIVE>
            &   + %string(records) + "|"
      </IF STRUCTURE_RELATIVE>
      <IF CUSTOM_DBL_TYPE>
;//
;// CUSTOM FIELDS
;//
            &    + %<FIELD_CUSTOM_STRING_FUNCTION>(<structure_name>.<field_original_name_modified>,<structure_name>) + "<IF MORE>|</IF MORE>"
;//
;// ALPHA
;//
      <ELSE ALPHA>
        <IF DEFINED_DBLV11>
            &    + (<structure_name>.<field_original_name_modified> ? %atrim(<structure_name>.<field_original_name_modified>)<IF MORE> + "|"</IF MORE> : "<IF MORE>|</IF MORE>")
        <ELSE>
            &    + %atrim(<structure_name>.<field_original_name_modified>) + "<IF MORE>|</IF MORE>"
        </IF DEFINED_DBLV11>
;//
;// DECIMAL
;//
      <ELSE DECIMAL>
        <IF DEFINED_DBLV11>
            &    + (<structure_name>.<field_original_name_modified> ? <IF NEGATIVE_ALLOWED>%MakeDecimalForCsvNegatives<ELSE>%MakeDecimalForCsvNoNegatives</IF NEGATIVE_ALLOWED>(<structure_name>.<field_original_name_modified>)<IF MORE> + "|"</IF MORE> : "<IF MORE>0|</IF MORE>")
        <ELSE>
            &    + <IF NEGATIVE_ALLOWED>%MakeDecimalForCsvNegatives<ELSE>%MakeDecimalForCsvNoNegatives</IF NEGATIVE_ALLOWED>(<structure_name>.<field_original_name_modified>) + "<IF MORE>|</IF MORE>"
        </IF DEFINED_DBLV11>
;//
;// DATE
;//
      <ELSE DATE>
        <IF DEFINED_DBLV11>
            &    + (<structure_name>.<field_original_name_modified> ? %string(<structure_name>.<field_original_name_modified>,"XXXX-XX-XX")<IF MORE> + "|"</IF MORE> : "<IF MORE>|</IF MORE>")
        <ELSE>
            &    + %MakeDateForCsv(<structure_name>.<field_original_name_modified>) + "<IF MORE>|</IF MORE>"
        </IF DEFINED_DBLV11>
;//
;// DATE_YYMMDD
;//
      <ELSE DATE_YYMMDD>
            &    + %atrim(^a(<structure_name>.<field_original_name_modified>)) + "<IF MORE>|</IF MORE>"
;//
;// TIME_HHMM
;//
      <ELSE TIME_HHMM>
        <IF DEFINED_DBLV11>
            &    + (<structure_name>.<field_original_name_modified> ? %MakeTimeForCsv(<structure_name>.<field_original_name_modified>)<IF MORE> + "|"</IF MORE> : "<IF MORE>|</IF MORE>")
        <ELSE>
            &    + %MakeTimeForCsv(<structure_name>.<field_original_name_modified>) + "<IF MORE>|</IF MORE>"
        </IF DEFINED_DBLV11>
;//
;// TIME_HHMMSS
;//
      <ELSE TIME_HHMMSS>
        <IF DEFINED_DBLV11>
            &    + (<structure_name>.<field_original_name_modified> ? %MakeTimeForCsv(<structure_name>.<field_original_name_modified>)<IF MORE> + "|"</IF MORE> : "<IF MORE>|</IF MORE>")
        <ELSE>
            &    + %MakeTimeForCsv(<structure_name>.<field_original_name_modified>) + "<IF MORE>|</IF MORE>"
        </IF DEFINED_DBLV11>
;//
;// USER-DEFINED
;//
      <ELSE USER>
        <IF USERTIMESTAMP>
            &    + %string(^d(<structure_name>.<field_original_name_modified>),"XXXX-XX-XX XX:XX:XX.XXXXXX") + "<IF MORE>|</IF MORE>"
        <ELSE>
            &    + <IF DEFINED_ASA_TIREMAX>%TmJulianToCsvDate<ELSE>%atrim</IF DEFINED_ASA_TIREMAX>(<structure_name>.<field_original_name_modified>) + "<IF MORE>|</IF MORE>"
        </IF USERTIMESTAMP>
;//
;//
;//
      </IF CUSTOM_DBL_TYPE>
    </IF CUSTOM_NOT_REPLICATOR_EXCLUDE>
  </FIELD_LOOP>

            .ifdef OS_WINDOWS7
            writes(outchn,outrec)
            .else
            puts(outchn,outrec + %char(13) + %char(10))
            .endc
        end
    end

  <IF NOT STRUCTURE_TAGS>
eof,
  </IF STRUCTURE_TAGS>

    ;Close the file
    if (filechn && %chopen(filechn))
    begin
        close filechn
    end

    ;Close the CSV file
    if (outchn && %chopen(outchn))
    begin
        close outchn
    end

    ;Return the record count
    if (^passed(recordCount))
        recordCount = records

    ;Return the error text
    if (^passed(errorMessage))
        errorMessage = errtxt

    freturn ok

endfunction

;*****************************************************************************
;;; <summary>
;;; Opens the <FILE_NAME> for input.
;;; </summary>
;;; <param name="errorMessage">Returned error message.</param>
;;; <returns>Returns the channel number, or 0 if an error occured.</returns>

function <StructureName>OpenInput, ^val
    optional out errorMessage, a  ;Returned error text
    endparams
    stack record
        ch, int
        errmsg, a128
    endrecord
proc

    try
    begin
        open(ch=0,<IF STRUCTURE_ISAM>i:i<ELSE STRUCTURE_RELATIVE>i:r</IF>,"<FILE_NAME>")
        clear errmsg
    end
    catch (ex, @Exception)
    begin
        errmsg = ex.Message
        clear ch
    end
    endtry

    if (^passed(errorMessage))
        errorMessage = errmsg

    freturn ch

endfunction

<IF STRUCTURE_ISAM>
;*****************************************************************************
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
      <ELSE DECIMAL>
    <structureName>.<segment_name> = ^d(aKeyValue(segPos:<SEGMENT_LENGTH>))
      <ELSE DATE>
    if ((!^d(aKeyValue(segPos:<SEGMENT_LENGTH>)))||(!%IsDate(^a(^d(aKeyValue(segPos:<SEGMENT_LENGTH>)))))) then
        ^a(<structureName>.<segment_name>) = "17530101"
    else
        <structureName>.<segment_name> = ^d(aKeyValue(segPos:<SEGMENT_LENGTH>))
      <ELSE TIME>
    <structureName>.<segment_name> = ^d(aKeyValue(segPos:<SEGMENT_LENGTH>))
      <ELSE USER>
    <structureName>.<segment_name> = aKeyValue(segPos:<SEGMENT_LENGTH>)
      </IF ALPHA>
    segPos += <SEGMENT_LENGTH>
    </SEGMENT_LOOP>
  </UNIQUE_KEY>

    freturn <structureName>

endfunction

;*****************************************************************************
;;; <summary>
;;; Extract a key value from the segment fields in a record.
;;; This function behaves like %KEYVAL but without requiring an open channel.
;;; </summary>
;;; <param name="aRecord">Record containing key data</param>
;;; <returns>Returned key value.</returns>

function <StructureName>KeyVal, ^val
    required in  aRecord, str<StructureName>
    required out aKeyVal, a
    required out aKeyLen, n
    endparams
    .align
    stack record
        pos,    int
        len,    int
        keyval, a255
  <UNIQUE_KEY>
    <IF LITERAL_SEGMENTS>
        tmpval, string
    </IF LITERAL_SEGMENTS>
  </UNIQUE_KEY>
    endrecord
proc
    clear keyval
    pos = 1
    len = 0

  <UNIQUE_KEY>
    <SEGMENT_LOOP>
      <IF SEG_TYPE_FIELD>
    ; Key segment <SEGMENT_NUMBER> (Field)
    keyval(pos:<SEGMENT_LENGTH>) = aRecord(<SEGMENT_POSITION>:<SEGMENT_LENGTH>)
        <IF MORE>
    pos += <SEGMENT_LENGTH>
        </IF MORE>
    len += <SEGMENT_LENGTH>
      <ELSE SEG_TYPE_LITERAL>
    ; Key segment <SEGMENT_NUMBER> (Literal value)
    tmpval = "<SEGMENT_LITVAL>"
    keyval(pos:tmpval.Length) = tmpval
        <IF MORE>
    pos += tmpval.Length
        </IF MORE>
    len += tmpval.Length
      <ELSE SEG_TYPE_RECNUM>
    throw new ApplicationException("Key segments of type RECORD NUMBER are not supported by replication!")
      <ELSE SEG_TYPE_EXTERNAL>
    throw new ApplicationException("Key segments of type EXTERNAL VALUE are not supported by replication!")
      </IF>

    </SEGMENT_LOOP>
  </UNIQUE_KEY>
    aKeyVal = keyval(1,len)
    aKeyLen = len

    freturn true

endfunction

;*****************************************************************************
;;; <summary>
;;; Returns the key number of the first unique key.
;;; </summary>
;;; <returns>Returned key number.</returns>

function <StructureName>KeyNum, ^val
proc
    freturn <UNIQUE_KEY><KEY_NUMBER></UNIQUE_KEY>
endfunction

</IF STRUCTURE_ISAM>
<IF STRUCTURE_MAPPED>
;*****************************************************************************
;;; <summary>
;;; 
;;; </summary>
;;; <param name="<mapped_structure>"></param>
;;; <returns></returns>

function <structure_name>_map, a
    .include "<MAPPED_STRUCTURE>" repository, required in group="<mapped_structure>"
    endparams
    .include "<STRUCTURE_NAME>" repository, stack record="<structure_name>"
proc
    init <structure_name>
    ;Store the record
  <FIELD_LOOP>
    <field_path> = <mapped_path_conv>
  </FIELD_LOOP>
    freturn <structure_name>
endfunction

;*****************************************************************************
;;; <summary>
;;; 
;;; </summary>
;;; <param name="<structure_name>"></param>
;;; <returns></returns>

function <structure_name>_unmap, a
    .include "<STRUCTURE_NAME>" repository, required in group="<structure_name>"
    endparams
    .include "<MAPPED_STRUCTURE>" repository, stack record="<mapped_structure>"
proc
    init <mapped_structure>
    ;Store the record
  <FIELD_LOOP>
    <mapped_path> = <field_path_conv>
  </FIELD_LOOP>
    freturn <mapped_structure>
endfunction

</IF STRUCTURE_MAPPED>
;*****************************************************************************
;;; <summary>
;;; 
;;; </summary>
;;; <returns></returns>

function <StructureName>Length ,^val
proc
    freturn <STRUCTURE_SIZE>
endfunction

;*****************************************************************************
;;; <summary>
;;; 
;;; </summary>
;;; <param name="fileType"></param>
;;; <returns></returns>

function <StructureName>Type, ^val
    required out fileType, a
proc
    fileType = "<FILE_TYPE>"
    freturn true
endfunction

;*****************************************************************************
;;; <summary>
;;; Return the number of columns in the <StructureName> table
;;; </summary>
;;; <returns>Number of columns</returns>

function <StructureName>Cols ,^val
proc
<COUNTER_1_RESET>
<IF STRUCTURE_RELATIVE><COUNTER_1_INCREMENT></IF STRUCTURE_RELATIVE>
<FIELD_LOOP>
  <IF CUSTOM_NOT_REPLICATOR_EXCLUDE>
    <IF DEFINED_ASA_TIREMAX>
      <IF STRUCTURE_ISAM AND USER>
        <COUNTER_1_INCREMENT>
      <ELSE STRUCTURE_ISAM AND NOT USER>
        <COUNTER_1_INCREMENT>
      <ELSE STRUCTURE_RELATIVE AND USER>
        <COUNTER_1_INCREMENT>
      <ELSE STRUCTURE_RELATIVE AND NOT USER>
        <COUNTER_1_INCREMENT>
      </IF STRUCTURE_ISAM>
    <ELSE>
      <IF STRUCTURE_ISAM>
        <COUNTER_1_INCREMENT>
      <ELSE STRUCTURE_RELATIVE>
        <COUNTER_1_INCREMENT>
      </IF STRUCTURE_ISAM>
    </IF DEFINED_ASA_TIREMAX>
  </IF CUSTOM_NOT_REPLICATOR_EXCLUDE>
</FIELD_LOOP>
    freturn <COUNTER_1_VALUE>

endfunction
