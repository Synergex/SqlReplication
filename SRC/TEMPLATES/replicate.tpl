<CODEGEN_FILENAME>Replicate.dbl</CODEGEN_FILENAME>
;//*****************************************************************************
;//
;// Title:      replicate.tpl
;//
;// Description:Template to generate a subroutine to adds new instructions to
;//             the replication servers instruction file.
;//
;// Author:     Steve Ives, Synergex Professional Services Group
;//
;// Copyright   © 2009 Synergex International Corporation.  All rights reserved.
;//
;;*****************************************************************************
;;
;; File:        Replicate.dbl
;;
;; Type:        Subroutine (Replicate)
;;
;; Description: Adds new instructions to the replication servers instruction file.
;;
;; Author:      <AUTHOR>
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

.include "REPLICATION_INSTRUCTION" repository, enum, end

subroutine Replicate

	required in a_action, REPLICATION_INSTRUCTION
	optional in a_structure, a
	optional in a_key, a
	endparams

	.include "REPLICATION" repository, stack record="instruction", end

	static record
		chn ,i4
	endrecord

proc

	;Do we need to open the replication transaction file?
	if (!chn)
		open(chn=0,"U:I","DAT:REPLICATION.ISM")

	using a_action select

	(REPLICATION_INSTRUCTION.CLOSE_FILE),
	begin
		if (chn && %chopen(chn))
		begin
			close chn
			init chn
		end
	end

	(REPLICATION_INSTRUCTION.DELETE_ALL_INSTRUCTIONS),
	begin
		;Delete pending instructions
		repeat
		begin
			try
			begin
				read(chn,instruction,^FIRST)
				delete(chn)
			end
			catch (ex, @EndOfFileException)
			begin
				exitloop
			end
			catch (ex, @Exception)
			begin
				sleep 0.01
			end
			endtry
		end
	end

	(),
	begin
		;Issue new instruction

		init instruction

		instruction.action = (i)a_action

		if (^passed(a_structure) && a_structure)
			instruction.structure_name = a_structure

		if (^passed(a_key) && a_key)
			instruction.key = a_key

		repeat
		begin
			try
			begin
				instruction.transaction_id = %datetime
				store(chn,instruction)
				exitloop
			end
			catch (ex, @DuplicateException)
			begin
				sleep 0.01
			end
			endtry
		end
	end
	endusing

	xreturn

endsubroutine

