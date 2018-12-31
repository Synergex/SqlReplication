<CODEGEN_FILENAME><StructureName>IsamIO.dbl</CODEGEN_FILENAME>
<REQUIRES_CODEGEN_VERSION>5.3.12</REQUIRES_CODEGEN_VERSION>
;//*****************************************************************************
;//
;// Title:       IsamIO.tpl
;//
;// Description: Template to generate a collection of Synergy functions which
;//              create and interact with a second set of ISAM files.
;//
;// Author:      Steve Ives, Synergex Professional Services Group
;//
;// Copyright    (c) 2018 Synergex International Corporation.
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
;;*****************************************************************************
;;
;; File:        <StructureName>IsamIO.dbl
;;
;; Description: Various functions that performs SQL I/O for <STRUCTURE_NAME>
;;
;;*****************************************************************************
;; WARNING: THIS CODE WAS CODE GENERATED AND WILL BE OVERWRITTEN IF CODE
;;          GENERATION IS RE-EXECUTED FOR THIS PROJECT.
;;*****************************************************************************

import ReplicationLibrary

.ifndef str<StructureName>
.include "<STRUCTURE_NOALIAS>" repository, structure="str<StructureName>", end
.endc

;;*****************************************************************************
;;; <summary>
;;; Determines if the <StructureName> file exists.
;;; </summary>
;;; <param name="a_errtxt">Returned error text.</param>
;;; <returns>Returns 1 if the file exists and can be opened, otherwise a number indicating the type of error.</returns>

function <StructureName>ExistsF, ^val

    optional out a_errtxt, a
    endparams

    stack record local_data
        error       ,int    ;;Returned error number
        errtxt      ,a512   ;;Error message text
    endrecord

proc

    init local_data








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
;;; Creates the <StructureName> file.
;;; </summary>
;;; <param name="a_errtxt">Returned error text.</param>
;;; <returns>Returns true on success, otherwise false.</returns>

function <StructureName>CreateF, ^val

    optional out a_errtxt, a
    endparams

    stack record local_data
        ok,     boolean
        errtxt, string
    endrecord

    literal
        fileSpec, a*, "MIRROR_<FILE_ISAMC_SPEC>"
        <COUNTER_1_RESET>
        <KEY_LOOP>
        <COUNTER_1_INCREMENT>
        keySpec<COUNTER_1_VALUE>, a*, "<KEY_ISAMC_SPEC>"
        </KEY_LOOP>
    endliteral

proc

    init local_data
    ok = true

    try
    begin
        xcall isamc(fileSpec,<STRUCTURE_SIZE>,<STRUCTURE_KEYS>,<COUNTER_1_RESET><KEY_LOOP><COUNTER_1_INCREMENT>keySpec<COUNTER_1_VALUE><,></KEY_LOOP>)
    end
    catch (ex, @exception)
    begin
        errtxt = ex.Message
        ok = false
    end
    endtry

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
;;; Insert a record into the <StructureName> file.
;;; </summary>
;;; <param name="a_chn">Open channel.</param>
<IF STRUCTURE_RELATIVE>
;;; <param name="a_recnum">Relative record number to be inserted.</param>
</IF STRUCTURE_RELATIVE>
;;; <param name="a_data">Record to be inserted.</param>
;;; <param name="a_errtxt">Returned error text.</param>
;;; <returns>Returns 1 if the row was inserted, 2 to indicate the row already exists, or 0 if an error occurred.</returns>

function <StructureName>InsertF, ^val

    required in  a_chn,  i
    <IF STRUCTURE_RELATIVE>
    required in  a_recnum, n
    </IF STRUCTURE_RELATIVE>
    required in  a_data,   a
    optional out a_errtxt, a
    endparams

    stack record local_data
        ok,         boolean     ;;OK to continue
        sts,        int         ;;Return status
        errtxt,     a512        ;;Error message text
        <IF STRUCTURE_RELATIVE>
        recordNumber,d28        ;;Relative record number
        </IF STRUCTURE_RELATIVE>
    endrecord

