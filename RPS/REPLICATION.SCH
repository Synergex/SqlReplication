 
;  SYNERGY DATA LANGUAGE OUTPUT
;
;  REPOSITORY     : D:\PUBLIC\SqlReplicationIoHooks\PRJVS\repository\bin\Release
;                 : D:\PUBLIC\SqlReplicationIoHooks\PRJVS\repository\bin\Release
;                 : Version 10.3.3e
;
;  GENERATED      : 11-JUL-2018, 15:43:49
;                 : Version 10.3.3e
;  EXPORT OPTIONS : [ALL] 
 
 
Format PHONE   Type NUMERIC   "(XXX) XXX-XXXX"   Justify LEFT
 
Enumeration REPLICATION_INSTRUCTION
   Description "SQL Replication Instruction"
   Members CREATE_ROW 1, UPDATE_ROW 2, DELETE_ROW 3, CREATE_TABLE 4,
          LOAD_TABLE 5, CREATE_AND_LOAD_TABLE 6, DELETE_ALL_ROWS 7,
          DELETE_TABLE 8, SHUTDOWN 9, INSERT_RELATIVE 10,
          UPDATE_RELATIVE 11, ADD_INDEXES 12, DELETE_INDEXES 13,
          BULK_LOAD_TABLE 14, DELETE_ALL_INSTRUCTIONS 20, CLOSE_FILE 21,
          CHANGE_INTERVAL 22, CREATE_CSV 23, CYCLE_LOG 24
 
Template DEPARTMENT_ID   Type ALPHA   Size 15
   Description "Department ID"
   Prompt "Department"
   Uppercase
   Required
   Drill Method "department_drill"   Change Method "department_change"
 
Template DEPARTMENT_NAME   Type ALPHA   Size 50
   Description "Department name"
   Required
 
Template EMPLOYEE_ID   Type DECIMAL   Size 6
   Description "Employee ID"
   Prompt "Employee ID"
   Required
 
Template PERSON_FIRST_NAME   Type ALPHA   Size 20
   Description "First name"
   Prompt "First name"
   Required
 
Template PERSON_LAST_NAME   Type ALPHA   Size 20
   Description "Last name"
   Prompt "Last name"
   Required
 
Template PHONE_NUMBER   Type DECIMAL   Size 10
   Description "Phone Number"
   Prompt "Phone"   Info Line "Enter a telephone number"   Format PHONE
   Report Just LEFT   Input Just LEFT   Blankifzero
 
Structure DEPARTMENT   DBL ISAM
   Description "Department Master File"
 
Field DEPT_ID   Template DEPARTMENT_ID
   Prompt "Department"
 
Field DEPT_NAME   Template DEPARTMENT_NAME   Dimension 1
   Prompt "Description"   User Text "@CODEGEN_DISPLAY_FIELD"
 
Field DEPT_MANAGER   Template EMPLOYEE_ID
   Description "Department manager"
   Prompt "Manager"
 
Key DEPT_ID   ACCESS   Order ASCENDING   Dups NO
   Description "Department ID"
   Segment FIELD   DEPT_ID
 
Key DEPT_MANAGER   ACCESS   Order ASCENDING   Dups YES   Insert END
   Modifiable YES   Krf 001
   Description "Department manager"
   Segment FIELD   DEPT_MANAGER  SegType ALPHA
 
Structure EMPLOYEE   DBL ISAM
   Description "Employee Master File"
 
Field EMP_ID   Template EMPLOYEE_ID
   Info Line "Enter an employee ID"   ODBC Name EMPLOYEE_ID
 
Field EMP_FIRST_NAME   Template PERSON_FIRST_NAME
   Prompt "First name"   Info Line "Enter the employees first name"
   ODBC Name FIRST_NAME
   Required
 
Field EMP_LAST_NAME   Template PERSON_LAST_NAME
   Info Line "Enter the employees last name"
   User Text "@CODEGEN_DISPLAY_FIELD"   ODBC Name LAST_NAME
 
Field EMP_DEPT   Template DEPARTMENT_ID
   Description "Employee's department ID"
   Info Line "Enter a department ID"   ODBC Name DEPARTMENT_ID   Nodisabled
 
Field EMP_HIRE_DATE   Type DATE   Size 8   Stored YYYYMMDD
   Coerced Type NULLABLE_DATETIME
   Description "Date hired"
   Prompt "Hire Date"   Info Line "Enter the employees date of hire"
   ODBC Name HIRE_DATE
   Date Today
 
Field EMP_PHONE_WORK   Type ALPHA   Size 14
   Description "Work phone number"
   Prompt "Work phone"
 
