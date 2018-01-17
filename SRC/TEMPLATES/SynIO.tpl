<CODEGEN_FILENAME><StructureName>IO.dbl</CODEGEN_FILENAME>
<PROVIDE_FILE>IsDate.dbl</PROVIDE_FILE>
<PROVIDE_FILE>IsNumeric.dbl</PROVIDE_FILE>
<PROVIDE_FILE>IsTime.dbl</PROVIDE_FILE>
<PROVIDE_FILE>sqlgbl.def</PROVIDE_FILE>
<PROVIDE_FILE>structureio.def</PROVIDE_FILE>
;//*****************************************************************************
;//
;// Title:       SynIO.tpl
;//
;// Description: This template generates a Synergy function which performs
;//              file IO for a specific structure / file defined in repository.
;//
;// Author:      Steve Ives, Synergex Professional Services Group
;//
;// Copyright    ©2009 Synergex International Corporation.  All rights reserved.
;//
;;*****************************************************************************
;;
;; File:        <StructureName>IO.dbl
;;
;; Type:        Function (<structure_name>_io)
;;
;; Description: Performs file I/O for the file <FILE_NAME>
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

.include "<STRUCTURE_NOALIAS>" repository, structure="str<StructureName>", end

function <structure_name>_io ,^val

    required in    a_mode       ,n  ;;Access type
    required inout a_channel    ,n  ;;Channel
    <IF STRUCTURE_ISAM>
    optional in    a_key        ,a  ;;Key value
    optional in    a_keynum     ,n  ;;Key number
    </IF STRUCTURE_ISAM>
    <IF STRUCTURE_RELATIVE>
    optional in    a_recnum     ,n  ;;Record number
    </IF STRUCTURE_RELATIVE>
    optional inout <structure_name>, str<StructureName>
    optional in    a_lock       ,n  ;;If passed and TRUE, lock record
    <IF STRUCTURE_ISAM>
    optional in    a_partial    ,n  ;;Do a partial key lookup
    </IF STRUCTURE_ISAM>
    optional out   a_errtxt     ,a  ;;Returned error text
    endparams

    .INCLUDE "INC:structureio.def"
    .include "INC:sqlgbl.def"

    stack record localData
        <IF STRUCTURE_ISAM>
        keyno                   ,int    ;;Key number
        keylen                  ,int    ;;Key length
        keyValue                ,a255   ;;Hold original key
        </IF STRUCTURE_ISAM>
        <IF STRUCTURE_RELATIVE>
        recordNumber            ,d28    ;;Relative record number
        </IF STRUCTURE_RELATIVE>
        lock                    ,int    ;;Lock record?
        pos                     ,int    ;;Position in a string
        errorNumber             ,int
        lineNumber              ,int
        errorMessage            ,a45
        errmsg                  ,a45    ;;Error message
    endrecord

    <IF STRUCTURE_ISAM>
    <IF STRUCTURE_TAGS>
    .define TAG_MATCH <TAG_LOOP><TAGLOOP_CONNECTOR_C><structure_name>.<TAGLOOP_FIELD_NAME><TAGLOOP_OPERATOR_C><TAGLOOP_TAG_VALUE></TAG_LOOP>

    </IF STRUCTURE_TAGS>
    </IF STRUCTURE_ISAM>