proc

    init local_data
    ok = true
    sts = 1
    <IF STRUCTURE_RELATIVE>
    recordNumber = a_recnum
    </IF STRUCTURE_RELATIVE>
















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
;;; Inserts multiple records into the <StructureName> file.
;;; </summary>
;;; <param name="a_chn">Open channel</param>
;;; <param name="a_data">Memory handle containing one or more records to insert.</param>
;;; <param name="a_errtxt">Returned error text.</param>
;;; <param name="a_exception">Memory handle to load exception data records into.</param>
;;; <param name="a_terminal">Terminal number channel to log errors on.</param>
;;; <returns>Returns true on success, otherwise false.</returns>

function <StructureName>InsertRowsF, ^val

    required in  a_chn,     i
    required in  a_data,      i
    optional out a_errtxt,    a
    optional out a_exception, i
    optional in  a_terminal,  i
    endparams

    .define EXCEPTION_BUFSZ 100

    stack record local_data
        ok          ,boolean    ;;Return status
        errtxt      ,a512       ;;Error message text
        <IF STRUCTURE_RELATIVE>
        recordNumber,d28
        </IF STRUCTURE_RELATIVE>
    endrecord

proc

    init local_data
    ok = true








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
;;; Updates a record in the <StructureName> file.
;;; </summary>
;;; <param name="a_chn">Open channel.</param>
<IF STRUCTURE_RELATIVE>
;;; <param name="a_recnum">record number.</param>
</IF STRUCTURE_RELATIVE>
;;; <param name="a_data">Record containing data to update.</param>
;;; <param name="a_errtxt">Returned error text.</param>
;;; <returns>Returns true on success, otherwise false.</returns>

function <StructureName>UpdateF, ^val

    required in  a_chn,  i
    <IF STRUCTURE_RELATIVE>
    required in  a_recnum, n
    </IF STRUCTURE_RELATIVE>
    required in  a_data,   a
    optional out a_errtxt, a
    endparams

    stack record local_data
        ok          ,boolean    ;;OK to continue
        errtxt      ,a512       ;;Error message text
    endrecord

proc

    init local_data
    ok = true










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
;;; Deletes a record from the <StructureName> file.
;;; </summary>
;;; <param name="a_chn">Open channel.</param>
;;; <param name="a_key">Unique key of row to be deleted.</param>
;;; <param name="a_errtxt">Returned error text.</param>
;;; <returns>Returns true on success, otherwise false.</returns>

function <StructureName>DeleteF, ^val

    required in  a_chn,  i
    required in  a_key,    a
    optional out a_errtxt, a
    endparams

    stack record local_data
        ok, boolean
        <structureName>, str<StructureName>
        errtxt, a512
    endrecord

proc

    init local_data
    ok = true

    ;;Put the unique key value into the record
    <structureName> = %<StructureName>KeyToRecordF(a_key)







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
;;; Deletes all records from the <StructureName> file.
;;; </summary>
;;; <param name="a_chn">Connected channel.</param>
;;; <param name="a_errtxt">Returned error text.</param>
;;; <returns>Returns true on success, otherwise false.</returns>

function <StructureName>ClearF, ^val

    required in  a_chn,  i
    optional out a_errtxt, a
    endparams

    stack record local_data
        ok          ,boolean    ;;Return status
        errtxt      ,a512       ;;Returned error message text
    endrecord

proc

    init local_data
    ok = true








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
;;; Deletes the <StructureName> file.
;;; </summary>
;;; <param name="a_chn">Open channel.</param>
;;; <param name="a_errtxt">Returned error text.</param>
;;; <returns>Returns true on success, otherwise false.</returns>

function <StructureName>DropF, ^val

    required in  a_chn,  i
    optional out a_errtxt, a
    endparams

    stack record local_data
        ok          ,boolean    ;;Return status
        errtxt      ,a512       ;;Returned error message text
    endrecord

