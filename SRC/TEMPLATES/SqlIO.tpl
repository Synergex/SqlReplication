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

function <StructureName>Exists, ^val

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

function <StructureName>Create, ^val

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
        <IF STRUCTURE_RELATIVE>
        & + '"RecordNumber" INT NOT NULL,'
        </IF STRUCTURE_RELATIVE>
        <FIELD_LOOP>
        <IF STRUCTURE_RELATIVE>
        & + '"<FieldSqlName>" <FIELD_SQLTYPE><IF REQUIRED> NOT NULL</IF><,>'
        </IF STRUCTURE_RELATIVE>
        <IF STRUCTURE_ISAM>
        & + '"<FieldSqlName>" <FIELD_SQLTYPE><IF REQUIRED> NOT NULL</IF><IF LAST><IF STRUCTURE_HAS_UNIQUE_PK>,</IF STRUCTURE_HAS_UNIQUE_PK><ELSE>,</IF LAST>'
        </IF STRUCTURE_ISAM>
        </FIELD_LOOP>
        <IF STRUCTURE_ISAM>
        <IF STRUCTURE_HAS_UNIQUE_PK>
        & + 'CONSTRAINT PK_<StructureName> PRIMARY KEY CLUSTERED(<PRIMARY_KEY><SEGMENT_LOOP>"<SegmentName>" <SEGMENT_ORDER><,></SEGMENT_LOOP></PRIMARY_KEY>)'
        </IF STRUCTURE_HAS_UNIQUE_PK>
        </IF STRUCTURE_ISAM>
        <IF STRUCTURE_RELATIVE>
        & + 'CONSTRAINT PK_<StructureName> PRIMARY KEY CLUSTERED("RecordNumber" ASC)'
        </IF STRUCTURE_RELATIVE>
        & + ')'

        call open_cursor

        if (ok)
        begin
            call execute_cursor
            call close_cursor
        end
    end

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

<IF STRUCTURE_ISAM>
;;*****************************************************************************
;;; <summary>
;;; Add alternate key indexes to the <StructureName> table if they do not exist.
;;; </summary>
;;; <param name="a_dbchn">Connected database channel.</param>
;;; <param name="a_errtxt">Returned error text.</param>
;;; <returns>Returns true on success, otherwise false.</returns>

function <StructureName>Index, ^val

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
        keycount    ,int        ;;Total number of keys
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

    <IF STRUCTURE_HAS_UNIQUE_PK>
    <ELSE>
    ;;The structure has no unique primary key, so no primary key constraint was added to the table. Create an index instead.

    if (ok && !IndexExists(a_dbchn,"IX_<StructureName>_<PRIMARY_KEY><KeyName></PRIMARY_KEY>",errtxt))
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

    if (ok && !%IndexExists(a_dbchn,"IX_<StructureName>_<KeyName>",errtxt))
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
;;; Removes alternate key indexes from the <StructureName> table in the database.
;;; </summary>
;;; <param name="a_dbchn">Connected database channel.</param>
;;; <param name="a_errtxt">Returned error text.</param>
;;; <returns>Returns true on success, otherwise false.</returns>

function <StructureName>UnIndex, ^val

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
        keycount    ,int        ;;Total number of keys
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

    <IF STRUCTURE_HAS_UNIQUE_PK>
    <ELSE>
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
    ;;Drop index <KEY_NUMBER> (<KEY_DESCRIPTION>)

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

</IF STRUCTURE_ISAM>
;;*****************************************************************************
;;; <summary>
;;; Insert a row into the <StructureName> table.
;;; </summary>
;;; <param name="a_dbchn">Connected database channel.</param>
<IF STRUCTURE_RELATIVE>
;;; <param name="a_recnum">Relative record number to be inserted.</param>
</IF STRUCTURE_RELATIVE>
;;; <param name="a_data">Record to be inserted.</param>
;;; <param name="a_errtxt">Returned error text.</param>
;;; <returns>Returns 1 if the row was inserted, 2 to indicate the row already exists, or 0 if an error occurred.</returns>

