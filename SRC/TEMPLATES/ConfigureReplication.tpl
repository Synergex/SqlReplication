<CODEGEN_FILENAME>ConfigureReplication.dbl</CODEGEN_FILENAME>
;;*****************************************************************************
;;
;; File:        ConfigureReplication.dbl
;;
;; Description: Adds replication I/O hooks to channels
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

namespace <NAMESPACE>

    subroutine ConfigureReplication
        required in channel, n
        endparams
        stack record
            openMode, a3
        endrecord

        .define common global common
        .include "INC:sqlgbl.def"
        .undefine common

        external function
            doFile, boolean
        endexternal

    proc

        ;;Default to NOT populating a REPLICATION_KEY field for this channel
        repkey_required[channel] = 0

        xcall getfa(channel,"OMD",openMode)

        if (openMode=="U:I")
        begin
            data fileSpec, a128
            data fileName, a80
            data fileExt,  a20

            xcall filnm(channel,fileSpec)
            xcall parse(fileSpec,,,,,fileName,fileExt)

            fileSpec = %atrim(fileName) + fileExt

            upcase fileSpec

            using fileSpec select

;            ;;A single-record layout file that already had a unique key
;            ("FILE1.ISM"),
;            begin
;                if (%doFile(fileName))
;                    new ReplicationIoHooks(channel,"FILE1")
;            end
;
;            ;;A single-record layout file with REPLICATION_KEY added
;            ("FILE2.ISM"),
;            begin
;                if (%doFile(fileName))
;                    new ReplicationIoHooks(channel,"FILE2")
;                repkey_required[channel] = 1
;            end
;
;
;            ;;A multi-record layout file that already had a unique key
;            ("FILE3.ISM"), ;;Multiple possibilities (FILE3A, FILE3B, FILE3C)
;            begin
;                if (%doFile(fileName))
;                    new ReplicationIoHooks(channel,"MULTI_FILE3")
;            end
;
;            ;;A multi-record layout file with REPLICATION_KEY added
;            ("FILE4.ISM"), ;;Multiple possibilities (FILE4A, FILE4B, FILE4C)
;            begin
;                if (%doFile(fileName))
;                    new ReplicationIoHooks(channel,"MULTI_FILE4")
;                repkey_required[channel] = 1
;            end

            ("EMPLOYEE.ISM"),
            begin
                if (%doFile(fileName))
                    new ReplicationIoHooks(channel,"EMPLOYEE")
            end

            endusing
        end

        xreturn

    endsubroutine

    function doFile, boolean
        required in fileName, a
        endparams
        stack record
            result, boolean
            len, i4
        endrecord
        static record
            files, a65535, "NOT DONE!"
        endrecord
    proc
        if (files=="NOT DONE!")
        begin
            ;;Look for an environment variable REPLICATOR_FILES. If defined it should be in the
            ;;format REPLICAOTR_FILES="|FILE1|FILE2|FILE3|" and names the base file names to be
            ;;INCLUDED in replication. Files not mentioned in the environment variable will NOT
            ;;be replicated, even if replication is otherwise configured.
            xcall getlog("REPLICATOR_FILES",files,len)
            if (!len)
                clear files
        end
        result = (!files || %instr(1,files,"|"+%atrim(fileName)+"|"))
        freturn result
    endfunction

endnamespace
