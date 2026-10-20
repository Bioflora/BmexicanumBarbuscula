#!/bin/bash

###############################################
# CONFIGURACIÓN DE INPUT Y OUTPUT
###############################################
p2o="all.p2o.csv"
pfam="all.pfam"
out="p2o_pfam_match_output.tab"

###############################################
# CHECKPOINT 1: Comprobar existencia de ficheros
###############################################
if [[ ! -f "$p2o" ]]; then
    echo "ERROR: No se encuentra el fichero $p2o" >&2
    exit 1
fi

if [[ ! -f "$pfam" ]]; then
    echo "ERROR: No se encuentra el fichero $pfam" >&2
    exit 1
fi

###############################################
# PROCESAMIENTO AWK
###############################################
awk -F'\t' -v OFS="\t" -v p2o="$p2o" '
BEGIN {
    ###############################################
    # CHECKPOINT 2: Cargar all.pfam en memoria
    ###############################################
    while ((getline line < ARGV[1]) > 0) {
        gsub(/\r/, "", line)
        split(line, a, "\t")

        id = a[1]
        pfams = a[2]
        descs = a[3]

        # Si la primera columna está vacía → descartar
        if (id == "") {
            print "WARNING: Línea sin ID en all.pfam → " line > "/dev/stderr"
            continue
        }

        # Si las columnas PFAM y descripción están vacías → avisar y no guardar
        if (pfams == "" || descs == "") {
            print "WARNING: ID " id " en all.pfam tiene columnas vacías; se ignora." > "/dev/stderr"
            continue
        }

        pfam_ids[id] = pfams
        pfam_desc[id] = descs
    }
    close(ARGV[1])

    ###############################################
    # CHECKPOINT 3: Preparar lectura del CSV
    ###############################################
    FS=","   # ahora procesaremos all.p2o.csv
    print "p2o_row", "pfam_row", "gene_id", "pfam_ids", "pfam_desc"
}

###############################################
# PROCESAR all.p2o.csv
###############################################
{
    row_id = $1

    # Comprobación de integridad
    if (row_id == "") {
        print "WARNING: Línea sin ID en all.p2o.csv → " $0 > "/dev/stderr"
        next
    }

    # Solo procesar si existe match en all.pfam
    if (!(row_id in pfam_ids)) {
        next
    }

    ###############################################
    # Extraer el primer identificador del gen
    ###############################################
    split($3, fields, " ")

    gene_id = ""
    for (i in fields) {
        if (fields[i] ~ /^[A-Za-z0-9_.-]+$/) {
            gene_id = fields[i]
            break
        }
    }

    if (gene_id == "") {
        print "WARNING: No se pudo extraer gene_id en fila → " $0 > "/dev/stderr"
        next
    }

    ###############################################
    # OUTPUT
    ###############################################
    print row_id, row_id, gene_id, pfam_ids[row_id], pfam_desc[row_id]
}
' "$pfam" "$p2o" > "$out"

echo "✔ Archivo generado: $out"