Field EMP_PHONE_HOME   Type ALPHA   Size 14
   Description "Home phone number"
   Prompt "Home phone"
 
Field EMP_PHONE_CELL   Type ALPHA   Size 14
   Description "Cell phone number"
   Prompt "Cell phone"
 
Field EMP_PAID   Type DECIMAL   Size 1
   Description "Employee pay method"
   Prompt "Paid"   Info Line "Is the employee paid hourly or salaried"
   Default "1"   Automatic
   Selection List 0 0 0  Entries "Hourly", "Salaried"
   Enumerated 8 1 1
 
Field EMP_HOME_OK   Type DECIMAL   Size 1
   Description "OK to call at home"
   Prompt "Call home OK"   Info Line "Is it OK to call this employee at home"
   Checkbox
   Default "1"   Automatic
 
Field EMP_DATE_OF_BIRTH   Type DATE   Size 8   Stored YYYYMMDD
   Coerced Type NULLABLE_DATETIME
   Description "Date of birth"
   Prompt "Date of birth"   Info Line "Enter the employees date of birth"
 
Field EMP_HIRE_TIME   Type TIME   Size 4   Stored HHMM
   Description "Hire time"
   Prompt "Hire time"   Info Line "Enter the time the employee was hired"
   Time Now
 
Field EMP_EMAIL   Type ALPHA   Size 40
   Description "Email address"
   Prompt "Email"
 
Field EMP_ADDRESS_STREET   Type ALPHA   Size 30
   Description "Street address"
   Prompt "Address"   Info Line "What is the employees street address?"
 
Field EMP_ADDRESS_CITY   Type ALPHA   Size 20
   Description "City"
   Prompt "City"   Info Line "What city does the employee live in?"
 
Field EMP_ADDRESS_STATE   Type ALPHA   Size 2
   Description "State"
   Prompt "State"   User Text "Which state does the employee live in?"
   Uppercase
 
Field EMP_ADDRESS_ZIP   Type DECIMAL   Size 5
   Description "Zip code"
   Prompt "Zip code"   Info Line "What is the employees home ZIP code?"
 
Field NONAME_001   Type ALPHA   Size 78   Language Noview   Script Noview
   Report Noview   Nonamelink
   Description "Spare space"
 
Key EMP_ID   ACCESS   Order ASCENDING   Dups NO
   Segment FIELD   EMP_ID  SegType ALPHA
 
Key EMP_DEPT   ACCESS   Order ASCENDING   Dups YES   Insert END
   Modifiable YES   Krf 001
   Description "Department ID"
   Segment FIELD   EMP_DEPT
 
Key EMP_LAST_NAME   ACCESS   Order ASCENDING   Dups YES   Insert END
   Modifiable YES   Krf 002
   Description "Last name"
   Segment FIELD   EMP_LAST_NAME  SegType NOCASE  SegOrder ASCENDING
 
Key STATE_CODE   ACCESS   Order ASCENDING   Dups YES   Insert END
   Modifiable YES   Krf 003
   Description "State"
   Segment FIELD   EMP_ADDRESS_STATE  SegType ALPHA  SegOrder ASCENDING
 
Key ZIP_CODE   ACCESS   Order ASCENDING   Dups YES   Insert END
   Modifiable YES   Krf 004
   Description "Zip code"
   Segment FIELD   EMP_ADDRESS_ZIP  SegType ALPHA  SegOrder ASCENDING
 
Structure EMPLOYEES   DBL ISAM
   Description "Employee Master File (MAPPED)"
   Long Description
      "@MAP=EMPLOYEE;"
 
Field EMPLOYEE_ID   Template EMPLOYEE_ID
   Long Description
      "@MAP=EMP_ID;"
   Info Line "Enter an employee ID"
 
Field FIRST_NAME   Template PERSON_FIRST_NAME
   Long Description
      "@MAP=EMP_FIRST_NAME;"
   Prompt "First name"   Info Line "Enter the employees first name"
   Required
 
Field LAST_NAME   Template PERSON_LAST_NAME
   Long Description
      "@MAP=EMP_LAST_NAME;"
   Info Line "Enter the employees last name"
 
Field DEPARTMENT   Template DEPARTMENT_ID
   Description "Employee's department ID"
   Long Description
      "@MAP=EMP_DEPT;"
   Info Line "Enter a department ID"   Nodisabled
 
Field HIRE_DATE   Type DATE   Size 8   Stored YYYYMMDD
   Coerced Type NULLABLE_DATETIME
   Description "Date hired"
   Long Description
      "@MAP=EMP_HIRE_DATE;"
   Prompt "Hire Date"   Info Line "Enter the employees date of hire"
   Date Today
 
