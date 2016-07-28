<CODEGEN_FILENAME><StructureName>KeyToRecord.dbl</CODEGEN_FILENAME>
;//*****************************************************************************
;//
;// Title:      KeyToRecord.tpl
;//
;// Description:Template to generate a subroutine that accepts a primary key
;//             value and returns an instance of the record containing the data
;//             of the key segments.
;//
;// Author:     Steve Ives, Synergex Professional Services Group
;//
;// Copyright   © 2016 Synergex International Corporation.  All rights reserved.
;//
;;*****************************************************************************
;;
;; File:        <StructureName>KeyToRecord.dbl
;;
;; Type:        Function (<StructureName>KeyToRecord)
;;
;; Description: Accepts a primary key value and returns an instance of the
;;              record containing the data of the key segments.
;;
;; Author:      <AUTHOR>
;;
;;*****************************************************************************
;;
;; Copyright (c) 2016, Synergex International, Inc.
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

namespace <NAMESPACE>

    function <StructureName>KeyToRecord, a
        required in aPrimaryKey, a
        endparams

        .include "<STRUCTURE_NOALIAS>" repository, stack record="<structureName>"

        stack record
            keyPos, i4
        endrecord

    proc

        clear <structureName>
        keyPos = 1

        <PRIMARY_KEY>
        <SEGMENT_LOOP>
        <IF ALPHA>
        <structureName>.<segment_name> = aPrimaryKey(keyPos:<SEGMENT_LENGTH>)
        <ELSE>
        ^a(<structureName>.<segment_name>) = aPrimaryKey(keyPos:<SEGMENT_LENGTH>)
        </IF ALPHA>
        <IF MORE>
        keyPos += <SEGMENT_LENGTH>
        </IF MORE>
        </SEGMENT_LOOP>
        </PRIMARY_KEY>

        freturn <structureName>

    endfunction

endnamespace

