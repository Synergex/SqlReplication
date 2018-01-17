<CODEGEN_FILENAME>PopulateReplicationKey.dbl</CODEGEN_FILENAME>
;;*****************************************************************************
;;
;; File:        PopulateReplicationKey.dbl
;;
;; Description: Put unique replication key
;;
;; Author:      Steve Ives, Synergex Professional Services Group
;;
;;*****************************************************************************
;;
;; This routine fills in the value of the REPLICATION_KEY field with a %datetime
;; value. It should be called BY THE ORIGINAL APPLICATION from any routine that
;; CREATES new records in a file that has had a REPLICATION_KEY field and key
;; added. It populates the REPLICATION_KEY field with a %DATETIME value, but there
;; is no guarantee that the value will be unique witin the file. The application
;; must also trap "duplicate key" errors, and when encountered, sleep for a short
;; time (e.g. SLEEP 0.01) and then recall this routine to get a new REPLICATION_KEY
;; value before attempting the STORE again. This behavior should continue until the
;; duplicate key error does not occur.
;;

subroutine PopulateReplicationKey
	required in    channel, n
	required inout aRecord, a
	endparams
	stack record
		fileSpec, a128
		fileName, a80
		fileExt,  a20
	endrecord

    ;;Include the structure for each record type that needs REPLICATION_KEY populating on STORE
;   .include "SOME_STRUCTURE" repository, structure="strSomeStructure"

proc
	xcall filnm(channel,fileSpec)
	xcall parse(fileSpec,,,,,fileName,fileExt)

	fileSpec = %atrim(fileName) + fileExt

	upcase fileSpec

	;;Add a section to fill out the REPLICATION_KEY field for each file / record type
	using fileSpec select
;	("SOMEFILE.ISM"),
;   	^m(strSomeStructure.replication_key,aRecord) = %datetime
	(),
		nop
	endusing

	xreturn

endsubroutine
