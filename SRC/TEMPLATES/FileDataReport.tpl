<CODEGEN_FILENAME><StructureName>DataReport.dbl</CODEGEN_FILENAME>

import Synergex.SynergyDE.Select

main <StructureName>DataReport

    .include "<STRUCTURE_NOALIAS>" repository, structure="str<StructureName>", end

    global common
        tt, i4
        ch, i4
        log, i4
    endrecord

    stack record
        <structureName>, str<StructureName>
    endrecord
proc

    open(tt=0,i,"tt:")
    open(ch=0,i:i,"<FILE_NAME>")
    open(log=0,o:s,"<StructureName>DataReport.txt")

    foreach <structureName> in new Select(new From(ch,<structureName>))
    begin
        ;;Check that decimal fields contain valid numeric values
        <FIELD_LOOP>
        <IF DECIMAL>
        <IF NOPRECISION>
        ;TODO: Code goes here
        </IF NOPRECISION>
        </IF DECIMAL>
        </FIELD_LOOP>

        ;;Check that implied decimal fields contain valid numeric values
        <FIELD_LOOP>
        <IF DECIMAL>
        <IF PRECISION>
        ;TODO: Code goes here
        </IF PRECISION>
        </IF DECIMAL>
        </FIELD_LOOP>

        ;;Check that integer fields contain valid numeric values
        <FIELD_LOOP>
        <IF INTEGER>
        ;TODO: Code goes here
        </IF INTEGER>
        </FIELD_LOOP>

        ;;Check that date fields contain valid date values
        <FIELD_LOOP>
        <IF DATE>
        ;TODO: Code goes here
        </IF DATE>
        </FIELD_LOOP>

        ;;Check that time fields contain valid date values
        <FIELD_LOOP>
        <IF TIME>
        ;TODO: Code goes here
        </IF TIME>
        </FIELD_LOOP>

    end

    close ch
    close log
    close tt
    stop

endmain

subroutine LogError
    required in fullRecord, a
    required in fieldName, string
    required in errorMessage, string
    required in fieldData, string
    external common
        tt, i4
        ch, i4
        log, i4
    endrecord
    stack record
        field, a30
    endrecord
proc
    field = fieldName
    writes(log,"Record " + %keyval(ch,fullRecord,0) + " field " + field + " " + errorMessage + " " + fieldData
    xreturn
endsubroutine

function CheckDecimal, boolean
    required in fullRecord, a
    required in fieldName, string
    required in fieldData, d
    required in allowNegative, boolean
    endparams
    stack record
        ok, boolean
    endrecord
proc
    ok = true

    if (!ok)
        nop

    freturn ok
endfunction

function CheckImpliedDecimal, boolean
    required in field, d.
    required in allowNegative, boolean
    endparams
    stack record
        ok, boolean
    endrecord
proc
    ok = true
    freturn ok
endfunction

function CheckInteger, boolean
    required in field, i
    required in allowNegative, boolean
    endparams
    stack record
        ok, boolean
    endrecord
proc
    ok = true
    freturn ok
endfunction

function CheckDate, boolean
    required in field, d
    required in allowNull, boolean
    endparams
    stack record
        ok, boolean
    endrecord
proc
    ok = true
    freturn ok
endfunction

function CheckTime, boolean
    required in field, d
    endparams
    stack record
        ok, boolean
    endrecord
proc
    ok = true
    freturn ok
endfunction

