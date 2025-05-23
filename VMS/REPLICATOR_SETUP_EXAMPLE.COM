$!*****************************************************************************
$!
$! File:        REPLICATOR_SETUP_EXAMPLE.COM
$!
$! Type:        Command procedure
$!
$! Description: This file provides an example of how to configure an environment
$!              to run the replicator in. You should copy or rename this file
$!              to REPLICATOR_SETUP.COM as that file is called from other
$!              procedures.
$!
$! Author:      Steve Ives
$!
$!*****************************************************************************
$!
$! Copyright (c) 2016, Synergex International, Inc.
$! All rights reserved.
$!
$! Redistribution and use in source and binary forms, with or without
$! modification, are permitted provided that the following conditions are met:
$!
$! * Redistributions of source code must retain the above copyright notice,
$!   this list of conditions and the following disclaimer.
$!
$! * Redistributions in binary form must reproduce the above copyright notice,
$!   this list of conditions and the following disclaimer in the documentation
$!   and/or other materials provided with the distribution.
$!
$! THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
$! AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
$! IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
$! ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
$! LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
$! CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
$! SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
$! INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
$! CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
$! ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
$! POSSIBILITY OF SUCH DAMAGE.
$!
$!*****************************************************************************
$!
$ DATDIR = F$PARSE(F$ENVIRONMENT("PROCEDURE"),,,"DEVICE") + F$PARSE("[.DATA]",,,"DIRECTORY")
$ LOGDIR = F$PARSE(F$ENVIRONMENT("PROCEDURE"),,,"DEVICE") + F$PARSE("[.LOG]",,,"DIRECTORY")
$ EXEDIR = F$PARSE(F$ENVIRONMENT("PROCEDURE"),,,"DEVICE") + F$PARSE("[.EXE]",,,"DIRECTORY")
$ REPSHR = F$PARSE(F$ENVIRONMENT("PROCEDURE"),,,"DEVICE") + F$PARSE("[.EXE]",,,"DIRECTORY") + "LIBRARY.EXE"
$!
$ DEFINE/SYS/NOLOG REPLICATOR_SH 'REPSHR
$!
$!
$! Main configuration parameters
$!
$ DEFINE/SYS/NOLOG REPLICATOR_INSTANCE                  DEFAULT
$ DEFINE/SYS/NOLOG REPLICATOR_INTERVAL                  2
$ DEFINE/SYS/NOLOG REPLICATOR_DATABASE                  "net:DatabaseUser/DatabasePassword/DatabaseName/DatabaseServer///@1958:DatabaseServerOrIp!VTX12_SQLNATIVE"
$ DEFINE/SYS/NOLOG REPLICATOR_DATABASE_TIMEOUT          60
$ DEFINE/SYS/NOLOG REPLICATOR_COMMIT_MODE               BATCH
$ DEFINE/SYS/NOLOG REPLICATOR_EXE                       'EXEDIR
$ DEFINE/SYS/NOLOG REPLICATOR_DATA                      'DATDIR
$ DEFINE/SYS/NOLOG REPLICATOR_ERROR_STOP                YES
$!
$! Database reconnect settings
$!
$ DEFINE/SYS/NOLOG REPLICATOR_RECONNECT_ATTEMPTS        5
$ DEFINE/SYS/NOLOG REPLICATOR_RECONNECT_DELAY           60
$!
$! Replicator capabilities
$!
$ DEFINE/SYS/NOLOG REPLICATOR_MAX_COLS                  254
$ DEFINE/SYS/NOLOG REPLICATOR_MAX_CURSORS               128
$!
$! Bulk load configuration
$!
$ DEFINE/SYS/NOLOG REPLICATOR_EXPORT_LOCAL              'DATDIR
$ DEFINE/SYS/NOLOG REPLICATOR_FILESERVICE_HOST          "DatabaseServerOrIp"
$ DEFINE/SYS/NOLOG REPLICATOR_FILESERVICE_PORT          8080
$ DEFINE/SYS/NOLOG REPLICATOR_LOG_BULK_LOAD_EXCEPTIONS  YES
$ DEFINE/SYS/NOLOG REPLICATOR_BULKLOAD_TIMEOUT          900
$!
$! Logging configuration
$!
$ DEFINE/SYS/NOLOG REPLICATOR_LOGDIR                    'LOGDIR
$ DEFINE/SYS/NOLOG REPLICATOR_FULL_LOG                  YES
$ DEFINE/SYS/NOLOG REPLICATOR_LOG_KEYS                  YES
$ DEFINE/SYS/NOLOG REPLICATOR_SYSTEM_LOG                NO
$!
$! Email notification settings
$!
$! DEFINE/SYS/NOLOG REPLICATOR_ERROR_EMAIL               person.to.notify@someorg.com
$! DEFINE/SYS/NOLOG REPLICATOR_EMAIL_SENDER              replicator@someorg.com
$! DEFINE/SYS/NOLOG REPLICATOR_SMTP_SERVER               mail.someorg.com
$ !