function <StructureName>Insert, ^val

    required in  a_dbchn,  i
    <IF STRUCTURE_RELATIVE>
    required in  a_recnum, n
    </IF STRUCTURE_RELATIVE>
    required in  a_data,   a
    optional out a_errtxt, a
    endparams

    .include "CONNECTDIR:ssql.def"

    .align
    stack record local_data
        ok          ,boolean    ;;OK to continue
        openAndBind ,boolean    ;;Should we open the cursor and bind data this time?
        sts         ,int        ;;Return status
        dberror     ,int        ;;Database error number
        transaction ,int        ;;Transaction in progress
        length      ,int        ;;Length of a string
        errtxt      ,a256       ;;Error message text
        <IF STRUCTURE_RELATIVE>
        recordNumber,d28        ;;Relative record number
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
        & +              '"<FieldSqlName>"<,>'
        </FIELD_LOOP>
        & +              ") VALUES(<IF STRUCTURE_RELATIVE>:1,</IF STRUCTURE_RELATIVE><FIELD_LOOP><COUNTER_1_INCREMENT><IF USERTIMESTAMP>CONVERT(DATETIME2,:<COUNTER_1_VALUE>,21)<,><ELSE>:<COUNTER_1_VALUE><,></IF USERTIMESTAMP></FIELD_LOOP>)"
    endliteral

    static record
        <structure_name>, str<STRUCTURE_NOALIAS>
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
    endrecord

    global common
        csr_<structure_name>_insert1, i4, 0
    endcommon

proc

    init local_data
    ok = true
    sts = 1
    <IF STRUCTURE_RELATIVE>
    recordNumber = a_recnum
    </IF STRUCTURE_RELATIVE>
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

    <IF STRUCTURE_RELATIVE>
    if (ok && openAndBind)
    begin
        if (%ssc_bind(a_dbchn,csr_<structure_name>_insert1,1,recordNumber)==SSQL_FAILURE)
        begin
            ok = false
            sts = 0
            if (%ssc_getemsg(a_dbchn,errtxt,length,,dberror)==SSQL_FAILURE)
                errtxt="Failed to bind variables"
        end
    end

    </IF STRUCTURE_RELATIVE>
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
        <IF STRUCTURE_MAPPED>
        ;;Map the file data into the table data record

        <structure_name> = %<structure_name>_map(a_data)
        <ELSE>
        ;;Load the data into the bound record

        <structure_name> = a_data
        </IF STRUCTURE_MAPPED>

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

function <StructureName>InsertRows, ^val

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
        openAndBind ,boolean    ;;Should we open the cursor and bind data this time?
        dberror     ,int        ;;Database error number
        rows        ,int        ;;Number of rows to insert
        transaction ,int        ;;Transaction in progress
        length      ,int        ;;Length of a string
        ex_ms       ,int        ;;Size of exception array
        ex_mc       ,int        ;;Items in exception array
        continue    ,int        ;;Continue after an error
        errtxt      ,a512       ;;Error message text
        <IF STRUCTURE_RELATIVE>
        recordNumber,d28
        </IF STRUCTURE_RELATIVE>
    endrecord

    <COUNTER_1_RESET>
    literal
        sql         ,a*, "INSERT INTO <StructureName> ("
        <IF STRUCTURE_RELATIVE>
        & +              '"RecordNumber",'
        </IF STRUCTURE_RELATIVE>
        <FIELD_LOOP>
        & +              '"<FieldSqlName>"<,>'
        </FIELD_LOOP>
        & +              ") VALUES(<IF STRUCTURE_RELATIVE>:1,<COUNTER_1_INCREMENT></IF STRUCTURE_RELATIVE><FIELD_LOOP><COUNTER_1_INCREMENT><IF USERTIMESTAMP>CONVERT(DATETIME2,:<COUNTER_1_VALUE>,21)<,><ELSE>:<COUNTER_1_VALUE><,></IF USERTIMESTAMP></FIELD_LOOP>)"
    endliteral

    <IF STRUCTURE_ISAM>
    .include "<STRUCTURE_NOALIAS>" repository, structure="inpbuf", nofields, end
    </IF STRUCTURE_ISAM>
    <IF STRUCTURE_RELATIVE>
    structure inpbuf
        recnum, d28
        .include "<STRUCTURE_NOALIAS>" repository, group="inprec", nofields
    endstructure
    </IF STRUCTURE_RELATIVE>
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

    rows = (%mem_proc(DM_GETSIZE,a_data)/^size(inpbuf))

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