proc

    init local_data
    ok = true









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
;;; Load all data from into the <StructureName> file.
;;; </summary>
;;; <param name="a_chn">Open channel.</param>
;;; <param name="a_errtxt">Returned error text.</param>
;;; <param name="a_logex">Log exception records?</param>
;;; <param name="a_terminal">Terminal channel to log errors on.</param>
;;; <param name="a_added">Total number of successful inserts.</param>
;;; <param name="a_failed">Total number of failed inserts.</param>
;;; <param name="a_progress">Report progress.</param>
;;; <returns>Returns true on success, otherwise false.</returns>

function <StructureName>LoadF, ^val

    required in  a_chn,    i
    optional out a_errtxt,   a
    optional in  a_logex,    i
    optional in  a_terminal, i
    optional out a_added,    n
    optional out a_failed,   n
    optional in  a_progress, n
    endparams

    stack record local_data
        ok          ,boolean    ;;Return status
        firstRecord ,boolean    ;;Is this the first record?
        errtxt      ,a512       ;;Error message text
        <IF STRUCTURE_RELATIVE>
        recordNumber,d28
        </IF STRUCTURE_RELATIVE>
        ttl_added   ,int
        ttl_failed  ,int
    endrecord

proc

    init local_data
    ok = true

















    ;;Return the error text

    if (^passed(a_errtxt))
        a_errtxt = errtxt

    ;;Return totals

    if (^passed(a_added))
        a_added = ttl_added
    if (^passed(a_failed))
        a_failed = ttl_failed

    freturn ok

endfunction

;;*****************************************************************************
;;; <summary>
;;; Bulk load data from <IF STRUCTURE_MAPPED><MAPPED_FILE><ELSE><FILE_NAME></IF STRUCTURE_MAPPED> into the <StructureName> table via a CSV file.
;;; </summary>
;;; <param name="a_dbchn">Connected database channel.</param>
;;; <param name="a_commit_mode">What commit mode are we using?</param>
;;; <param name="a_localpath">Path to local export directory</param>
;;; <param name="a_remotepath">Remote export directory or URL</param>
;;; <param name="a_db_timeout">Database timeout in seconds.</param>
;;; <param name="a_bl_timeout">Bulk load timeout in seconds.</param>
;;; <param name="a_logchannel">Log file channel to log messages on.</param>
;;; <param name="a_records">Total number of records processed</param>
;;; <param name="a_exceptions">Total number of exception records detected</param>
;;; <param name="a_errtxt">Returned error text.</param>
;;; <returns>Returns true on success, otherwise false.</returns>

function <StructureName>BulkLoadF, ^val

    required in  a_dbchn,      i
    required in  a_commit_mode, i
    required in  a_localpath,  string
    required in  a_server,     string
    required in  a_port,       string
    required in  a_db_timeout, n
    required in  a_bl_timeout, n
    optional in  a_logchannel, n
    optional out a_records,    n
    optional out a_exceptions, n
    optional out a_errtxt,     a
    endparams

    .include "CONNECTDIR:ssql.def"

     stack record local_data
        ok,                     boolean    ;;Return status
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
        recordCount,            int
        exceptionCount,         int
        errtxt,                 a512       ;;Error message text
        fsc,                    @FileServiceClient
        now,                    a20
    endrecord

    .define writelog(x) writes(a_logchannel,"   - " + %string(^d(now(9:8)),"XX:XX:XX.XX ") + x)

