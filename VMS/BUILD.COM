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
 + LIBSRC:ReplicatorControl.dbl -
 + LIBSRC:SmtpMail.dbl
$ !
$ WRITE SYS$OUTPUT "Creating object library LIBRARY.OLB..."
$ LIB/CREATE OBJ:LIBRARY.OLB OBJ:LIBRARY.OBJ
$ !
$ WRITE SYS$OUTPUT "Creating shared image LIBRARY.EXE..."
$! MAKESHARE -L OBJ:LIBRARY.OLB -E EXE: -Q -SQL -XD
$ @LIBRARY.COM
$ !
$ !------------------------------------------------------------------------------------
$ WRITE SYS$OUTPUT "Compiling replicator and utilities..."
$ !
$ OPTIONS_FILE="''HERE'REPLICATOR.OPT/OPT"
$ !
$ DIB/OPT/OBJ=OBJ: REPSRC:REPLICATOR.DBL
$ LINK/EXE=EXE:REPLICATOR.EXE OBJ:REPLICATOR.OBJ,'OPTIONS_FILE
$ !
$ DIB/OPT/OBJ=OBJ: REPSRC:INSTRUCTIONCOUNT.DBL
$ LINK/EXE=EXE:INSTRUCTIONCOUNT.EXE OBJ:INSTRUCTIONCOUNT.OBJ,'OPTIONS_FILE
$ !
$ DIB/OPT/OBJ=OBJ: REPSRC:ReplicatorMenu.dbl
$ LINK/EXE=EXE:ReplicatorMenu.exe OBJ:ReplicatorMenu.obj,'OPTIONS_FILE
$ !
$ DIB/OPT/OBJ=OBJ: REPSRC:REPLICATORSTOP.DBL
$ LINK/EXE=EXE:REPLICATORSTOP.EXE OBJ:REPLICATORSTOP.OBJ,'OPTIONS_FILE
$ !
$ !------------------------------------------------------------------------------------
$ WRITE SYS$OUTPUT "Compiling sample application..."
$ !
$ DIB/DEBUG/OBJ=OBJ:APPLICATION.OBJ -
   APPSRC:MENU.DBL -
 + APPSRC:DEPARTMENT_CHANGE.DBL -
 + APPSRC:DEPARTMENT_DRILL.DBL -
 + APPSRC:DEPARTMENT_LOOKUP.DBL -
 + APPSRC:DISPLAY_LOCAL_FIELDS.DBL -
 + APPSRC:EMPLOYEE_MAINT_TAB.DBL -
 + APPSRC:ENTRST_METHOD.DBL -
 + APPSRC:GENERATEDEPARTMENTDATA.DBL -
 + APPSRC:GENERATEEMPLOYEEDATA.DBL - 
 + APPSRC:HEADINGS_FROM_WINDOW.DBL -
 + APPSRC:I_CHECKDATA.DBL -
 + APPSRC:POSITION_WINDOW.DBL -
 + APPSRC:WNDEVENT_CLOSE.DBL
$ !
$ LINK/EXE=EXE:APPLICATION.EXE OBJ:APPLICATION.OBJ,'OPTIONS_FILE
$ !
$ !------------------------------------------------------------------------------------
$ WRITE SYS$OUTPUT "Building window library..."
$ !
$ SCRIPT:==$WND:SCRIPT.EXE
$ SCRIPT -c EXE:TKAPP.ISM -i APPSRC:EMPLOYEE_MAINT_TAB.WSC
$ EXIT
