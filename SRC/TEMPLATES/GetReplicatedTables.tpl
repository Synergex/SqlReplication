<CODEGEN_FILENAME>GetReplicatedTables.dbl</CODEGEN_FILENAME>

import System.Collections

subroutine GetReplicatedTables
    required out tables, @ArrayList
proc
    tables = new ArrayList()
    <STRUCTURE_LOOP>
    tables.Add((string)"<StructureName>")
    </STRUCTURE_LOOP>
    xreturn
endsubroutine