<IF STRUCTURE_RELATIVE>
    if (ok && openAndBind)
    begin
        if (%ssc_bind(a_dbchn,csr_<structure_name>_insert2,1,recordNumber)==SSQL_FAILURE)
        begin
            ok = false
            if (%ssc_getemsg(a_dbchn,errtxt,length,,dberror)==SSQL_FAILURE)
                errtxt="Failed to bind variables"
        end
    end

</IF STRUCTURE_RELATIVE>
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

            <IF STRUCTURE_ISAM>
            <IF STRUCTURE_MAPPED>
            <structure_name> = %<structure_name>_map(^m(inpbuf[cnt],a_data))
            <ELSE>
            <structure_name> = ^m(inpbuf[cnt],a_data)
            </IF STRUCTURE_MAPPED>
            </IF STRUCTURE_ISAM>
            <IF STRUCTURE_RELATIVE>
            recordNumber = ^m(inpbuf[cnt].recnum,a_data)
            <IF STRUCTURE_MAPPED>
            <structure_name> = %<structure_name>_map(^m(inpbuf[cnt].inprec,a_data))
            <ELSE>
            <structure_name> = ^m(inpbuf[cnt].inprec,a_data)
            </IF STRUCTURE_MAPPED>
            </IF STRUCTURE_RELATIVE>

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
<IF STRUCTURE_RELATIVE>
;;; <param name="a_recnum">record number.</param>
</IF STRUCTURE_RELATIVE>
;;; <param name="a_data">Record containing data to update.</param>
;;; <param name="a_rows">Returned number of rows affected.</param>
;;; <param name="a_errtxt">Returned error text.</param>
;;; <returns>Returns true on success, otherwise false.</returns>

function <StructureName>Update, ^val

    required in  a_dbchn,  i
    <IF STRUCTURE_RELATIVE>
    required in  a_recnum, n
    </IF STRUCTURE_RELATIVE>
    required in  a_data,   a
    optional out a_rows,   i
    optional out a_errtxt, a
    endparams

    .include "CONNECTDIR:ssql.def"

    stack record local_data
        ok          ,boolean    ;;OK to continue
        openAndBind ,boolean    ;;Should we open the cursor and bind data this time?
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
        <IF STRUCTURE_ISAM>
        & +              ' WHERE <UNIQUE_KEY><SEGMENT_LOOP><COUNTER_1_INCREMENT>"<SegmentName>"=:<COUNTER_1_VALUE> <AND> </SEGMENT_LOOP></UNIQUE_KEY>'
        </IF STRUCTURE_ISAM>
        <IF STRUCTURE_RELATIVE>
        & +              ' WHERE "RecordNumber"=:<COUNTER_1_INCREMENT><COUNTER_1_VALUE>'
        </IF STRUCTURE_RELATIVE>
    endliteral

    static record
        <structure_name>, str<STRUCTURE_NOALIAS>
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

    <IF STRUCTURE_MAPPED>
    <structure_name> = %<structure_name>_map(a_data)
    <ELSE>
    <structure_name> = a_data
    </IF STRUCTURE_MAPPED>

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
        <IF STRUCTURE_ISAM>
        if (%ssc_bind(a_dbchn,csr_<structure_name>_update,<UNIQUE_KEY><KEY_SEGMENTS>,<SEGMENT_LOOP><IF DATEORTIME>^a(</IF DATEORTIME><structure_name>.<segment_name><IF DATEORTIME>)</IF DATEORTIME><,></SEGMENT_LOOP></UNIQUE_KEY>)==SSQL_FAILURE)
        </IF STRUCTURE_ISAM>
        <IF STRUCTURE_RELATIVE>
        if (%ssc_bind(a_dbchn,csr_<structure_name>_update,1,a_recnum)==SSQL_FAILURE)
        </IF STRUCTURE_RELATIVE>
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

