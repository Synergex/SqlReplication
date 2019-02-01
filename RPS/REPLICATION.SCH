 
;  SYNERGY DATA LANGUAGE OUTPUT
;
;  REPOSITORY     : F:\2019-01\SqlReplication\RPS\rpsmain.ism
;                 : F:\2019-01\SqlReplication\RPS\rpstext.ism
;                 : Version 10.3.3f
;
;  GENERATED      : 29-JAN-2019, 09:13:20
;                 : Version 10.3.3f
;  EXPORT OPTIONS : [ALL] 
 
 
Enumeration REPLICATION_INSTRUCTION
   Description "SQL Replication Instruction"
   Members CREATE_ROW 1, UPDATE_ROW 2, DELETE_ROW 3, CREATE_TABLE 4,
          LOAD_TABLE 5, CREATE_AND_LOAD_TABLE 6, DELETE_ALL_ROWS 7,
          DELETE_TABLE 8, SHUTDOWN 9, INSERT_RELATIVE 10,
          UPDATE_RELATIVE 11, ADD_INDEXES 12, DELETE_INDEXES 13,
          BULK_LOAD_TABLE 14, DELETE_ALL_INSTRUCTIONS 20, CLOSE_FILE 21,
          CHANGE_INTERVAL 22, CREATE_CSV 23, CYCLE_LOG 24
 
Structure REPLICATION   DBL ISAM
   Description "Replication request queue"
 
Field TRANSACTION_ID   Type AUTOSEQ   Size 8
   Description "Unique transaction ID (I8 timestamp)"
   Report Just LEFT   Input Just LEFT   Readonly
   Nonull
 
Field ACTION   Type DECIMAL   Size 2
   Description "Replicator action"
   Negative
 
Field STRUCTURE_NAME   Type ALPHA   Size 32
   Description "the SDMS structure name"
 
Field RECORD   Type ALPHA   Size 65000
   Description "Record affected"
 
Key TRANSACTION_ID   ACCESS   Order ASCENDING   Dups NO   Density 100
   Description "Transaction ID (I8 timestamp)"
   Segment FIELD   TRANSACTION_ID  SegType SEQUENCE
 
Structure REPLICATION_COSMOS   DBL ISAM
   Description "Replication request queue for CosmosDB"
 
Field TRANSACTION_ID   Type AUTOSEQ   Size 8
   Description "Unique transaction ID (I8 timestamp)"
   Report Just LEFT   Input Just LEFT   Readonly
   Nonull
 
Field ACTION   Type DECIMAL   Size 2
   Description "Replicator action"
   Negative
 
Field STRUCTURE_NAME   Type ALPHA   Size 32
   Description "Table name"
 
Field BEFORE   Type ALPHA   Size 32500
   Description "Record before changes"
 
Field AFTER   Type ALPHA   Size 32500
   Description "Record after changes"
 
Key TRANSACTION_ID   ACCESS   Order ASCENDING   Dups NO   Density 100
   Description "Transaction ID (I8 timestamp)"
   Segment FIELD   TRANSACTION_ID  SegType SEQUENCE
 
Structure TYPMAS   DBL ISAM
   Description "Unit types master record"
 
Tag FIELD   TYPRCT EQ "52"
 
Field TYPRCT   Type DECIMAL   Size 2
   Long Description
      "(0001,0002) smerf rec type for typmas (always 52!)"
   ODBC Name SMF_RECORD_TYPE
 
Field TYPPRJ   Type DECIMAL   Size 4
   Description "(0003,0006) PROJECT"
   ODBC Name PROPERTY_CODE
 
Field TYPTYP   Type ALPHA   Size 3
   Description "(0007,0009) TYPE ID"
   ODBC Name UNIT_TYPE_CODE
 
Field NONAME_001   Type ALPHA   Size 15
   Description "(0010,0024) fill out key to 24 chars"
 
Field TYPDSL   Type ALPHA   Size 35
   Description "(0025,0059) long description"
   ODBC Name LONG_DESC
 
Field TYPDSC   Type ALPHA   Size 8
   Description "(0060,0067) SHORT DESCRIPTION"
   ODBC Name SHORT_DESC
 
Field TYPOVL   Type DECIMAL   Size 4
   Description "(0068,0071) default overbook limit"
   ODBC Name DEFAULT_OVER_BOOK_LIMIT
 