proc

    init localData

    onerror fatalIoError

    <IF STRUCTURE_ISAM>
    if ^passed(a_key)
    begin
        keyValue = a_key
        if (^passed(a_partial)&&a_partial) then
            keylen = %trim(a_key)
        else
            keylen = ^size(a_key)
    end

    if ^passed(a_keynum) then
        keyno=a_keynum
    else
        keyno=0

    if (!^passed(a_key) && ^passed(<structure_name>))
    begin
        keyValue = %keyval(a_channel,<structure_name>,keyno)
        if (^passed(a_partial)&&a_partial) then
            keylen = %trim(%keyval(a_channel,<structure_name>,keyno))
        else
            keylen = ^len(%keyval(a_channel,<structure_name>,keyno))
    end

    </IF STRUCTURE_ISAM>
    <IF STRUCTURE_RELATIVE>
    if ^passed(a_recnum)
        recordNumber = a_recnum
    
    </IF STRUCTURE_RELATIVE>
    if (!^passed(a_lock)) then
        lock = Q_NO_LOCK
    else
        lock = Q_AUTO_LOCK

    if (^passed(a_errtxt))
        clear a_errtxt

    using a_mode select

    (IO_OPEN_INP),
    begin
        open(a_channel=0,<IF STRUCTURE_ISAM>i:i</IF STRUCTURE_ISAM><IF STRUCTURE_RELATIVE>i:r</IF STRUCTURE_RELATIVE>,"<FILE_NAME>") [ERR=openError]
    end

    (IO_OPEN_UPD),
    begin
        open(a_channel=0,<IF STRUCTURE_ISAM>u:i</IF STRUCTURE_ISAM><IF STRUCTURE_RELATIVE>u:r</IF STRUCTURE_RELATIVE>,"<FILE_NAME>") [ERR=openError]
        <IF DEFINED_ATTACH_IO_HOOKS>
        xcall ConfigureReplication(a_channel)
        </IF>
    end

    <IF STRUCTURE_ISAM>
    (IO_FIND),
    begin
        find(a_channel,,keyValue(1:keylen),KEYNUM:keyno) [$ERR_EOF=endOfFile,$ERR_LOCKED=recordLocked,$ERR_KEYNOT=keyNotFound]
    end

    </IF STRUCTURE_ISAM>
    <IF STRUCTURE_ISAM>
    (IO_FIND_FIRST),
    begin
        .ifdef TAG_VALUE
        find(a_channel,,TAG_VALUE,KEYNUM:keyno) [$ERR_EOF=endOfFile,$ERR_LOCKED=recordLocked,$ERR_KEYNOT=keyNotFound]
        .else
        find(a_channel,,^FIRST,KEYNUM:keyno)    [$ERR_EOF=endOfFile,$ERR_LOCKED=recordLocked,$ERR_KEYNOT=keyNotFound]
        .endc
    end

    </IF STRUCTURE_ISAM>
    (IO_READ_FIRST),
    begin
        <IF STRUCTURE_ISAM>
        <IF STRUCTURE_TAGS>
        find(a_channel,,^FIRST,KEYNUM:keyno,LOCK:lock) [$ERR_EOF=endOfFile,$ERR_LOCKED=recordLocked,$ERR_KEYNOT=keyNotFound]
        repeat
        begin
            reads(a_channel,<structure_name>,LOCK:lock) [$ERR_EOF=endOfFile,$ERR_LOCKED=recordLocked,$ERR_KEYNOT=keyNotFound]
            if (TAG_MATCH) then
                exitloop
            else
                unlock a_channel
        end
        <ELSE>
        read(a_channel,<structure_name>,^FIRST,KEYNUM:keyno)    [$ERR_EOF=endOfFile,$ERR_LOCKED=recordLocked,$ERR_KEYNOT=keyNotFound]
        </IF STRUCTURE_TAGS>
        </IF STRUCTURE_ISAM>
        <IF STRUCTURE_RELATIVE>
        read(a_channel,<structure_name>,^FIRST)    [$ERR_EOF=endOfFile,$ERR_LOCKED=recordLocked,$ERR_KEYNOT=keyNotFound]
        </IF STRUCTURE_RELATIVE>
    end

    (IO_READ),
    begin
        <IF STRUCTURE_ISAM>
        read(a_channel,<structure_name>,keyValue(1:keylen),KEYNUM:keyno,LOCK:lock) [$ERR_EOF=endOfFile,$ERR_LOCKED=recordLocked,$ERR_KEYNOT=keyNotFound]
        </IF STRUCTURE_ISAM>
        <IF STRUCTURE_RELATIVE>
        read(a_channel,<structure_name>,recordNumber,LOCK:lock) [$ERR_EOF=endOfFile,$ERR_LOCKED=recordLocked,$ERR_KEYNOT=keyNotFound]
        </IF STRUCTURE_RELATIVE>
    end

    (IO_READ_NEXT),
    begin
        <IF STRUCTURE_ISAM>
        <IF STRUCTURE_TAGS>
        repeat
        begin
            reads(a_channel,<structure_name>,LOCK:lock) [$ERR_EOF=endOfFile,$ERR_LOCKED=recordLocked,$ERR_KEYNOT=keyNotFound]
            if (TAG_MATCH)
                exitloop
        end
        <ELSE>
        reads(a_channel,<structure_name>,LOCK:lock) [$ERR_EOF=endOfFile,$ERR_LOCKED=recordLocked,$ERR_KEYNOT=keyNotFound]
        </IF STRUCTURE_TAGS>
        </IF STRUCTURE_ISAM>
        <IF STRUCTURE_RELATIVE>
        reads(a_channel,<structure_name>,LOCK:lock) [$ERR_EOF=endOfFile,$ERR_LOCKED=recordLocked,$ERR_KEYNOT=keyNotFound]
        </IF STRUCTURE_RELATIVE>
    end

    <IF STRUCTURE_ISAM>
    (IO_CREATE),
    begin
        <IF DEFINED_CLEAN_DATA>
        <FIELD_LOOP>
        <IF DECIMAL>
        if ((!<field_path>)||(!%IsNumeric(^a(<field_path>))))
            clear <field_path>
        </IF>
        <IF DATE>
        if (!<field_path>||!%IsDate(^a(<field_path>)))
            clear <field_path>
        </IF>
        <IF TIME>
        if (!<field_path>||!%IsTime(^a(<field_path>)))
            clear <field_path>
        </IF>
        </FIELD_LOOP>
        </IF>

        if (repkey_required[a_channel]) then
        begin
            repeat
            begin
                xcall PopulateReplicationKey(a_channel,<structure_name>)
                store(a_channel,<structure_name>) [$ERR_NODUPS=timeStampClash]
                exitloop