<IF STRUCTURE_ISAM>
;;*****************************************************************************
;;; <summary>
;;; Deletes a row from the <StructureName> table.
;;; </summary>
;;; <param name="a_dbchn">Connected database channel.</param>
;;; <param name="a_key">Unique key of row to be deleted.</param>
;;; <param name="a_errtxt">Returned error text.</param>
;;; <returns>Returns true on success, otherwise false.</returns>

function <StructureName>Delete, ^val

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

;TODO: NEED TO FIGURE OUT HOW TO DEAL WITH this
;      THE PASSED IN KEY VALUE WILL BE A KEY ON THE MAPPED FILE
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

</IF STRUCTURE_ISAM>
;;*****************************************************************************
;;; <summary>
;;; Deletes all rows from the <StructureName> table.
;;; </summary>
;;; <param name="a_dbchn">Connected database channel.</param>
;;; <param name="a_errtxt">Returned error text.</param>
;;; <returns>Returns true on success, otherwise false.</returns>

function <StructureName>Clear, ^val

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

function <StructureName>Drop, ^val

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

    xcall <StructureName>Close(a_dbchn)

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
;;; Load all data from <IF STRUCTURE_MAPPED><MAPPED_FILE><ELSE><FILE_NAME></IF STRUCTURE_MAPPED> into the <StructureName> table.
;;; </summary>
;;; <param name="a_dbchn">Connected database channel.</param>
;;; <param name="a_errtxt">Returned error text.</param>
;;; <param name="a_logex">Log exception records?</param>
;;; <param name="a_terminal">Terminal channel to log errors on.</param>
;;; <param name="a_added">Total number of successful inserts.</param>
;;; <param name="a_failed">Total number of failed inserts.</param>
;;; <param name="a_progress">Report progress.</param>
;;; <returns>Returns true on success, otherwise false.</returns>