Field WORK_PHONE   Type ALPHA   Size 14
   Description "Work phone number"
   Long Description
      "@MAP=EMP_PHONE_WORK;"
   Prompt "Work phone"
 
Field HOME_PHONE   Type ALPHA   Size 14
   Description "Home phone number"
   Long Description
      "@MAP=EMP_PHONE_HOME;"
   Prompt "Home phone"
 
Field CELL_PHONE   Type ALPHA   Size 14
   Description "Cell phone number"
   Long Description
      "@MAP=EMP_PHONE_CELL;"
   Prompt "Cell phone"
 
Field PAID   Type DECIMAL   Size 1
   Description "Employee pay method"
   Long Description
      "@MAP=EMP_PAID;"
   Prompt "Paid"   Info Line "Is the employee paid hourly or salaried"
   Default "1"   Automatic
   Selection List 0 0 0  Entries "Hourly", "Salaried"
   Enumerated 8 1 1
 
Field OK_TO_CALL_HOME   Type DECIMAL   Size 1
   Description "OK to call at home"
   Long Description
      "@MAP=EMP_HOME_OK;"
   Prompt "Call home OK"   Info Line "Is it OK to call this employee at home"
   Checkbox
   Default "1"   Automatic
 
Field DATE_OF_BIRTH   Type DATE   Size 8   Stored YYYYMMDD
   Coerced Type NULLABLE_DATETIME
   Description "Date of birth"
   Long Description
      "@MAP=EMP_DATE_OF_BIRTH;"
   Prompt "Date of birth"   Info Line "Enter the employees date of birth"
 
Field HIRE_TIME   Type TIME   Size 4   Stored HHMM
   Description "Hire time"
   Long Description
      "@MAP=EMP_HIRE_TIME;"
   Prompt "Hire time"   Info Line "Enter the time the employee was hired"
   Time Now
 
Field EMAIL   Type ALPHA   Size 40
   Description "Email address"
   Long Description
      "@MAP=EMP_EMAIL;"
   Prompt "Email"
 
Field STREET   Type ALPHA   Size 30
   Description "Street address"
   Long Description
      "@MAP=EMP_ADDRESS_STREET;"
   Prompt "Address"   Info Line "What is the employees street address?"
 
Field CITY   Type ALPHA   Size 20
   Description "City"
   Long Description
      "@MAP=EMP_ADDRESS_CITY;"
   Prompt "City"   Info Line "What city does the employee live in?"
 
Field STATE   Type ALPHA   Size 2
   Description "State"
   Long Description
      "@MAP=EMP_ADDRESS_STATE;"
   Prompt "State"   User Text "Which state does the employee live in?"
   Uppercase
 
Field ZIP   Type DECIMAL   Size 5
   Description "Zip code"
   Long Description
      "@MAP=EMP_ADDRESS_ZIP;"
   Prompt "Zip code"   Info Line "What is the employees home ZIP code?"
 
Key EMP_ID   ACCESS   Order ASCENDING   Dups NO
   Segment FIELD   EMPLOYEE_ID  SegType ALPHA
 
Key EMP_DEPT   ACCESS   Order ASCENDING   Dups YES   Insert END
   Modifiable YES   Krf 001
   Description "Department ID"
   Segment FIELD   DEPARTMENT
 
Key EMP_LAST_NAME   ACCESS   Order ASCENDING   Dups YES   Insert END
   Modifiable YES   Krf 002
   Description "Last name"
   Segment FIELD   LAST_NAME  SegType NOCASE  SegOrder ASCENDING
 
Key STATE_CODE   ACCESS   Order ASCENDING   Dups YES   Insert END
   Modifiable YES   Krf 003
   Description "State"
   Segment FIELD   STATE  SegType ALPHA  SegOrder ASCENDING
 
Key ZIP_CODE   ACCESS   Order ASCENDING   Dups YES   Insert END
   Modifiable YES   Krf 004
   Description "Zip code"
   Segment FIELD   ZIP  SegType ALPHA  SegOrder ASCENDING
 
Structure RELSTR   RELATIVE
   Description "Relative structure"
 
Field FIELD1   Type ALPHA   Size 1
   Description "Field 1"
 
Field FIELD2   Type DECIMAL   Size 2
   Description "Field 2"
 
Field FIELD3   Type DATE   Size 8   Stored YYYYMMDD
   Description "Field 3"
 
Field FIELD4   Type TIME   Size 6   Stored HHMMSS
   Description "Field 4"
 
