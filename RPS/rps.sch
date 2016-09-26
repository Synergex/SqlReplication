 
;  SYNERGY DATA LANGUAGE OUTPUT
;
;  REPOSITORY     : C:\DEV\PUBLIC\SqlReplicationIoHooks\RPS\rpsmain.ism
;                 : C:\DEV\PUBLIC\SqlReplicationIoHooks\RPS\rpstext.ism
;                 : Version 10.3.3a
;
;  GENERATED      : 23-SEP-2016, 00:25:30
;                 : Version 10.3.3a
;  EXPORT OPTIONS : [ALL-K-R-A] 
 
 
Format PHONE   Type NUMERIC   "(XXX) XXX-XXXX"   Justify LEFT
 
Enumeration REPLICATION_INSTRUCTION
   Description "SQL Replication Instruction"
   Members CREATE_ROW 1, UPDATE_ROW 2, DELETE_ROW 3, CREATE_TABLE 4,
          LOAD_TABLE 5, CREATE_AND_LOAD_TABLE 6, DELETE_ALL_ROWS 7,
          DELETE_TABLE 8, SHUTDOWN 9, CYCLE_LOG 10, CREATE_CSV 11,
          DELETE_ALL_INSTRUCTIONS 20, CLOSE_FILE 21, CHANGE_INTERVAL 22
 
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
 
Field NONAME_001   Type ALPHA   Size 135   Language Noview   Script Noview
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
   Selection List 0 0 0  Entries "Employee ID", "Last Name", "Department"
   Enumerated 10 1 1
   Change Method "employee_mntmode"
 
Field FIELD1   Template EMPLOYEE_ID
 
Field FIELD2   Template PERSON_LAST_NAME
   Noprompt
   Norequired
 
Field FIELD3   Template DEPARTMENT_ID
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
 
