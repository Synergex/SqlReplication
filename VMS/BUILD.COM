$ !
$ HERE = F$PARSE(F$ENVIRONMENT("PROCEDURE"),,,"DEVICE") + F$PARSE(F$ENVIRONMENT("PROCEDURE"),,,"DIRECTORY")
$ SET DEF 'HERE
$ !
$ @SETUP.COM
$ !
$ !------------------------------------------------------------------------------------
$ WRITE SYS$OUTPUT "Prototyping library routines..."
$ DBLPROTO -OUT LIBRARY LIBSRC:*.DBL
$ !
$ WRITE SYS$OUTPUT "Compiling library routines..."
$ DIB/DEB/OBJ=OBJ:LIBRARY.OBJ -
   LIBSRC:ConfigureReplication.dbl -
 + LIBSRC:DepartmentIO.dbl -
 + LIBSRC:EmployeeIO.dbl -
 + LIBSRC:EmployeeSqlIO.dbl -
 + LIBSRC:IsDate.dbl -
 + LIBSRC:IsNumeric.dbl -
 + LIBSRC:IsTime.dbl -
 + LIBSRC:LastRecordCache.dbl -
 + LIBSRC:PopulateReplicationKey.dbl - 
 + LIBSRC:Replicate.dbl -
 + LIBSRC:ReplicationIoHooks.dbl -
 + LIBSRC:SmtpMail.dbl
$ !
$ WRITE SYS$OUTPUT "Creating object library LIBRARY.OLB..."
$ LIB/CREATE OBJ:LIBRARY.OLB OBJ:LIBRARY.OBJ
$ !
$ WRITE SYS$OUTPUT "Creating shared image LIBRARY.EXE..."
$ MAKESHARE -L OBJ:LIBRARY.OLB -E EXE: -Q -SQL -XD
$ @LIBRARY.COM
$ !
$ !------------------------------------------------------------------------------------
$ WRITE SYS$OUTPUT "Compiling replicator and utilities..."
$ !
$ OPTIONS_FILE="''HERE'REPLICATOR.OPT/OPT"
$ !
$ DIB/OPT/OBJ=OBJ: REPSRC:EMPLOYEEMAINTENANCE.DBL
$ LINK/EXE=EXE:EMPLOYEEMAINTENANCE.EXE OBJ:EMPLOYEEMAINTENANCE.OBJ,'OPTIONS_FILE
$ !
$ DIB/OPT/OBJ=OBJ: REPSRC:REPLICATOR.DBL
$ LINK/EXE=EXE:REPLICATOR.EXE OBJ:REPLICATOR.OBJ,'OPTIONS_FILE
$ !
$ DIB/OPT/OBJ=OBJ: REPSRC:ReplicatorMenu.dbl
$ LINK/EXE=EXE:ReplicatorMenu.exe OBJ:ReplicatorMenu.obj,'OPTIONS_FILE
$ !
$ EXIT
