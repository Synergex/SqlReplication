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
$ RPSUTL -i [.REPOSITORY]REPOSITORY.SCM -ia -ir
$ !
$ !------------------------------------------------------------------------------------
$ WRITE SYS$OUTPUT "Prototyping library routines..."
$ !
$ DBLPROTO -OUT LIBRARY LIBSRC:*.dbl
$ !
$ WRITE SYS$OUTPUT "Compiling library routines..."
$ DBL/OPT/OBJ=OBJ:LIBRARY.OBJ -
   LIBSRC:CommandLineParser.dbl -
 + LIBSRC:ConfigureReplication.dbl -
 + LIBSRC:DatabaseCommunicationException.dbl -
 + LIBSRC:DataConversionTools.dbl -
 + LIBSRC:DepartmentSqlIO.dbl -
 + LIBSRC:EmployeeSqlIO.dbl -
 + LIBSRC:File.dbl -
 + LIBSRC:FileChunkReader.dbl -
 + LIBSRC:FileServiceClient.dbl -
 + LIBSRC:GenerateDepartmentData.dbl -
 + LIBSRC:GenerateEmployeeData.dbl -
 + LIBSRC:GetDateTimeString.dbl -
 + LIBSRC:GetInstanceNames.dbl -
 + LIBSRC:GetReplicatedTables.dbl -
 + LIBSRC:IndexExists.dbl -
 + LIBSRC:InstanceInfo.dbl -
 + LIBSRC:IOHooksISAM.dbl -
 + LIBSRC:IOHooksRELATIVE.dbl -
 + LIBSRC:IsDate.dbl -
 + LIBSRC:IsDecimal.dbl -
 + LIBSRC:IsEmailAddress.dbl -
 + LIBSRC:IsTime.dbl -
 + LIBSRC:Json.dbl -
 + LIBSRC:LastRecordCache.dbl -
 + LIBSRC:MakeDateForCsv.dbl -
 + LIBSRC:MakeDecimalForCsv.dbl -
 + LIBSRC:MakeTimeForCsv.dbl -
 + LIBSRC:OpenOrCreateQueueFile.dbl -
 + LIBSRC:PopulateReplicationKey.dbl - 
 + LIBSRC:Replicate.dbl -
 + LIBSRC:SmtpMail.dbl -
 + LIBSRC:StringDictionary.dbl -
 + LIBSRC:StringTools.dbl -
 + LIBSRC:ThrowOnCommunicationError.dbl -
 + LIBSRC:PalwSqlIO.dbl -
 + LIBSRC:ProdSqlIO.dbl -
 + LIBSRC:PurhSqlIO.dbl -
 + LIBSRC:PurlSqlIO.dbl -
 + LIBSRC:TcodSqlIO.dbl -
 + LIBSRC:VendSqlIO.dbl -
 + LIBSRC:WhpdSqlIO.dbl -
 + LIBSRC:WhseSqlIO.dbl -
 + LIBSRC:WhvdSqlIO.dbl
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
$ DBL/OPT/OBJ=OBJ:REPLICATOR.OBJ -
   REPSRC:replicator -
 + REPSRC:ConfigureEnvironment.dbl -
 + REPSRC:Counters.dbl -
 + REPSRC:DatabaseConnect.dbl -
 + REPSRC:DatabaseDisconnect.dbl -
 + REPSRC:DatabaseReconnect.dbl -
 + REPSRC:GetSettings.dbl -
 + REPSRC:Logger.dbl -
 + REPSRC:OpenQueueFile.dbl -
 + REPSRC:ReOpenQueueFile.dbl -
 + REPSRC:ReplicatorShutdown.dbl -
 + REPSRC:SendEmail.dbl -
 + REPSRC:Settings.dbl -
 + REPSRC:TimeNow.dbl
$!
$ LINK/EXE=REPLICATOR_EXE:REPLICATOR.EXE OBJ:REPLICATOR.OBJ,'OPTIONS_FILE
$ !
$ DBL/OPT/OBJ=OBJ: TOOLSRC:ChangeEveryEmployee.dbl
$ LINK/EXE=REPLICATOR_EXE:ChangeEveryEmployee.exe OBJ:ChangeEveryEmployee.obj,'OPTIONS_FILE
$ !
$ DBL/OPT/OBJ=OBJ: TOOLSRC:DepartmentMaintenance.dbl
$ LINK/EXE=REPLICATOR_EXE:DepartmentMaintenance.exe OBJ:DepartmentMaintenance.obj,'OPTIONS_FILE
$ !
$ DBL/OPT/OBJ=OBJ: TOOLSRC:EmployeeDataReport.dbl
$ LINK/EXE=REPLICATOR_EXE:EmployeeDataReport.exe OBJ:EmployeeDataReport.obj,'OPTIONS_FILE
$ !
$ DBL/OPT/OBJ=OBJ: TOOLSRC:EmployeeMaintenance.dbl
$ LINK/EXE=REPLICATOR_EXE:EmployeeMaintenance.exe OBJ:EmployeeMaintenance.obj,'OPTIONS_FILE
$ !
$ DBL/OPT/OBJ=OBJ: TOOLSRC:InstructionCount.dbl
$ LINK/EXE=REPLICATOR_EXE:InstructionCount.exe OBJ:InstructionCount.obj,'OPTIONS_FILE
$ !
$ DBL/OPT/OBJ=OBJ: TOOLSRC:QueueMonitor.dbl
$ LINK/EXE=REPLICATOR_EXE:QueueMonitor.exe OBJ:QueueMonitor.obj,'OPTIONS_FILE
$ !
$ DBL/OPT/OBJ=OBJ: TOOLSRC:ReplicatorMenu.dbl
$ LINK/EXE=REPLICATOR_EXE:ReplicatorMenu.exe OBJ:ReplicatorMenu.obj,'OPTIONS_FILE
$ !
$ DBL/OPT/OBJ=OBJ: TOOLSRC:ReplicatorStop.dbl
$ LINK/EXE=REPLICATOR_EXE:ReplicatorStop.exe OBJ:ReplicatorStop.obj,'OPTIONS_FILE
$ !
$ !------------------------------------------------------------------------------------
$ WRITE SYS$OUTPUT "Cleaning up..."
$ !
$ PURGE/NOCONFIRM/NOLOG [...]
$ !
$ EXIT
