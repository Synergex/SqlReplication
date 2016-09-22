<CODEGEN_FILENAME>ReplicationIoHooks.dbl</CODEGEN_FILENAME>
<PROCESS_TEMPLATE>SynIO</PROCESS_TEMPLATE>
<PROCESS_TEMPLATE>SqlIO</PROCESS_TEMPLATE>
<PROCESS_TEMPLATE>replicate</PROCESS_TEMPLATE>
<PROCESS_TEMPLATE>LastRecordCache</PROCESS_TEMPLATE>
;//*****************************************************************************
;//
;// Title:      ReplicationIoHooks.tpl
;//
;// Description:Template to generate an IO Hooks class for use with SQL replication
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
;; Description: An I/O Hooks class that implements SQL data replication
;;
;; Author:      <AUTHOR>
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
        private mActive, boolean
        private mChannel, int, 0
        private mKeyNum, int, -1
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
        proc
            ;;Make sure the channel is to an indexed file and open in update mode
            xcall getfa(aChannel,"OMD",openMode)
            if (mActive = (openMode=="U:I"))
            begin
                ;;Record the structure name and channel number
                mStructureName = aStructureName
                mChannel = aChannel

                ;;Search for the first unique key
                for thisKey from 0 thru %isinfo(mChannel,"NUMKEYS") - 1
                begin
                    if (!%isinfo(mChannel,"DUPS",thisKey))
                    begin
                        ;;Found one
                        mKeyNum = thisKey

                        ;;Is it REPLICATION_KEY and 20 long? If so we will cause the PRE STORE hook
                        ;;to fill the key with a timestamp value for new records.
                        xcall iskey(mChannel,mKeyNum,keyinfo)
                        upcase keyinfo.keynam
                        if ((mFillTimeStamp=(keyinfo.keynam=="REPLICATION_KEY"))&&(keylen==20))
                            mTimeStampPos = keypos

                        ;;Good to go
                        exitloop
                    end
                end

                ;;Did we find a unique key? If not, we can't enable replication.
                if (mActive=(mKeyNum>=0))
                begin
                    ;;Initialize the last record cache for the channel
                    LastRecordCache.Init(mChannel)
                end
            end
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

        ;;---------------------------------------------------------------------
        ;;DELETE hooks

;//     public override method delete_pre_operation_hook, void
;//         endparams
;//     proc
;//
;//     endmethod
;//
        public override method delete_post_operation_hook, void
            required inout aError, int
            endparams
        proc
            ;;A record was just deleted. Replicate the change.
            if (mActive && !aError)
                xcall replicate(REPLICATION_INSTRUCTION.DELETE_ROW,mStructureName,%keyval(mChannel,LastRecordCache.Retrieve(mChannel),mKeyNum))
        endmethod

;//     ;;---------------------------------------------------------------------
;//     ;;FIND hooks
;//
;//     public override method find_pre_operation_hook, void
;//         optional in mismatch aKey,    n
;//         optional in          aRfa,    a
;//         optional in          aKeynum, n
;//         required in          aFlags,  IOFlags
;//     proc
;//
;//     endmethod
;//
;//     public override method find_post_operation_hook, void
;//         optional in mismatch aKey,    n
;//         optional in          aRfa,    a
;//         optional in          aKeynum, n
;//         required in          aFlags,  IOFlags
;//         required inout       aError,  int
;//         endparams
;//     proc
;//
;//     endmethod
;//
        ;;---------------------------------------------------------------------
        ;;READ hooks

;//     public override method read_pre_operation_hook, void
;//         optional in mismatch aKey,    n
;//         optional in          aRfa,    a
;//         optional in          aKeynum, n
;//         required in          aFlags,  IOFlags
;//         endparams
;//     proc
;//
;//     endmethod
;//
        public override method read_post_operation_hook, void
            required inout       aRecord, a
            optional in mismatch aKey,    n
            optional in          aRfa,    a
            optional in          aKeynum, n
            required in          aFlags,  IOFlags
            required inout       aError,  int
            endparams
        proc
            if (mActive && !aError)
            begin
                ;;Record the record that was just read (to support delete)
                LastRecordCache.Update(mChannel,aRecord)
            end
        endmethod

        ;;---------------------------------------------------------------------
        ;;READS hooks

;//     public virtual method reads_pre_operation_hook, void
;//         required in          aFlags,  IOFlags
;//         endparams
;//     proc
;//
;//     endmethod
;//
        public override method reads_post_operation_hook ,void
            required inout aRecord, a
            optional in    aRfa,    a
            required in    aFlags,  IOFlags
            required inout aError,  int
            endparams
        proc
            if (mActive && !aError)
            begin
                ;;Record the record that was just read (to support delete)
                LastRecordCache.Update(mChannel,aRecord)
            end
        endmethod

        ;;---------------------------------------------------------------------
        ;;STORE hooks

        public override method store_pre_operation_hook, void
            required inout aRecord, a
            required in    aFlags,  IOFlags
            endparams
        proc
            ;;If we're using REPLICATION_KEY then add the timestamp value for the new record
            if (mActive&&mFillTimeStamp)
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
                xcall replicate(REPLICATION_INSTRUCTION.CREATE_ROW,mStructureName,%keyval(mChannel,aRecord,mKeyNum))
        endmethod

;//     ;;---------------------------------------------------------------------
;//     ;;UNLOCK hooks
;//
;//     public virtual method unlock_pre_operation_hook, void
;//         optional in          aRfa,    a
;//         required in          aFlags,  IOFlags
;//         endparams
;//     proc
;//
;//     endmethod
;//
;//     public override method unlock_post_operation_hook, void
;//         required in          aFlags,  IOFlags
;//         required inout       aError,  int
;//         endparams
;//     proc
;//
;//     endmethod
;//
        ;;---------------------------------------------------------------------
        ;;WRITE hooks

;//     public override method write_pre_operation_hook, void
;//         required inout       aBuffer, a
;//         optional in          aRecnum, n
;//         optional in          aRfa,    a
;//         required in          aFlags,  IOFlags
;//         endparams
;//     proc
;//
;//     endmethod
;//
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
                    xcall replicate(REPLICATION_INSTRUCTION.UPDATE_ROW,mStructureName,%keyval(mChannel,aRecord,mKeyNum))
        endmethod

;//     ;;---------------------------------------------------------------------
;//     ;;WRITES hooks
;//
;//     public override method writes_pre_operation_hook, void
;//         required inout       aBuffer, a
;//         required in          aFlags,  IOFlags
;//         endparams
;//     proc
;//
;//     endmethod
;//
;//     public override method writes_post_operation_hook, void
;//         required inout       aBuffer, a
;//         optional in          aRfa,    a
;//         required in          aFlags,  IOFlags
;//         required inout       aError,  int
;//         endparams
;//     proc
;//
;//     endmethod
;//
    endclass

endnamespace
