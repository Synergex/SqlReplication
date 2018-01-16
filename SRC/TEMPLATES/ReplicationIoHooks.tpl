<CODEGEN_FILENAME>ReplicationIoHooks.dbl</CODEGEN_FILENAME>
;//*****************************************************************************
;//
;// Title:      ReplicationIoHooks.tpl
;//
;// Description:Template to generate an IO Hooks class for use with SQL replication
;//             of ISAM files.
;//
;// Author:     Steve Ives, Synergex Professional Services Group
;//
;// Copyright   © 2015 Synergex International Corporation.  All rights reserved.
;//
;;*****************************************************************************
;;
;; File:        ReplicationIoHooks.dbl
;;
;; Type:        Class (ReplicationIoHooks)
;;
;; Description: An I/O Hooks class that implements SQL data replication for ISAM files
;;
;;*****************************************************************************
;;
;; Copyright (c) 2015, Synergex International, Inc.
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

import Synergex.SynergyDE.IOExtensions
import Synergex.SynergyDE.Select

namespace <NAMESPACE>

    ;;-------------------------------------------------------------------------
    ;;I/O hooks class that implements SQL Replication
    ;;
    public sealed class ReplicationIoHooks extends IOHooks

        private mStructureName, string
        private mActive, boolean, false
        private mMultiTable, boolean
        private mChannel, int, 0
        private mFillTimeStamp, boolean, false
        private mTimeStampPos, int, 0

        ;;---------------------------------------------------------------------
        ;;Constructor

        public method ReplicationIoHooks
            required in aChannel, n
            required in aStructureName, string
            endparams
            parent(aChannel)
            record
                openMode, a3
                thisKey, i4
            endrecord
            record keyinfo
                keypos ,d5
                keylen ,d3
                keydup ,d1
                keyasc ,d1
                keymod ,d1
                keynam ,a15
                key_spos ,8d5
                key_slen ,8d3
            endrecord
            .ifdef D_VMS
            .include "REPLICATION_VMS" repository, structure="strInstruction", end
            .else
            .include "REPLICATION" repository, structure="strInstruction", end
            .endc
        proc
            ;;Make sure the channel is to an indexed file and open in update mode
            xcall getfa(aChannel,"OMD",openMode)
            if (openMode=="U:I")
            begin

                ;;Check that the record length is not over the maximum we can support
                data recLen, int
                xcall getfa(aChannel,"RSZ",recLen)
                if (recLen > ^size(strInstruction.record))
                    exit

                ;;Search for a unique key
                for thisKey from 0 thru %isinfo(aChannel,"NUMKEYS") - 1
                begin
                    if (!%isinfo(aChannel,"DUPS",thisKey))
                    begin
                        ;;Found one
                        mActive = true
                        LastRecordCache.Init(aChannel)

                        ;;Is it REPLICATION_KEY and 20 long? If so we will cause the PRE STORE hook
                        ;;to fill the key with a timestamp value for new records.
                        xcall iskey(aChannel,thisKey,keyinfo)
                        upcase keyinfo.keynam
                        if ((mFillTimeStamp=(keyinfo.keynam=="REPLICATION_KEY"))&&(keylen==20))
                            mTimeStampPos = keypos

                        ;;Good to go
                        exitloop
                    end
                end

                if (mActive)
                begin
                    ;;Record the channel number and structure name
                    mChannel = aChannel
                    if (mMultiTable = aStructureName.StartsWith("MULTI_")) then
                        mStructureName = aStructureName - "MULTI_"
                    else
                        mStructureName = aStructureName
                end

            end
        endmethod

        ;;---------------------------------------------------------------------
        ;;READ hooks

        public override method read_post_operation_hook, void
            required inout       aRecord, a
            optional in mismatch aKey,    n
            optional in          aRfa,    a
            optional in          aKeynum, n
            required in          aFlags,  IOFlags
            required inout       aError,  int
            endparams
        proc
            if (mActive && !aError && !(aFlags&IOFlags.LOCK_NO_LOCK))
            begin
                ;;Record the record that was just read (to support delete)
                LastRecordCache.Update(mChannel,aRecord)
            end
        endmethod

        public override method reads_post_operation_hook ,void
            required inout aRecord, a
            optional in    aRfa,    a
            required in    aFlags,  IOFlags
            required inout aError,  int
            endparams
        proc
            if (mActive && !aError && !(aFlags&IOFlags.LOCK_NO_LOCK))
            begin
                ;;Record the record that was just read (to support delete)
                LastRecordCache.Update(mChannel,aRecord)
            end
        endmethod

        ;;---------------------------------------------------------------------
        ;;WRITE hooks

        public override method write_post_operation_hook, void
            required inout       aRecord, a
            optional in          aRecnum, n
            optional in          aRfa,    a
            required in          aFlags,  IOFlags
            required inout       aError,  int
            endparams
        proc
            ;;A record was just updated. If it changed then replicate the change.
            if (mActive && !aError)
                if (LastRecordCache.HasChanged(mChannel,aRecord))
                    xcall replicate(REPLICATION_INSTRUCTION.UPDATE_ROW,getTableName(aRecord),aRecord)
        endmethod

        ;;---------------------------------------------------------------------
        ;;STORE hooks

        public override method store_pre_operation_hook, void
            required inout aRecord, a
            required in    aFlags,  IOFlags
            endparams
        proc
            ;;If we're using REPLICATION_KEY, and the program has no populated it, then
            ;;then add a timestamp value for the new record. This MAY NOT result in a
            ;;unique value, which in that case will result in a duplicate key error from
            ;; the STORE.
            if (mActive && mFillTimeStamp && !aRecord(mTimeStampPos:20))
                aRecord(mTimeStampPos:20) = %datetime
        endmethod

        public override method store_post_operation_hook, void
            required inout       aRecord, a
            optional in          aRfa,    a
            required in          aFlags,  IOFlags
            required inout       aError,  int
            endparams
        proc
            ;;A new record was just created. Replicate the change.
            if (mActive && !aError)
                xcall replicate(REPLICATION_INSTRUCTION.CREATE_ROW,getTableName(aRecord),aRecord)
        endmethod

        ;;---------------------------------------------------------------------
        ;;DELETE hooks

        public override method delete_post_operation_hook, void
            required inout aError, int
            endparams
        proc
            ;;A record was just deleted. Replicate the change.
            if (mActive && !aError)
                xcall replicate(REPLICATION_INSTRUCTION.DELETE_ROW,getTableName(LastRecordCache.Retrieve(mChannel)),LastRecordCache.Retrieve(mChannel))
        endmethod

        ;;---------------------------------------------------------------------
        ;;CLOSE hooks

        public override method close_pre_operation_hook, void
            required in aFlags, IOFlags
            endparams
        proc
            if (mActive)
                LastRecordCache.Clear(mChannel)
        endmethod

        ;;-------------------------------------------------------------------------------------
        ;;Custom code for multi-record layout files

        ;.include "ONE_OF_THE_STRUCTURES" repository, structure="strSomething", end

        private method getTableName, string
            required in aRecord, a
        proc
;            if (mMultiTable) then
;            begin
;                using mStructureName select
;                ("FILENAME"),
;                begin
;                    data rec, strSomething, aRecord
;                    ;;Make sure you cover all the bases here, if not it'll be a problem!
;                    if (rec.some_tag_field=="1") then
;                        mreturn "STRUCTURE1"
;                    if (rec.some_tag_field=="2") then
;                        mreturn "STRUCTURE2"
;                    if (rec.some_tag_field=="3")
;                        mreturn "STRUCTURE3"
;                end
;               (),
;                    mreturn "*BUG*"
;                endusing
;            end
;            else
;            begin
                mreturn mStructureName
;            end

        endmethod

        ;;-------------------------------------------------------------------------------------

    endclass

endnamespace