Key RECORD_NUMBER   ACCESS   Order ASCENDING   Dups NO
   Segment RECORD NUMBER
 
Structure REPLICATION   DBL ISAM
   Description "Replication request queue"
 
Field TRANSACTION_ID   Type AUTOSEQ   Size 8
   Description "Unique transaction ID (I8 timestamp)"
   Report Just LEFT   Input Just LEFT   Readonly
   Nonull
 
Field ACTION   Type DECIMAL   Size 2
   Description "Replicator action"
 
Field STRUCTURE_NAME   Type ALPHA   Size 32
   Description "the SDMS structure name"
 
Field RECORD   Type ALPHA   Size 65000
   Description "Record affected"
 
Key TRANSACTION_ID   ACCESS   Order ASCENDING   Dups NO   Density 100
   Description "Transaction ID (I8 timestamp)"
   Segment FIELD   TRANSACTION_ID  SegType SEQUENCE
 
Structure REPLICATION_OLD   DBL ISAM
   Description "Replication request queue (old format)"
 
Field TRANSACTION_ID   Type ALPHA   Size 20
   Description "Unique transaction ID (I8 timestamp)"
   Readonly
   Nonull
 
Field ACTION   Type DECIMAL   Size 2
   Description "Replicator action"
 
Field STRUCTURE_NAME   Type ALPHA   Size 32
   Description "the SDMS structure name"
 
Field RECORD   Type ALPHA   Size 65000
   Description "Record affected"
 
Key TRANSACTION_ID   ACCESS   Order ASCENDING   Dups NO   Density 100
   Description "Transaction ID (I8 timestamp)"
   Segment FIELD   TRANSACTION_ID
 
Structure REPLICATION_VMS   DBL ISAM
   Description "Replication request queue (OpenVMS)"
 
Field TRANSACTION_ID   Type AUTOSEQ   Size 8
   Description "Unique transaction ID (timestamp)"
   Report Just LEFT   Input Just LEFT   Readonly
   Nonull
 
Field ACTION   Type DECIMAL   Size 2
   Description "Replicator action"
 
Field STRUCTURE_NAME   Type ALPHA   Size 32
   Description "the SDMS structure name"
 
Field RECORD   Type ALPHA   Size 32000
   Description "Record affected"
 
Key TRANSACTION_ID   ACCESS   Order ASCENDING   Dups NO   Density 100
   Description "Transaction ID (timestamp)"
   Segment FIELD   TRANSACTION_ID  SegType SEQUENCE
 
Structure REPLICATION_VMS_OLD   DBL ISAM
   Description "Replication request queue (OpenVMS) Old"
 
Field TRANSACTION_ID   Type ALPHA   Size 20
   Description "Unique transaction ID (timestamp)"
   Readonly
   Nonull
 
Field ACTION   Type DECIMAL   Size 2
   Description "Replicator action"
 
Field STRUCTURE_NAME   Type ALPHA   Size 32
   Description "the SDMS structure name"
 
Field RECORD   Type ALPHA   Size 32000
   Description "Record affected"
 
Key TRANSACTION_ID   ACCESS   Order ASCENDING   Dups NO   Density 100
   Description "Transaction ID (timestamp)"
   Segment FIELD   TRANSACTION_ID
 
Structure TEST   DBL ISAM
   Description "test"
 
Field F1   Type ALPHA   Size 1
   Description "f1"
 
Field F2   Type ALPHA   Size 2
   Description "F2"
 
Key K0   ACCESS   Order ASCENDING   Dups NO
   Description "k0"
   Segment FIELD   F1
   Segment FIELD   F2
 
File DEPARTMENT   DBL ISAM   "REPLICATOR_DATA:DEPARTMENT.ISM"
   Description "Department master file"
   Compress
   Assign DEPARTMENT
 
File EMPLOYEE   DBL ISAM   "REPLICATOR_DATA:EMPLOYEE.ISM"
   Description "Employee master file"
   Compress
   Assign EMPLOYEE
 
File RELFILE   RELATIVE   "REPLICATOR_DATA:RELFILE.DDF"
   Description "Relative file"
   Assign RELSTR
 
File REPLICATION   DBL ISAM   "REPLICATOR_DATA:REPLICATION.ISM"
   Description "SQL replication request queue file"
   Addressing 40BIT   Compress   Terabyte
   Assign REPLICATION
 
File REPLICATION_VMS   DBL ISAM   "REPLICATOR_DATA:REPLICATION.ISM"
   Description "SQL replication request queue file (VMS)"
   Addressing 40BIT
   Assign REPLICATION_VMS
 