proc

    init local_data
    ok = true

    ;;If we're doing a remote bulk load, create an instance of the FileService client and verify that we can access the FileService server

    if (remoteBulkLoad = ((a_server!=^null) && (a_server.nes." ")))
    begin
        fsc = new FileServiceClient(a_server,a_port)

        now = %datetime
        writelog("Verifying FileService connection")

        if (!fsc.Ping(errtxt))
        begin
            now = %datetime
            writelog(errtxt = "No response from FileService, bulk upload cancelled")
            ok = false
        end
    end

    if (ok)
    begin
        ;;Determine temporary file names

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

        ;;Make sure there are no files left over from previous operations

        call DeleteFiles

        ;;And export the data

        now = %datetime
        writelog("Exporting delimited file")

        ok = %<StructureName>Csv(localCsvFile,recordCount,errtxt)
    end

    if (ok)
    begin
        ;;If necessary, upload the exported file to the database server

        if (remoteBulkLoad) then
        begin
            now = %datetime
            writelog("Uploading delimited file to database host")
            ok = fsc.UploadChunked(localCsvFile,remoteCsvFile,320,fileToLoad,errtxt)
        end
        else
        begin
            fileToLoad  = localCsvFile
        end
    end

    if (ok)
    begin
        ;;Bulk load the database table

        ;;Start a database transaction

        if (a_commit_mode==3)
        begin
            now = %datetime
            writelog("Starting transaction")

            if (%ssc_commit(a_dbchn,SSQL_TXON)==SSQL_NORMAL) then
                transaction = true
            else
            begin
                ok = false
                if (%ssc_getemsg(a_dbchn,errtxt,length,,dberror)==SSQL_FAILURE)
                    errtxt="Failed to start transaction"
            end
        end

        ;;Open a cursor for the statement

        if (ok)
        begin
            now = %datetime
            writelog("Opening cursor")

            errorFile = fileToLoad + "_err"

            sql = "BULK INSERT <StructureName> FROM '" + fileToLoad + "' WITH (FIRSTROW=2,FIELDTERMINATOR='|',ROWTERMINATOR='\n', ERRORFILE='" + errorFile + "')"

            if (%ssc_open(a_dbchn,cursor,sql,SSQL_NONSEL,SSQL_STANDARD)==SSQL_NORMAL) then
                cursorOpen = true
            else
            begin
                ok = false
                if (%ssc_getemsg(a_dbchn,errtxt,length,,dberror)==SSQL_FAILURE)
                    errtxt="Failed to open cursor"
            end
        end

        ;;Set the SQL statement execution timeout to the bulk load value

        if (ok)
        begin
            now = %datetime
            writelog("Setting database timeout to " + %string(a_bl_timeout) + " seconds")
            if (%ssc_cmd(a_dbchn,,SSQL_TIMEOUT,%string(a_bl_timeout))==SSQL_FAILURE)
            begin
                ok = false
                if (%ssc_getemsg(a_dbchn,errtxt,length,,dberror)==SSQL_FAILURE)
                    errtxt="Failed to set database timeout"
            end
        end

        ;;Execute the statement

        if (ok)
        begin
            now = %datetime
            writelog("Executing BULK INSERT")
            if (%ssc_execute(a_dbchn,cursor,SSQL_STANDARD)==SSQL_FAILURE)
            begin
                if (%ssc_getemsg(a_dbchn,errtxt,length,,dberror)==SSQL_NORMAL) then
                begin
                    now = %datetime
                    writelog("Bulk insert error")
                    using dberror select
                    (-4864),
                    begin
                        ;Bulk load data conversion error
                        now = %datetime
                        writelog("Data conversion errors were reported")
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

            ;;Delete temporary files
            call DeleteFiles
        end

        ;;Set the database timeout back to the regular value

        now = %datetime
        writelog("Resetting database timeout to " + %string(a_db_timeout) + " seconds")
        if (%ssc_cmd(a_dbchn,,SSQL_TIMEOUT,%string(a_db_timeout))==SSQL_FAILURE)
            nop

        ;;Commit or rollback the transaction

        if ((a_commit_mode==3) && transaction)
        begin
            if (ok) then
            begin
                now = %datetime
                writelog("COMMIT")
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
                now = %datetime
                writelog("ROLLBACK")
                xcall ssc_rollback(a_dbchn,SSQL_TXOFF)
            end
        end

        ;;Close the cursor

        if (cursorOpen)
        begin
            now = %datetime
            writelog("Closing cursor")
            if (%ssc_close(a_dbchn,cursor)==SSQL_FAILURE)
            begin
                if (%ssc_getemsg(a_dbchn,errtxt,length,,dberror)==SSQL_FAILURE)
                    errtxt="Failed to close cursor"
            end
        end
    end

    ;; Return the record count

    if (^passed(a_records))
        a_records = recordCount

    if (^passed(a_exceptions))
        a_exceptions = exceptionCount

    ;;Return the error text

    if (^passed(a_errtxt))
        a_errtxt = errtxt

      now = %datetime
      writelog("BULK ULOAD COMPLETE")

    freturn ok