Field TYPCNT   Type DECIMAL   Size 4
   Long Description
      "(0072,0075) default base count of real units"
   ODBC Name DEFAULT_BASE_COUNT
 
Field TYPCK1   Type DECIMAL   Size 1
   Description "(0076,0076) default checkin day for type"
   ODBC Name CHECKIN_DAY_WK
 
Field TYPCK2   Type DECIMAL   Size 1
   Description "(0077,0077) checkin day for half week"
   ODBC Name CHECKIN_DAY_MIDWK
 
Field TYPDYS   Type DECIMAL   Size 1
   Description "(0078,0078) number of days for half week"
   ODBC Name CHECKIN_DAY_HALF_WK
 
Field TYPWGT   Type DECIMAL   Size 6
   Long Description
      "(0079,0084) weighting factor for cen rental pool"
   ODBC Name WEIGHT_IN_RENTAL_POOL
 
Field TYPCG1   Type DECIMAL   Size 5
   Long Description
      "(0085,0089) hskeeping chg per nght guest is checked in"
   ODBC Name NIGHTLY_HK_CHARGE_AMOUNT
 
Field TYPCG2   Type DECIMAL   Size 5
   Long Description
      "(0090,0094) housekeeping charge on a checkout night"
   ODBC Name CHECKOUT_HK_CHARGE_AMOUNT
 
Field TYPFLT   Type DECIMAL   Size 1
   Long Description
      "(0095,0095) if=1, we do not assign units for"
   ODBC Name DONOT_ASSIGN_UNITS
 
Field TYPAMN   Type ALPHA   Size 20
   Long Description
      "(0096,0115) amenities for these type of units"
   ODBC Name UNIT_TYPE_AMENITIES
 
Field TYPATR   Type ALPHA   Size 1
   Long Description
      "(0116,0116) attribute flag for segment filtering"
   ODBC Name ATTRIBUTE_FLAG
 
Field TYPPLO   Type DECIMAL   Size 1
   Description "(0117,0117) where to find point values"
   ODBC Name WHERE_FIND_POINTS_VALUES
 
Field TYPITP   Type DECIMAL   Size 1
   Description "(0118,0118) Inventory control type:"
   ODBC Name MATRIX_OR_COUNTS
 
Field TYPCLB   Type DECIMAL   Size 1
   Long Description
      "(0119,0119) Booking Weight (# of bedrooms)"
   ODBC Name BOOKING_WEIGHT
 
Field TYPWYN   Type DECIMAL   Size 1
   Long Description
      "(0120,0120) Can i book this unittype on the web"
   ODBC Name AVAIL_ON_WEB
 
Field TYPDSW   Type ALPHA   Size 35
   Description "(0121,0155) web long description"
   ODBC Name WEB_LONG_DESC
 
Field TYPHCR   Type DECIMAL   Size 5   Dimension 10
   Long Description
      "(0156,0205) housekeeping `credits` value (xxx.xx)"
   ODBC Name HK_CREDITS_VALUE
 
Field TYPHTM   Type DECIMAL   Size 3   Dimension 10
   Long Description
      "(0206,0235) housekeeping time factor (minutes)"
   ODBC Name HK_TIME_FACTOR
 
Field TYPCDW   Type ALPHA   Size 3
   Description "(0236,0238) generic unit type"
   ODBC Name GENERIC_UNIT_TYPE
 
Field TYPSIT   Type ALPHA   Size 4
   Description "(0239,0242) interface site code"
   ODBC Name INTERFACE_SIDE_ID
 
Field TYPHPJ   Type ALPHA   Size 10
   Description "(0243,0252) hilstar`s property code"
   ODBC Name HILSTAR_PROPERTY_ID
 
Field TYPHTY   Type ALPHA   Size 10   Dimension 3
   Description "(0253,0282) hilstar types to update"
   ODBC Name HILSTAR_TYPES
 
Field TYPHUM   Type DECIMAL   Size 1
   Description "(0283,0283) hilstar sync method:"
   ODBC Name HILSTAR_UPDATE_HOLD
 
Field TYPHUO   Type DECIMAL   Size 1
   Description "(0284,0284) update hilstar Out-of-Order?"
   ODBC Name HILSTAR_UPDATE_OUTOFORDER
 
Field TYPMXO   Type DECIMAL   Size 3
   Long Description
      "(0285,0287) max days out to update hilstar"
   ODBC Name HILSTAR_MAX_DAYS_OUT
 
