 
;  SYNERGY DATA LANGUAGE OUTPUT
;
;  REPOSITORY     : C:\Users\K\Documents\Visual Studio 2017\Projects\SqlReplicat
;                 : C:\Users\K\Documents\Visual Studio 2017\Projects\SqlReplicat
;                 : Version 10.3.3c
;
;  GENERATED      : 07-AUG-2017, 15:09:24
;                 : Version 10.3.3c
;  EXPORT OPTIONS : [ENUMERATION=REPLICATION_INSTRUCTION] 
;                 : [STRUCTURE=REPLICATION] [FILE=REPLICATION] 
 
 
Enumeration REPLICATION_INSTRUCTION
   Description "SQL Replication Instruction"
   Members CREATE_ROW 1, UPDATE_ROW 2, DELETE_ROW 3, CREATE_TABLE 4,
          LOAD_TABLE 5, CREATE_AND_LOAD_TABLE 6, DELETE_ALL_ROWS 7,
          DELETE_TABLE 8, SHUTDOWN 9, CREATE_CSV 11,
          DELETE_ALL_INSTRUCTIONS 20, CLOSE_FILE 21, CHANGE_INTERVAL 22
 
Structure REPLICATION   DBL ISAM
   Description "Replication request queue"
 
Field TRANSACTION_ID   Type ALPHA   Size 20
   Description "Unique transaction ID (timestamp)"
 
Field ACTION   Type DECIMAL   Size 2
   Description "Replicator action"
 
Field STRUCTURE_NAME   Type ALPHA   Size 32
   Description "the SDMS structure name"
 
Field RECORD   Type ALPHA   Size 65000
   Description "Record affected"
 
Key TRANSACTION_ID   ACCESS   Order ASCENDING   Dups NO   Density 100
   Description "Transaction ID (timestamp)"
   Segment FIELD   TRANSACTION_ID
 
File REPLICATION   DBL ISAM   "DAT:REPLICATION.ISM"
   Description "SQL replication request queue file"
   Addressing 40BIT   Compress   Terabyte
   Assign REPLICATION
 
