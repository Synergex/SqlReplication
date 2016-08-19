<CODEGEN_FILENAME><StructureName>DataReport.dbl</CODEGEN_FILENAME>

import Synergex.SynergyDE.Select

.include "<STRUCTURE_NOALIAS>" repository, structure="str<StructureName>", end

main <StructureName>DataReport

    global common
        tt, i4
        ch, i4
        log, i4
        errors, i4
    endcommon

    stack record
        <structureName>, str<StructureName>
    endrecord
proc

    open(tt=0,i,"tt:")
    open(ch=0,i:i,"<FILE_NAME>")
    open(log=0,o:s,"<StructureName>DataReport.log")

    xcall flags(7004020,1)

    foreach <structureName> in new Select(new From(ch,<structureName>))
    begin
        ;;Check that decimal fields contain valid numeric values
        <FIELD_LOOP>
        <IF DECIMAL>
        <IF NOPRECISION>
        xcall CheckDecimal(<structureName>,"<FIELD_NAME>",<structureName>.<field_name>,<IF NEGATIVE_ALLOWED>true<ELSE>false</IF NEGATIVE_ALLOWED>)
        </IF NOPRECISION>
        </IF DECIMAL>
        </FIELD_LOOP>

        ;;Check that implied decimal fields contain valid numeric values
        <FIELD_LOOP>
        <IF DECIMAL>
        <IF PRECISION>
        xcall CheckImpliedDecimal(<structureName>,"<FIELD_NAME>",<structureName>.<field_name>,<IF NEGATIVE_ALLOWED>true<ELSE>false</IF NEGATIVE_ALLOWED>)
        </IF PRECISION>
        </IF DECIMAL>
        </FIELD_LOOP>

        ;;Check that integer fields contain valid numeric values
        <FIELD_LOOP>
        <IF INTEGER>
        xcall CheckInteger(<structureName>,"<FIELD_NAME>",<structureName>.<field_name>,<IF NEGATIVE_ALLOWED>true<ELSE>false</IF NEGATIVE_ALLOWED>)
        </IF INTEGER>
        </FIELD_LOOP>

        ;;Check that date fields contain valid date values
        <FIELD_LOOP>
        <IF DATE>
        xcall CheckDate(<structureName>,"<FIELD_NAME>",<structureName>.<field_name>,<IF DATE_NULLABLE>true<ELSE>false</IF DATE_NULLABLE>)
        </IF DATE>
        </FIELD_LOOP>

        ;;Check that time fields contain valid date values
        <FIELD_LOOP>
        <IF TIME>
        xcall CheckTime(<structureName>,"<FIELD_NAME>",<structureName>.<field_name>)
        </IF TIME>
        </FIELD_LOOP>
    end


    if (errors) then
    begin
        writes(tt,%string(errors) + " errors were found. Check log file <StructureName>DataReport.log")
        close log
    end
    else
    begin
        writes(tt,"No problems detected")
        purge log
    end

    close ch
    close tt

    sleep 1

    stop

endmain

subroutine LogError
    required in fullRecord, str<StructureName>
    required in fieldName, string
    required in errorMessage, string
    required in fieldData, string
    external common
        tt, i4
        ch, i4
        log, i4
        errors, i4
    endcommon
    stack record
        field, a30
    endrecord
proc
    field = fieldName
    writes(log,"Record " + %keyval(ch,fullRecord,0) + " field " + field + " " + errorMessage + " " + fieldData)
    errors += 1
    xreturn
endsubroutine

subroutine CheckDecimal
    required in fullRecord, str<StructureName>
    required in fieldName, string
    required in fieldData, d
    required in allowNegative, boolean
    endparams
    stack record
        ok, boolean
    endrecord
proc
    ok = true

    ;TODO: Add validation code

    if (!ok)
        LogError(fullRecord,fieldName,"",^a(fieldData))

    xreturn
endsubroutine

subroutine CheckImpliedDecimal
    required in fullRecord, str<StructureName>
    required in fieldName, string
    required in fieldData, d.
    required in allowNegative, boolean
    endparams
    stack record
        ok, boolean
    endrecord
proc
    ok = true

    ;TODO: Add validation code

    if (!ok)
        LogError(fullRecord,fieldName,"",^a(fieldData))

    xreturn
endsubroutine

subroutine CheckInteger
    required in fullRecord, str<StructureName>
    required in fieldName, string
    required in fieldData, i
    required in allowNegative, boolean
    endparams
    stack record
        ok, boolean
    endrecord
proc
    ok = true

    ;TODO: Add validation code

    if (!ok)
        LogError(fullRecord,fieldName,"",^a(fieldData))

    xreturn
endsubroutine

subroutine CheckDate
    required in fullRecord, str<StructureName>
    required in fieldName, string
    required in fieldData, d
    required in allowNull, boolean
    endparams
    stack record
        ok, boolean
    endrecord
proc
    ok = true

    ;TODO: Add validation code

    if (!ok)
        LogError(fullRecord,fieldName,"",^a(fieldData))

    xreturn
endsubroutine

subroutine CheckTime
    required in fullRecord, str<StructureName>
    required in fieldName, string
    required in fieldData, d
    endparams
    stack record
        ok, boolean
    endrecord
proc
    ok = true

    ;TODO: Add validation code

    if (!ok)
        LogError(fullRecord,fieldName,"",^a(fieldData))

    xreturn
endsubroutine