Field TYPHSG   Type ALPHA   Size 2   Dimension 5
   Long Description
      "(0288,0297) max days out to update hilstar"
   ODBC Name HILSTAR_SEGMENT
 
Field TYPADH   Type DECIMAL   Size 2
   Long Description
      "(0298,0299) ada holdback from rental count Dec2011"
   ODBC Name ADA_HOLDBACK_RENTAL_CNT
 
Field TYPHUA   Type DECIMAL   Size 1
   Long Description
      "(0300,0300) ada sync method, similar to typhum:"
   ODBC Name ADA_SYNC_METHOD
 
Field NONAME_002   Type ALPHA   Size 210
   Description "(0301,0510) slush"
 
Key KEY_0   ACCESS   Order ASCENDING   Dups NO
   Segment FIELD   TYPRCT
   Segment FIELD   TYPPRJ
   Segment FIELD   TYPTYP
   Segment FIELD   NONAME_001
 
Key KEY_1   ACCESS   Order ASCENDING   Dups YES   Modifiable YES
   Segment FIELD   TYPRCT
   Segment FIELD   TYPDSL
 
Structure UNTMAS   DBL ISAM
   Description "Unit Master Record"
 
Tag FIELD   UNTRCT EQ "53"
 
Field UNTRCT   Type DECIMAL   Size 2
   Description "(0001,0002) record type, always 53"
   ODBC Name SMF_REC_TYPE
 
Field UNTPRJ   Type DECIMAL   Size 4
   Description "(0003,0006)"
   ODBC Name PROPERTY_CODE
 
Field UNTNUM   Type ALPHA   Size 6
   Description "(0007,0012) {4}"
   ODBC Name UNIT_CODE
 
Field NONAME_001   Type ALPHA   Size 12
   Description "(0013,0024) fill out to 24 size key"
 
Field UDSAMN   Type ALPHA   Size 20
   Description "(0025,0044) amenity codes desc."
   ODBC Name AMENITY_DESC
 
Field UNTTYP   Type ALPHA   Size 3
   Description "(0045,0047)"
   ODBC Name UNIT_TYPE_CODE
 
Field UNTPRI   Type DECIMAL   Size 3
   Description "(0048,0050) PRIORITY IN ASSIGNMENT"
   ODBC Name PRIORITY_CODE
 
Field UNTPOS   Type DECIMAL   Size 3
   Long Description
      "(0051,0053) which element is this unit in the BOARD.ISM"
   ODBC Name BOARD_ELEMENT_NO
 
Field UNTOWF   Type ALPHA   Size 1
   Long Description
      "(0054,0054) W IF FIXED WEEK UNIT, O IF WHOLLY OWNED"
   ODBC Name OWNER_USAGE_TYPE
 
Field UNTMST   Type DECIMAL   Size 1
   Description "(0055,0055) 0=t/s, 4=c/l"
   ODBC Name TS_CODE
 
Field UNTACC   Type ALPHA   Size 12
   Description "(0056,0067) {new}"
   ODBC Name TS_ACCOUNT_NO
 
Field UNTOWN   Type ALPHA   Size 10   Overlay UNTACC:0
   Description "(0056,0065) {6} Whole owner number"
 
Field UNTONO   Type DECIMAL   Size 8   Overlay UNTACC:0
   Description "(0056,0063) {new} owner number"
 
Field UNTOPJ   Type DECIMAL   Size 4   Overlay UNTACC:8
   Description "(0064,0067) {new} project"
 
Field UNTPCT   Type DECIMAL   Size 4
   Description "(0068,0071) PERCENT OF REVENUE TO OWNER"
   ODBC Name TS_REVENUE_PERCENTAGE
 
Field UNTRMM   Type DECIMAL   Size 2
   Long Description
      "(0072,0073) MONTH TO DATE UNIT NITES USED"
   ODBC Name MTD_NIGHTS_USED
 
Field UNTRYD   Type DECIMAL   Size 3
   Description "(0074,0076) YTD    `  `    `    `     `"
   ODBC Name YTD_NIGHTS_USED
 
Field UNTRLY   Type DECIMAL   Size 3
   Description "(0077,0079) LAST YEARS YTD"
   ODBC Name LYR_NIGHTS_USED
 
Field MTD_REVENUE   Type DECIMAL   Size 10
   Description "Month to date revenue"
 