function <StructureName>Load, ^val

    required in  a_dbchn,    i
    optional out a_errtxt,   a
    optional in  a_logex,    i
    optional in  a_terminal, i
    optional out a_added,    n
    optional out a_failed,   n
    optional in  a_progress, n
    endparams

    .include "CONNECTDIR:ssql.def"
    <IF STRUCTURE_ISAM>
    <IF STRUCTURE_MAPPED>
    .include "<MAPPED_STRUCTURE>" repository, structure="inpbuf", end
    <ELSE>
    .include "<STRUCTURE_NOALIAS>" repository, structure="inpbuf", end
    </IF STRUCTURE_MAPPED>
    </IF STRUCTURE_ISAM>
    <IF STRUCTURE_RELATIVE>
    structure inpbuf
        recnum, d28
        <IF STRUCTURE_MAPPED>
        .include "<MAPPED_STRUCTURE>" repository, group="inprec"
        <ELSE>
        .include "<STRUCTURE_NOALIAS>" repository, group="inprec"
        </IF STRUCTURE_MAPPED>
    endstructure
    .include "<STRUCTURE_NOALIAS>" repository, structure="<STRUCTURE_NAME>", end
    </IF STRUCTURE_RELATIVE>
    <IF STRUCTURE_MAPPED>
    .include "<MAPPED_STRUCTURE>" repository, stack record="tmprec", end
    <ELSE>
    .include "<STRUCTURE_NOALIAS>" repository, stack record="tmprec", end
    </IF STRUCTURE_MAPPED>
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

    ;;If we are logging exceptions, delete any existing exceptions file.
    if (^passed(a_logex) && a_logex)
    begin
        xcall delet("REPLICATOR_LOGDIR:<structure_name>_data_exceptions.log")
    end

    ;;Open the data file associated with the structure

    if (%<IF STRUCTURE_MAPPED><MappedStructure><ELSE><StructureName></IF STRUCTURE_MAPPED>IO(IO_OPEN_INP,filechn)!=IO_OK)
    begin
        ok = false
        errtxt = "Failed to open file <IF STRUCTURE_MAPPED><MAPPED_FILE><ELSE><FILE_NAME></IF STRUCTURE_MAPPED>"
        clear filechn
    end

    if (ok)
    begin
        ;;Allocate memory buffer for the database rows

        mh = %mem_proc(DM_ALLOC,^size(inpbuf)*(ms=BUFFER_ROWS))

        ;;Read records from the input file

        firstRecord = true
        repeat
        begin
            ;;Get the next record from the input file
            if (firstRecord) then
            begin
                <IF STRUCTURE_ISAM>
                errnum = %<IF STRUCTURE_MAPPED><MappedStructure><ELSE><StructureName></IF STRUCTURE_MAPPED>IO(IO_READ_FIRST,filechn,,,tmprec)
                </IF STRUCTURE_ISAM>
                <IF STRUCTURE_RELATIVE>
                errnum = %<IF STRUCTURE_MAPPED><MappedStructure><ELSE><StructureName></IF STRUCTURE_MAPPED>IO(IO_READ_FIRST,filechn,,tmprec)
                </IF STRUCTURE_RELATIVE>
                firstRecord = false
            end
            else
            begin
                <IF STRUCTURE_ISAM>
                errnum = %<IF STRUCTURE_MAPPED><MappedStructure><ELSE><StructureName></IF STRUCTURE_MAPPED>IO(IO_READ_NEXT,filechn,,,tmprec)
                </IF STRUCTURE_ISAM>
                <IF STRUCTURE_RELATIVE>
                errnum = %<IF STRUCTURE_MAPPED><MappedStructure><ELSE><StructureName></IF STRUCTURE_MAPPED>IO(IO_READ_NEXT,filechn,,tmprec)
                </IF STRUCTURE_RELATIVE>
            end

            using errnum select
            (IO_OK),
            begin
                <IF STRUCTURE_ISAM>
                nop
                </IF STRUCTURE_ISAM>
                <IF STRUCTURE_RELATIVE>
                recordNumber += 1
                if (!tmprec)
                    nextloop
                </IF STRUCTURE_RELATIVE>
            end
            (IO_EOF),
                exitloop
            (),
            begin
                ok = false
                errtxt = "Unexpected response " + %string(errnum) + " from %<IF STRUCTURE_MAPPED><MappedStructure><ELSE><StructureName></IF STRUCTURE_MAPPED>IO"
                exitloop
            end
            endusing

            ;;Got one, load it into or buffer
            <IF STRUCTURE_ISAM>
            ^m(inpbuf[mc+=1],mh) = tmprec
            </IF STRUCTURE_ISAM>
            <IF STRUCTURE_RELATIVE>
            ^m(inpbuf[mc+=1].recnum,mh) = recordNumber
            ^m(inpbuf[mc].inprec,mh) = tmprec
            </IF STRUCTURE_RELATIVE>

            ;;If the buffer is full, write it to the database
            if (mc==ms)
                call insert_data
        end

        if (mc)
        begin
            mh = %mem_proc(DM_RESIZ,^size(inpbuf)*mc,mh)
            call insert_data
        end

        ;;Deallocate memory buffer

        mh = %mem_proc(DM_FREE,mh)

    end

    ;;Close the file

    if (filechn)
        xcall <IF STRUCTURE_MAPPED><MappedStructure><ELSE><StructureName></IF STRUCTURE_MAPPED>IO(IO_CLOSE,filechn)

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

    attempted = (%mem_proc(DM_GETSIZE,mh)/^size(inpbuf))

    if (%<StructureName>InsertRows(a_dbchn,mh,errtxt,ex_mh,a_terminal))
    begin
        ;;Any exceptions?
        if (ex_mh) then
        begin
            ;;How many exceptions to log?
            ex_mc = (%mem_proc(DM_GETSIZE,ex_mh)/^size(inpbuf))
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
                    writes(ex_ch,^m(inpbuf[cnt],ex_mh))
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
;;; Bulk load data from <IF STRUCTURE_MAPPED><MAPPED_FILE><ELSE><FILE_NAME></IF STRUCTURE_MAPPED> into the <StructureName> table via a CSV file.
;;; </summary>
;;; <param name="a_dbchn">Connected database channel.</param>
;;; <param name="a_errtxt">Returned error text.</param>
;;; <param name="a_logex">Log exception records?</param>
;;; <param name="a_terminal">Terminal channel to log errors on.</param>
;;; <param name="a_added">Total number of successful inserts.</param>
;;; <param name="a_failed">Total number of failed inserts.</param>
;;; <param name="a_progress">Report progress.</param>
;;; <returns>Returns true on success, otherwise false.</returns>