timeStampClash,
                sleep 0.01
            end
        end
        else
        begin
            store(a_channel,<structure_name>) [$ERR_NODUPS=duplicateKey]
        end
    end

    </IF STRUCTURE_ISAM>
    (IO_UPDATE),
    begin
        <IF DEFINED_CLEAN_DATA>
        <FIELD_LOOP>
        <IF DECIMAL>
        if ((!<field_path>)||(!%IsNumeric(^a(<field_path>))))
            clear <field_path>
        </IF>
        <IF DATE>
        if (!<field_path>||!%IsDate(^a(<field_path>)))
            clear <field_path>
        </IF>
        <IF TIME>
        if (!<field_path>||!%IsTime(^a(<field_path>)))
            clear <field_path>
        </IF>
        </FIELD_LOOP>
        </IF>
        write(a_channel,<structure_name><IF STRUCTURE_RELATIVE>,recordNumber</IF STRUCTURE_RELATIVE>) [$ERR_NOCURR=noCurrentRecord]
    end

    <IF STRUCTURE_ISAM>
    (IO_DELETE),
    begin
        delete(a_channel) [$ERR_NOCURR=noCurrentRecord]
    end

    </IF STRUCTURE_ISAM>
    (IO_UNLOCK),
    begin
        unlock a_channel
    end

    (IO_CLOSE),
    begin
        if (a_channel)
        begin
            close a_channel
            clear a_channel
        end
    end

    (),
    begin
        if (^passed(a_errtxt))
            a_errtxt = "Invalid file access mode"
        freturn IO_FATAL
    end

    endusing

    offerror

    if (!^passed(a_lock) || (^passed(a_lock) && !a_lock))
        if (a_channel && %chopen(a_channel))
            unlock a_channel

    freturn IO_OK

;;-----------------------------------------------------------------------------

recordLocked,

    ;;Return the locked error code
    if (^passed(a_errtxt))
        a_errtxt = "Record locked"

    freturn IO_LOCKED

;;-----------------------------------------------------------------------------

endOfFile,

    unlock a_channel

    if (^passed(a_errtxt))
        a_errtxt = "Record not found - end of file"

    freturn IO_EOF

;;-----------------------------------------------------------------------------

keyNotFound,

    unlock a_channel

    if (^passed(a_errtxt))
        a_errtxt = "Record not found"

    freturn IO_NOT_FOUND

;;-------------------------------------------------------------------------------

duplicateKey,

    unlock a_channel

    if (^passed(a_errtxt))
        a_errtxt = "Record already exists"

    freturn IO_DUP_KEY

;;-----------------------------------------------------------------------------

noCurrentRecord,

    unlock a_channel

    if (^passed(a_errtxt))
        a_errtxt = "No record was locked"

    freturn IO_NO_CUR_REC

;;-----------------------------------------------------------------------------

fatalIoError,

    if (a_channel && %chopen(a_channel))
        unlock a_channel

    offerror

    if (^passed(a_errtxt))
    begin
        xcall error(errorNumber,lineNumber)
        xcall ertxt(errorNumber,errorMessage)
        xcall s_bld(a_errtxt,,'Error : %d, %a, at line : %d',errorNumber,errorMessage,lineNumber)
    end

    freturn IO_FATAL

;;-----------------------------------------------------------------------------

openError,

    if (^passed(a_errtxt))
        a_errtxt = "Failed to open file"

    freturn IO_FATAL

endfunction

function <structure_name>_length ,^val
    endparams
proc
    freturn <STRUCTURE_SIZE>
endfunction

function <structure_name>_type, ^val
    required out fileType, a
    endparams
proc
    fileType = "<FILE_TYPE>"
    freturn true
endfunction