GetExceptionDetails,

    ;;If we get here then the bulk load reported one or more "data conversion error" issues
    ;;There should be two files on the server

    now = %datetime
    writelog("Data conversion errors, processing exceptions")


    if (remoteBulkLoad) then
    begin
        data fileExists, boolean
        data tmpmsg, string

        if (fsc.Exists(remoteExceptionsFile,fileExists,tmpmsg)) then
        begin
            if (fileExists) then
            begin
                ;;Download the error file
                data exceptionRecords, [#]string

                now = %datetime
                writelog("Downloading remote exceptions data file")

                if (fsc.DownloadText(remoteExceptionsFile,exceptionRecords))
                begin
                    data ex_ch, int
                    data exceptionRecord, string

                    open(ex_ch=0,o:s,localExceptionsFile)

                    foreach exceptionRecord in exceptionRecords
                        writes(ex_ch,exceptionRecord)

                    close ex_ch

                    exceptionCount = exceptionRecords.Length

                    now = %datetime
                    writelog(%string(exceptionCount) + " items saved to " + localExceptionsFile)
                end
            end
            else
            begin
                ;;Error file does not exist! In theory this should not happen, because we got here due to "data conversion error" being reported
                now = %datetime
                writelog("Remote exceptions data file not found!")
            end
        end
        else
        begin
            ;;Failed to determine if file exists
            now = %datetime
            writelog("Failed to determine if remote exceptions data file exists. Error was " + tmpmsg)
        end

        ;;Now check for and retrieve the associated exceptions log

        if (fsc.Exists(remoteExceptionsLog,fileExists,tmpmsg)) then
        begin
            if (fileExists) then
            begin
                ;;Download the error file
                data exceptionRecords, [#]string

                now = %datetime
                writelog("Downloading remote exceptions log file")

                if (fsc.DownloadText(remoteExceptionsLog,exceptionRecords))
                begin
                    data ex_ch, int
                    data exceptionRecord, string

                    open(ex_ch=0,o:s,localExceptionsLog)

                    foreach exceptionRecord in exceptionRecords
                        writes(ex_ch,exceptionRecord)

                    close ex_ch

                    now = %datetime
                    writelog(%string(exceptionRecords.Length) + " items saved to " + localExceptionsLog)
                end
            end
            else
            begin
                ;;Error file does not exist! In theory this should not happen, because we got here due to "data conversion error" being reported
                now = %datetime
                writelog("Remote exceptions file not found!")
            end
        end
        else
        begin
            ;;Failed to determine if file exists
            now = %datetime
            writelog("Failed to determine if remote exceptions log file exists. Error was " + tmpmsg)
        end
    end
    else
    begin
        ;;Local bulk load

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
            now = %datetime
            writelog(%string(exceptionCount) + " exception items found in " + localExceptionsFile)
        end
        else
        begin
            ;;Error file does not exist! In theory this should not happen, because we got here due to "data conversion error" being reported
            now = %datetime
            writelog("Exceptions data file not found!")
        end
    end

    return

DeleteFiles,

    ;;Delete local files

    now = %datetime
    writelog("Deleting local files")

    xcall delet(localCsvFile)
    xcall delet(localExceptionsFile)
    xcall delet(localExceptionsLog)

    ;;Delete remote files

    if (remoteBulkLoad)
    begin
        now = %datetime
        writelog("Deleting remote files")

        fsc.Delete(remoteCsvFile)
        fsc.Delete(remoteExceptionsFile)
        fsc.Delete(remoteExceptionsLog)
    end

    return

endfunction

;;*****************************************************************************
;;; <summary>
;;; Close cursors associated with the <StructureName> table.
;;; </summary>
;;; <param name="a_dbchn">Connected database channel</param>
;;; <param name="a_commit_mode">What commit mode are we using?</param>

subroutine <StructureName>CloseF

    required in  a_dbchn, i
    required in  a_commit_mode, i
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
;;; <param name="fileSpec">File to create</param>
;;; <param name="recordCount">Returned error text.</param>
;;; <param name="errorMessage">Returned error text.</param>
;;; <returns>Returns true on success, otherwise false.</returns>

function <StructureName>CsvF, ^val
    required in  fileSpec, string
    optional out recordCount, n
    optional out errorMessage, a
    endparams

    .include "CONNECTDIR:ssql.def"
    .include "<STRUCTURE_NOALIAS>" repository, record="<structure_name>", end

    .define EXCEPTION_BUFSZ 100

    stack record local_data
        ok,             boolean     ;;Return status
        filechn,        int         ;;Data file channel
        csvchn,         int         ;;CSV file channel
        csvrec,         string      ;;A CSV file record
        errnum,         int         ;;Error number
        records,        int         ;;Number of records exported
        errtxt,         a512        ;;Error message text
    endrecord

proc

    init local_data
    ok = true

    ;;Open the data file associated with the structure

    if (!(filechn=%<StructureName>OpenInput))
    begin
        ok = false
        errtxt = "Failed to open data file!"
    end

    if (ok)
    begin
        ;;Create the local CSV file
        .ifdef OS_WINDOWS7
        open(csvchn=0,o:s,fileSpec)
        .endc
        .ifdef OS_UNIX
        open(csvchn=0,o,fileSpec)
        .endc
        .ifdef OS_VMS
        open(csvchn=0,o,fileSpec,OPTIONS:"/stream")
        .endc

        ;;Add a row of column headers
        .ifdef OS_WINDOWS7
        writes(csvchn,"<FIELD_LOOP><IF STRUCTURE_RELATIVE>RecordNumber|</IF STRUCTURE_RELATIVE><FieldSqlName><IF MORE>|</IF MORE></FIELD_LOOP>")
        .else
        puts(csvchn,"<FIELD_LOOP><IF STRUCTURE_RELATIVE>RecordNumber|</IF STRUCTURE_RELATIVE><FieldSqlName><IF MORE>|</IF MORE></FIELD_LOOP>" + %char(13) + %char(10))
        .endc

        ;;Read and add data file records
        repeat
        begin
            ;;Get the next record from the input file
            try
            begin
                <IF STRUCTURE_TAGS>
                repeat
                begin
                    reads(filechn,<structure_name>)
                    if (<TAG_LOOP><TAGLOOP_CONNECTOR_C><structure_name>.<TAGLOOP_FIELD_NAME><TAGLOOP_OPERATOR_C><TAGLOOP_TAG_VALUE></TAG_LOOP>)
                        exitloop
                end
                <ELSE>
                reads(filechn,<structure_name>)
                </IF STRUCTURE_TAGS>

                ;;Make sure there are no | characters in the data
                if (%instr(1,<structure_name>,"|"))
                begin
                    data tmpData, string, <structure_name>
                    tmpData.Replace("|"," ")
                    <structure_name> = tmpData
                end

                records += 1
                csvrec = ""
                <FIELD_LOOP>
                <IF STRUCTURE_RELATIVE>
                &   + %string(records) + "|"
                </IF STRUCTURE_RELATIVE>
                <IF ALPHA>
                &    + %atrim(<structure_name>.<field_original_name_modified>) + "<IF MORE>|</IF MORE>"
                </IF ALPHA>
                <IF DECIMAL>
                &    + %string(<structure_name>.<field_original_name_modified>) + "<IF MORE>|</IF MORE>"
                </IF DECIMAL>
                <IF DATE>
                &    + %string(<structure_name>.<field_original_name_modified>,"XXXX-XX-XX") + "<IF MORE>|</IF MORE>"
                </IF DATE>
                <IF DATE_YYMMDD>
                &    + %atrim(^a(<structure_name>.<field_original_name_modified>)) + "<IF MORE>|</IF MORE>"
                </IF DATE_YYMMDD>
                <IF TIME_HHMM>
                &    + %string(<structure_name>.<field_original_name_modified>,"XX:XX") + "<IF MORE>|</IF MORE>"
                </IF TIME_HHMM>
                <IF TIME_HHMMSS>
                &    + %string(<structure_name>.<field_original_name_modified>,"XX:XX:XX") + "<IF MORE>|</IF MORE>"
                </IF TIME_HHMMSS>
                <IF USER>
                <IF USERTIMESTAMP>
                &    + %string(^d(<structure_name>.<field_original_name_modified>),"XXXX-XX-XX XX:XX:XX.XXXXXX") + "<IF MORE>|</IF MORE>"
                <ELSE>
                &    + %atrim(<structure_name>.<field_original_name_modified>) + "<IF MORE>|</IF MORE>"
                </IF USERTIMESTAMP>
                </IF USER>
                </FIELD_LOOP>

                .ifdef OS_WINDOWS7
                writes(csvchn,csvrec)
                .else
                puts(csvchn,csvrec + %char(13) + %char(10))
                .endc
            end
            catch (e, @EndOfFileException)
            begin
                exitloop
            end
            catch (e, @Exception)
            begin
                ok = false
                errtxt = "Unexpected error when reading data file: " + e.Message
                exitloop
            end
            endtry
        end
    end

    ;;Close the CSV file
    if (csvchn)
        close csvchn

    ;;Close the data file
    if (filechn && %chopen(filechn))
        close filechn

    ;;Return the record count
    if (^passed(recordCount))
        recordCount = records

    ;;Return the error text
    if (^passed(errorMessage))
        errorMessage = errtxt

    freturn ok

endfunction

;;*****************************************************************************
;;; <summary>
;;; Opens the <FILE_NAME> for input.
;;; </summary>
;;; <param name="errorMessage">Returned error message.</param>
;;; <returns>Returns the channel number, or 0 if an error occured.</returns>

function <StructureName>OpenInputF, ^val
    optional out errorMessage, a  ;;Returned error text
    endparams
    stack record
        ch, int
        errmsg, a128
    endrecord
proc

    try
    begin
        open(ch=0,<IF STRUCTURE_ISAM>i:i</IF STRUCTURE_ISAM><IF STRUCTURE_RELATIVE>i:r</IF STRUCTURE_RELATIVE>,"<FILE_NAME>")
        errmsg = ""
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
;;*****************************************************************************
;;; <summary>
;;; Loads a unique key value into the respective fields in a record.
;;; </summary>
;;; <param name="aKeyValue">Unique key value.</param>
;;; <returns>Returns a record containig only the unique key segment data.</returns>

function <StructureName>KeyToRecordF, a

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
function <structure_name>_mapf, a
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

function <structure_name>_unmapf, a
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

function <StructureName>LengthF ,^val
proc
    freturn <STRUCTURE_SIZE>
endfunction

function <StructureName>TypeF, ^val
    required out fileType, a
proc
    fileType = "<FILE_TYPE>"
    freturn true
endfunction