function <StructureName>BulkLoad, ^val

    required in    a_dbchn,      i
	required inout a_localpath,  string
	required in    a_remotepath, string
    optional out   a_errtxt,     a
    endparams

    .include "CONNECTDIR:ssql.def"

     stack record local_data
        ok,				boolean    ;;Return status
		transaction,	boolean
		cursorOpen,		boolean
		sql,			string
		copyTarget,		string
		fileToLoad,		string
		cursor,			int
		length,			int
		dberror,		int
        errtxt,			a256       ;;Error message text
    endrecord

proc

    init local_data

	;;Export the data to a delimited text file. The a_localpath parameter is updated with the full path to the local file.

	ok = <StructureName>Csv(a_localpath,errtxt)

	;;If necessary, copy the delimited text file to the server

	if ((a_remotepath==^null) || (a_remotepath.eqs." ")) then
	begin
		;;We're bulk loading a local file
		fileToLoad = a_localpath
	end
	else
	begin
		;;We're bulk loading a remote file

		;;Are we using xfServer or "File Upload Service"?

		if (%instr(1,a_remotepath,"@")) then
		begin
			;;We're using xfServer
			
			;;Always a Windows file spec because the target is the SQL Server!
			fileToLoad = a_remotepath(1:%instr(1,a_remotepath,"@")-1) + "\<StructureName>.csv"

			try
			begin
				data remoteFileSpec, string, fileToLoad + a_remotepath(%instr(1,a_remotepath,"@"),%trim(a_remotepath))

				xcall copy(a_localpath,remoteFileSpec)
			end
			catch (ex, @exception)
			begin
				ok = false
				errtxt = "Failed to copy file to server. Error was " + ex.Message
			end
			endtry
		end
		else if (%instr(1,a_remotepath,"http://"))
		begin
			;;We're using "File Upload Service"
			ok = %UploadToWebService(a_localpath,a_remotepath+"/<StructureName>.csv",fileToLoad,errtxt)
		end
	end

	;;Bulk load the delimited file into the database

	if (ok)
	begin
		;;Start a database transaction
		if (%ssc_commit(a_dbchn,SSQL_TXON)==SSQL_NORMAL) then
			transaction = true
		else
		begin
			ok = false
			if (%ssc_getemsg(a_dbchn,errtxt,length,,dberror)==SSQL_FAILURE)
				errtxt="Failed to start transaction"
		end

		;;Open a cursor for the statement
		if (ok)
		begin
			sql = "BULK INSERT <StructureName> FROM '" + fileToLoad + "' WITH (FIRSTROW=2,FIELDTERMINATOR='|',ROWTERMINATOR='\n')"

			if (%ssc_open(a_dbchn,cursor,sql,SSQL_NONSEL,SSQL_STANDARD)==SSQL_NORMAL) then
				cursorOpen = true
			else
			begin
				ok = false
				if (%ssc_getemsg(a_dbchn,errtxt,length,,dberror)==SSQL_FAILURE)
					errtxt="Failed to open cursor"
			end
		end

		;;Execute the statement
		if (ok)
		begin
			if (%ssc_execute(a_dbchn,cursor,SSQL_STANDARD)==SSQL_FAILURE)
			begin
				if (%ssc_getemsg(a_dbchn,errtxt,length,,dberror)==SSQL_NORMAL) then
					nop
				else
					errtxt="Failed to execute SQL statement"
				ok = false
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
					if (%ssc_getemsg(a_dbchn,errtxt,length,,dberror)==SSQL_FAILURE)
						errtxt="Failed to commit transaction"
					ok = false
				end
			end
			else
			begin
				;;There was an error, rollback the transaction
				xcall ssc_rollback(a_dbchn,SSQL_TXOFF)
			end
		end

		;;Close the cursor
		if (cursorOpen)
		begin
			if (%ssc_close(a_dbchn,cursor)==SSQL_FAILURE)
			begin
				if (%ssc_getemsg(a_dbchn,errtxt,length,,dberror)==SSQL_FAILURE)
					errtxt="Failed to close cursor"
			end		
		end
	end

    ;;Return the error text

    if (^passed(a_errtxt))
        a_errtxt = errtxt

    freturn ok

