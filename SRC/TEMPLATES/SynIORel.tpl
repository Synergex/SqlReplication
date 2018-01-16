<CODEGEN_FILENAME><StructureName>IO.dbl</CODEGEN_FILENAME>
<PROVIDE_FILE>IsDate.dbl</PROVIDE_FILE>
<PROVIDE_FILE>IsNumeric.dbl</PROVIDE_FILE>
<PROVIDE_FILE>IsTime.dbl</PROVIDE_FILE>
<PROVIDE_FILE>sqlgbl.def</PROVIDE_FILE>
<PROVIDE_FILE>structureio.def</PROVIDE_FILE>
;//*****************************************************************************
;//
;// Title:       SynIORel.tpl
;//
;// Description: This template generates a Synergy function which performs
;//              Relative file IO for a specific structure / file defined in repository.
;//
;// Author:      Steve Ives, Synergex Professional Services Group
;//
;// Copyright    ©2018 Synergex International Corporation.  All rights reserved.
;//
;;*****************************************************************************
;;
;; File:        <StructureName>IO.dbl
;;
;; Type:        Function (<structure_name>_io)
;;
;; Description: Performs relative file I/O for the file <FILE_NAME>
;;
;;*****************************************************************************
;;
;; Copyright (c) 2018, Synergex International, Inc.
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
	optional in    a_recnum     ,n  ;;Record number
	optional inout <structure_name>, str<StructureName>
	optional in    a_lock       ,n  ;;If passed and TRUE, lock record
	optional out   a_errtxt     ,a  ;;Returned error text
	endparams

	.INCLUDE "INC:structureio.def"
	.include "INC:sqlgbl.def"

	stack record localData
		lock                    ,int    ;;Lock record?
		pos                     ,int    ;;Position in a string
		errorNumber             ,int
		lineNumber              ,int
		errorMessage            ,a45
		errmsg                  ,a45    ;;Error message
		recNum                  ,d28    ;;Hold original record number
	endrecord

proc

	init localData

	onerror fatalIoError

	if ^passed(a_recnum)
		recNum = a_recnum

	if (!^passed(a_lock)) then
		lock = Q_NO_LOCK
	else
		lock = Q_AUTO_LOCK

	if (^passed(a_errtxt))
		clear a_errtxt

	using a_mode select

	(IO_OPEN_INP),
	begin
		open(a_channel=0,i:r,"<FILE_NAME>") [ERR=openError]
	end

	(IO_OPEN_UPD),
	begin
		open(a_channel=0,u:r,"<FILE_NAME>") [ERR=openError]
		<IF DEFINED_ATTACH_IO_HOOKS>
		xcall ConfigureReplication(a_channel)
		</IF>
	end

	(IO_READ_FIRST),
	begin
		read(a_channel,<structure_name>,^FIRST)    [$ERR_EOF=endOfFile,$ERR_LOCKED=recordLocked,$ERR_KEYNOT=keyNotFound]
	end

	(IO_READ),
	begin
		read(a_channel,<structure_name>,recNum,LOCK:lock) [$ERR_EOF=endOfFile,$ERR_LOCKED=recordLocked,$ERR_KEYNOT=keyNotFound]
	end

	(IO_READ_NEXT),
	begin
		reads(a_channel,<structure_name>,,LOCK:lock) [$ERR_EOF=endOfFile,$ERR_LOCKED=recordLocked,$ERR_KEYNOT=keyNotFound]
	end

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
		write(a_channel,<structure_name>,recNum) [$ERR_NOCURR=noCurrentRecord]
	end

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