Field YTD_REVENUE   Type DECIMAL   Size 10
   Description "Year to date revenue"
 
Field LYR_REVENUE   Type DECIMAL   Size 10
   Description "Lasy year revenue"
 
Field UNTREV   Type DECIMAL   Size 10   Dimension 3   Overlay MTD_REVENUE:0
   Long Description
      "(0080,0109) {3D8} MTD,YTD,& LAST YTD REVENUE"
 
Field MTD_OWNER_REVENUE   Type DECIMAL   Size 10
   Description "Month to date owner revenue"
 
Field YTD_OWNER_REVENUE   Type DECIMAL   Size 10
   Description "Year to date owner revenue"
 
Field LYR_OWNER_REVENUE   Type DECIMAL   Size 10
   Description "Last year owner revenue"
 
Field UNTORV   Type DECIMAL   Size 10   Dimension 3
   Overlay MTD_OWNER_REVENUE:0
   Long Description
      "(0110,0139) {3D8} MTD,YTD,& LAST YTD OWNER`S REVENUE"
 
Field MTD_MAINT_COSTS   Type DECIMAL   Size 10
   Description "Month to date maintenance costs"
 
Field YTD_MAINT_COSTS   Type DECIMAL   Size 10
   Description "Year to date maintenance costs"
 
Field LYR_MAINT_COSTS   Type DECIMAL   Size 10
   Description "Last year maintenance costs"
 
Field UNTMNT   Type DECIMAL   Size 10   Dimension 3   Overlay MTD_MAINT_COSTS:0
   Long Description
      "(0140,0169) {3D8} MTD,YTD,& LAST YTD MAINT. COSTS"
 
Field UNTSMN   Type DECIMAL   Size 2
   Long Description
      "(0170,0171) MONTH THAT 31 DAY ARRAY IS FOR"
   ODBC Name MONTH_ARRAY_NO
 
Field UNTSTS   Type DECIMAL   Size 1   Dimension 31
   Long Description
      "(0172,0202) MONTHLY STATUS (E.G. OCCUPIED,RENTED,EMPTY)"
   ODBC Name MONTLY_STATUS
 
Field UNTLOC   Type ALPHA   Size 2
   Description "(0203,0204) UNIT LOCATION CODE"
   ODBC Name UNIT_LOCATION_CODE
 
Field UNTDAY   Type DECIMAL   Size 1
   Long Description
      "(0205,0205) CHECK-IN DAY IF FIXED WEEK TIMESHARE"
   ODBC Name CHECKIN_DAY
 
Field UNTRSC   Type DECIMAL   Size 3
   Description "(0206,0208) subcode for unit revenue"
   ODBC Name UNIT_REVENUE_SUBCODE
 
Field UNTOSC   Type DECIMAL   Size 3
   Description "(0209,0211) subcode for owner revenue"
   ODBC Name OWNER_REVENUE_SUBCODE
 
Field UDSCNF   Type ALPHA   Size 75
   Long Description
      "(0212,0286) full description for confirmations"
   ODBC Name UNIT_DESC
 
Field UDSSLP   Type DECIMAL   Size 2
   Description "(0287,0288) number of people unit sleeps"
   ODBC Name MAX_OCCUPANCY
 
Field UDSBED   Type DECIMAL   Size 2
   Description "(0289,0290) number of bedrooms"
   ODBC Name NO_OF_BEDROOMS
 
Field UDSEXT   Type DECIMAL   Size 4   Dimension 2
   Description "(0291,0298) up to 2 unit extension"
   ODBC Name PHONE_UNIT_EXT
 
Field UDSPHN   Type DECIMAL   Size 10
   Description "(0299,0308) unit`s phone number"
   ODBC Name UNIT_PHONE_NO
 
Field UDSOST   Type ALPHA   Size 2
   Description "(0309,0310) used for phone xface"
   ODBC Name PHONE_INTERFACE_FLAG1
 
Field UDSSTA   Type ALPHA   Size 2
   Description "(0311,0312) used for phone xface"
   ODBC Name PHONE_INTERFACE_FLAG2
 
Field UNTRCI   Type ALPHA   Size 10
   Long Description
      "(0313,0322) RCI Unit Number - used for WVS Mod (30864)"
   ODBC Name RCI_UNIT_NUMBER
 
