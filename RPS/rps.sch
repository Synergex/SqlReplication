 
;  SYNERGY DATA LANGUAGE OUTPUT
;
;  REPOSITORY     : C:\DEV\PUBLIC\SqlReplicationIoHooksPrimaryKey\RPS\rpsmain.is
;                 : C:\DEV\PUBLIC\SqlReplicationIoHooksPrimaryKey\RPS\rpstext.is
;                 : Version 10.3.3a
;
;  GENERATED      : 05-AUG-2016, 09:01:34
;                 : Version 10.3.3a
;  EXPORT OPTIONS : [ALL-K-R-A] 
 
 
Format PHONE   Type NUMERIC   "(XXX) XXX-XXXX"   Justify LEFT
 
Enumeration REPLICATION_INSTRUCTION
   Description "SQL Replication Instruction"
   Members CREATE_ROW 1, UPDATE_ROW 2, DELETE_ROW 3, CREATE_TABLE 4,
          LOAD_TABLE 5, CREATE_AND_LOAD_TABLE 6, DELETE_ALL_ROWS 7,
          DELETE_TABLE 8, SHUTDOWN 9, CYCLE_LOG 10,
          DELETE_ALL_INSTRUCTIONS 20, CLOSE_FILE 21
 
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
   Prompt "Employee"
   Required
 
Template PERSON_FIRST_NAME   Type ALPHA   Size 30
   Description "First name"
   Prompt "First name"
   Required
 
Template PERSON_LAST_NAME   Type ALPHA   Size 30
   Description "Last name"
   Prompt "Last name"
   Uppercase
   Required
 
Template PHONE_NUMBER   Type DECIMAL   Size 10
   Description "Phone Number"
   Prompt "Phone"   Info Line "Enter a telephone number"   Format PHONE
   Blankifzero
 
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
   Description "Date hired"
   Prompt "Hire Date"   Info Line "Enter the employees date of hire"
   ODBC Name HIRE_DATE
   Date Today
   Required
 
Field EMP_PHONE   Template PHONE_NUMBER   Dimension 3
   Noinfo   ODBC Name PHONE
 
Field EMP_PAID   Type DECIMAL   Size 1
   Description "Employee pay method"
   Prompt "Paid"   Info Line "Is the employee paid hourly or salaried"
   Default "1"   Automatic
   Selection List 0 0 0  Entries "Hourly", "Salaried"
   Enumerated 8 1 1
 
Field EMP_HOME_OK   Type DECIMAL   Size 1
   Description "OK to call at home"
   Prompt "OK to Call Home"
   Info Line "Is it OK to call this employee at home"   Checkbox
   Default "1"   Automatic
 
Field EMP_DATE_OF_BIRTH   Type DATE   Size 8   Stored YYYYMMDD
   Description "Date of birth"
   Prompt "D.O.B."   Info Line "Enter the employees date of birth"
   Required
 
Field EMP_TIME_OF_BIRTH   Type TIME   Size 4   Stored HHMM
   Description "Time of birth"
   Prompt "T.O.B."   Info Line "Enter the employees time of birth"
 
Field NONAME_001   Type ALPHA   Size 67   Language Noview   Script Noview
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
   Segment FIELD   EMP_LAST_NAME
 
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
 
Structure EMPLOYEE_INPUT   DBL ISAM
   Description "Employee Master File (For Input)"
   User Text "@NOCODEGEN"
 
Group EMPLOYEE   Reference EMPLOYEE   Type ALPHA
   Description "Employee structure"
 
Field EMP_DEPT_DSP   Template DEPARTMENT_NAME
   Readonly
 
Structure EMPLOYEE_CRITERIA   DBL ISAM
   Description "Employee Master File (Search Criteria)"
   User Text "@NOCODEGEN"
 
Field MODE   Type DECIMAL   Size 1
   Description "Search mode"
   Radio
   Selection List 0 0 0  Entries "Last Name", "Department"
   Enumerated 10 1 1
   Change Method "employee_mntmode"
 
Field FIELD1   Template PERSON_LAST_NAME
   Noprompt
   Norequired
 
Field FIELD2   Template DEPARTMENT_ID
   Noprompt
   Norequired
 
Structure REPLICATION   DBL ISAM
   Description "Replication request queue"
 
Field TRANSACTION_ID   Type ALPHA   Size 20
   Description "Unique transaction ID (timestamp)"
 
Field ACTION   Type DECIMAL   Size 2
   Description "Replicator action"
 
Field STRUCTURE_NAME   Type ALPHA   Size 32
   Description "the SDMS structure name"
 
Field KEY   Type ALPHA   Size 255
   Description "Primary key of affected record"
 
Key TRANSACTION_ID   ACCESS   Order ASCENDING   Dups NO
   Description "Transaction ID (timestamp)"
   Segment FIELD   TRANSACTION_ID
 
File DEPARTMENT   DBL ISAM   "DAT:DEPARTMENT.ISM"
   Description "Department master file"
   Compress
   Assign DEPARTMENT
 
File EMPLOYEE   DBL ISAM   "DAT:EMPLOYEE.ISM"
   Description "Employee master file"
   Compress
   Assign EMPLOYEE
 
File REPLICATION   DBL ISAM   "DAT:REPLICATION.ISM"
   Description "SQL replication request queue file"
   Assign REPLICATION
 
