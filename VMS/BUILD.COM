$ !
$ HERE = F$PARSE(F$ENVIRONMENT("PROCEDURE"),,,"DEVICE") + F$PARSE(F$ENVIRONMENT("PROCEDURE"),,,"DIRECTORY")
$ SET DEF 'HERE
$ !
$ @SETUP.COM
$ !
$ !------------------------------------------------------------------------------------
$ WRITE SYS$OUTPUT "Loading repository schema..."
$ !
$ RPSUTL:==$RPS:RPSUTL.EXE
$ !
$ RPSUTL -i [-.REPOSITORY]REPLICATION.SCH -ia -ir
$ !
$ !------------------------------------------------------------------------------------
$ WRITE SYS$OUTPUT "Prototyping library routines..."
$ !
$ DBLPROTO -OUT LIBRARY LIBSRC:*.DBL
$ !
$ WRITE SYS$OUTPUT "Compiling library routines..."
$ DIB/OPT/VECTORS=VECTORS/OBJ=OBJ:LIBRARY.OBJ -
   LIBSRC:CommandLineParser.dbl -
 + LIBSRC:ConfigureReplication.dbl -
 + LIBSRC:DepartmentIO.dbl -
 + LIBSRC:EmployeeIO.dbl -
 + LIBSRC:EmployeeSqlIO.dbl -
 + LIBSRC:GetReplicatedTables.dbl -
 + LIBSRC:IndexExists.dbl -
 + LIBSRC:IOHooksISAM.dbl -
 + LIBSRC:IOHooksRELATIVE.dbl -
 + LIBSRC:IsDate.dbl -
 + LIBSRC:IsEmailAddress.dbl -
 + LIBSRC:IsNumeric.dbl -
 + LIBSRC:IsTime.dbl -
 + LIBSRC:LastRecordCache.dbl -
 + LIBSRC:PopulateReplicationKey.dbl - 
 + LIBSRC:Replicate.dbl -
 + LIBSRC:SmtpMail.dbl -
 + LIBSRC:StringTools.dbl -
 + LIBSRC:UploadToWebService.dbl
$ !
$ WRITE SYS$OUTPUT "Creating object library LIBRARY.OLB..."
$ LIB/CREATE OBJ:LIBRARY.OLB OBJ:LIBRARY.OBJ
$ !
$ WRITE SYS$OUTPUT "Creating shared image LIBRARY.EXE..."
$ MAKESHARE -L OBJ:LIBRARY.OLB -E REPLICATOR_EXE: -Q -SQL -XD
$ @LIBRARY.COM
$ !
$ !------------------------------------------------------------------------------------
$ WRITE SYS$OUTPUT "Compiling replicator and utilities..."
$ !
$ OPTIONS_FILE="''HERE'REPLICATOR.OPT/OPT"
$ !
$ DIB/OPT/OBJ=OBJ: REPSRC:REPLICATOR.DBL
$ LINK/EXE=REPLICATOR_EXE:REPLICATOR.EXE OBJ:REPLICATOR.OBJ,'OPTIONS_FILE
$ !
$ DIB/OPT/OBJ=OBJ: REPSRC:ReplicatorMenu.dbl
$ LINK/EXE=REPLICATOR_EXE:ReplicatorMenu.exe OBJ:ReplicatorMenu.obj,'OPTIONS_FILE
$ !
$ DIB/OPT/OBJ=OBJ: REPSRC:EMPLOYEEMAINTENANCE.DBL
$ LINK/EXE=REPLICATOR_EXE:EMPLOYEEMAINTENANCE.EXE OBJ:EMPLOYEEMAINTENANCE.OBJ,'OPTIONS_FILE
$ !
$ !------------------------------------------------------------------------------------
$ WRITE SYS$OUTPUT "Cleaning up..."
$ !
$ PURGE/KEEP=3/NOCONFIRM/NOLOG RPSMFIL
$ PURGE/KEEP=3/NOCONFIRM/NOLOG RPSTFIL
$ PURGE/KEEP=3/NOCONFIRM/NOLOG LIBSRC:
$ PURGE/KEEP=3/NOCONFIRM/NOLOG REPSRC:
$ PURGE/NOCONFIRM/NOLOG [-.REPOSITORY]*.SCH
$ PURGE/NOCONFIRM/NOLOG LIBRARY.COM
$ PURGE/NOCONFIRM/NOLOG VECTORS.VEC
$ PURGE/NOCONFIRM/NOLOG OBJ:
$ PURGE/NOCONFIRM/NOLOG REPLICATOR_EXE:
$ !
$ EXIT