Field UNTWOA   Type DECIMAL   Size 10
   Long Description
      "(0323,0332) {8} fixed amount mini-devl. gets for ngts"
   ODBC Name FIXED_RENTAL_AMOUNT
 
Field UNTWOD   Type DECIMAL   Size 8
   Long Description
      "(0333,0340) effective date - change overdate"
   ODBC Name CHANGE_OVERDATE
 
Field UNTTRX   Type DECIMAL   Size 3
   Long Description
      "(0341,0343) trx code to bill owners for T/A commiss"
   ODBC Name TA_COMMISS_TRX_CODE
 
Field UNTSUB   Type DECIMAL   Size 3
   Long Description
      "(0344,0346) subcode to bill owners for T/A commissions"
   ODBC Name TA_COMMISS_SUBCODE
 
Field UNTMIN   Type DECIMAL   Size 8
   Long Description
      "(0347,0354) minimum amount whole owner recieves/ night"
   ODBC Name WHOLE_OWNER_MIN_AMOUNT
 
Field UNTPPJ   Type DECIMAL   Size 4
   Description "(0355,0358) pcm project number"
   ODBC Name PCM_PROJECT_CODE
 
Field UNTPNM   Type ALPHA   Size 6
   Description "(0359,0364) pcm unit number"
   ODBC Name PCM_UNIT_CODE
 
Field UNTCBS   Type DECIMAL   Size 3
   Description "(0365,0367) send to this database"
   ODBC Name SEND_TO_DBASE_NO
 
Field UNTCPJ   Type DECIMAL   Size 4
   Long Description
      "(0368,0371) book in prop. database to this proj"
   ODBC Name PROP_DBASE_PROPERTY_CODE
 
Field UNTCUN   Type ALPHA   Size 6   Dimension 4
   Long Description
      "(0372,0395) book in prop. database these unit(s)"
   ODBC Name PROP_DBASE_UNIT_CODE
 
Field UNTCTY   Type ALPHA   Size 3   Dimension 4
   Long Description
      "(0396,0407) book in prop. database type(s)"
   ODBC Name PROP_DBASE_UNIT_TYPE
 
Field UNTATR   Type ALPHA   Size 2   Dimension 20
   Long Description
      "(0408,0447) ADA code attributes  ;WO#IM023610 2011SEP"
   ODBC Name ADA_ATTRIBUTE_CODE
 
Field UNTATO   Type ALPHA   Size 40   Overlay UNTATR:0
   Description "(0408,0447)"
 
Field UNTPRT   Type ALPHA   Size 1   Dimension 5
   Long Description
      "(0448,0452) Property Parameter Type(PRMTYP) ;TFS000785"
   ODBC Name PROPERTY_PARAMETER_CODE
 
Field AUNTPRT   Type ALPHA   Size 5   Overlay UNTPRT:0
 
Field UNTPRV   Type ALPHA   Size 6   Dimension 5
   Long Description
      "(0453,0482) Property Parameter Value  ;WO TFS000785"
   ODBC Name PROPERTY_PARAMETER_TYPE
 
Field NONAME_002   Type ALPHA   Size 28   Language Noview   Script Noview
   Report Noview   Nonamelink
   Description "(0483,0510) slush"
 
Key KEY_0   ACCESS   Order ASCENDING   Dups NO
   Segment FIELD   UNTRCT
   Segment FIELD   UNTPRJ
   Segment FIELD   UNTNUM
   Segment FIELD   NONAME_001
 
Key KEY_1   ACCESS   Order ASCENDING   Dups YES   Modifiable YES
   Segment FIELD   UNTRCT
   Segment FIELD   UDSAMN
 
File REPLICATION   DBL ISAM   "REPLICATOR_DATA:REPLICATION.ISM"
   Description "SQL replication request queue file"
   Addressing 40BIT   Compress   Terabyte
   Assign REPLICATION
 
File REPLICATION_COSMOS   DBL ISAM   "REPLICATOR_DATA:REPLICATION_COSMOS.ISM"
   Description "SQL replication request queue (Cosmos)"
   Addressing 40BIT   Compress   Terabyte
   Assign REPLICATION_COSMOS
 
File TYPMAS   DBL ISAM   "CM010:CMSSMF.ISM"
   Description "Property type master file"
   Assign TYPMAS
 
File UNTMAS   DBL ISAM   "CM010:CMSSMF.ISM"
   Description "Unit master file"
   Assign UNTMAS
 