endfunction

;;*****************************************************************************
;;; <summary>
;;; Close cursors associated with the <StructureName> table.
;;; </summary>
;;; <param name="a_dbchn">Connected database channel</param>

subroutine <StructureName>Close

    required in  a_dbchn, i
    endparams

    .include "CONNECTDIR:ssql.def"

    external common
        <IF STRUCTURE_ISAM>
        csr_<structure_name>_insert1, i4
        csr_<structure_name>_insert2, i4
        </IF STRUCTURE_ISAM>
        csr_<structure_name>_update,  i4
    endcommon

proc

    <IF STRUCTURE_ISAM>
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

    </IF STRUCTURE_ISAM>
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
;;; Exports <IF STRUCTURE_MAPPED><MAPPED_FILE><ELSE><FILE_NAME></IF STRUCTURE_MAPPED> to a CSV file.
;;; </summary>
;;; <param name="a_localpath"></param>
;;; <param name="a_errtxt">Returned error text.</param>
;;; <returns>Returns true on success, otherwise false.</returns>

function <StructureName>Csv, ^val
	required inout a_localpath, string
	optional out   a_errtxt, a
    endparams

    .include "CONNECTDIR:ssql.def"
    .include "<STRUCTURE_NOALIAS>" repository, record="<structure_name>", end
    .include "INC:structureio.def"

    .define EXCEPTION_BUFSZ 100

	stack record local_data
		ok,				boolean    ;;Return status
		filechn,		int        ;;Data file channel
		csvchn,			int        ;;CSV file channel
		errnum,			int        ;;Error number
		attempted,		int        ;;Number of records exported
		errtxt,			a256       ;;Error message text
		csvFile,		string
	endrecord

proc

    init local_data
    ok = true

    ;;Open the data file associated with the structure

    if (%<IF STRUCTURE_MAPPED><MappedStructure><ELSE><StructureName></IF STRUCTURE_MAPPED>IO(IO_OPEN_INP,filechn)!=IO_OK)
    begin
        ok = false
        errtxt = "Failed to open file <IF STRUCTURE_MAPPED><MAPPED_FILE><ELSE><FILE_NAME></IF STRUCTURE_MAPPED>"
        clear filechn
    end

    if (ok)
    begin
		;;Define the CSV file name
		.ifdef OS_WINDOWS7
		csvFile  = a_localpath + "\<StructureName>.csv" 
		.endc
		.ifdef OS_UNIX
		csvFile  = a_localpath + "/<StructureName>.csv" 
		.endc
		.ifdef OS_VMS
		csvFile  = a_localpath + "<StructureName>.csv" 
		.endc

		;;Create the local CSV file
		open(csvchn=0,o:s,csvFile)

		;;Add a row of column headers
        writes(csvchn,"<FIELD_LOOP><FieldSqlName><IF MORE>|</IF MORE></FIELD_LOOP>")

        ;;Read and add data file records
        repeat
        begin
            ;;Get the next record from the input file
            <IF STRUCTURE_ISAM>
            errnum = %<IF STRUCTURE_MAPPED><MappedStructure><ELSE><StructureName></IF STRUCTURE_MAPPED>IO(IO_READ_NEXT,filechn,,,<structure_name>)
            </IF STRUCTURE_ISAM>
            <IF STRUCTURE_RELATIVE>
            errnum = %<IF STRUCTURE_MAPPED><MappedStructure><ELSE><StructureName></IF STRUCTURE_MAPPED>IO(IO_READ_NEXT,filechn,,<structure_name>)
            </IF STRUCTURE_RELATIVE>

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
                &    + %string(<field_path>,"XXXX-XX-XX") + "<IF MORE>|</IF MORE>"
                </IF DATE>
                <IF DATE_YYMMDD>
                &    + %atrim(^a(<field_path>)) + "<IF MORE>|</IF MORE>"
                </IF DATE_YYMMDD>
                <IF TIME_HHMM>
                &    + %string(<field_path>,"XX:XX") + "<IF MORE>|</IF MORE>"
                </IF TIME_HHMM>
                <IF TIME_HHMMSS>
                &    + %string(<field_path>,"XX:XX:XX") + "<IF MORE>|</IF MORE>"
                </IF TIME_HHMMSS>
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
                errtxt = "Unexpected response " + %string(errnum) + " from %<IF STRUCTURE_MAPPED><MappedStructure><ELSE><StructureName></IF STRUCTURE_MAPPED>IO"
                exitloop
            end
            endusing
        end
    end

    ;;Close the CSV file
    if (csvchn)
        close csvchn

    ;;Close the data file
    if (filechn)
        xcall <IF STRUCTURE_MAPPED><MappedStructure><ELSE><StructureName></IF STRUCTURE_MAPPED>IO(IO_CLOSE,filechn)

	;;Return the full path of the local CSV file
	a_localpath = csvFile

    ;;Return the error text
    if (^passed(a_errtxt))
        a_errtxt = errtxt

    freturn ok

endfunction

<IF STRUCTURE_ISAM>
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
</IF STRUCTURE_ISAM>

<IF STRUCTURE_MAPPED>
function <structure_name>_map, a
    .include "<MAPPED_STRUCTURE>" repository, required in group="<mapped_structure>"
    endparams
    .include "<STRUCTURE_NAME>" repository, stack record="<structure_name>"
proc
    init <structure_name>
    ;;Store the record
    <FIELD_LOOP>
    <field_path> = <mapped_path_conv>
    </FIELD_LOOP>
    freturn <structure_name>
endfunction

function <structure_name>_unmap, a
    .include "<STRUCTURE_NAME>" repository, required in group="<structure_name>"
    endparams
    .include "<MAPPED_STRUCTURE>" repository, stack record="<mapped_structure>"
proc
    init <mapped_structure>
    ;;Store the record
    <FIELD_LOOP>
    <mapped_path> = <field_path_conv>
    </FIELD_LOOP>
    freturn <mapped_structure>
endfunction

</IF STRUCTURE_MAPPED>
