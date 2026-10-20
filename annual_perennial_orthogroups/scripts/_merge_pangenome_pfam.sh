#!/bin/bash

###############################################
# CONFIGURACIÓN DE INPUT Y OUTPUT
###############################################
pang="pangenome_matrix_t0.tr.tab"
pfam="p2o_pfam_match_output.tab"

out="BadiRate_input_pangenome_matrix_t0.tr_pfam.tab"
no_match="BadiRate_input_pangenome_matrix_t0.tr_NO_MATCH_pfam.txt"

###############################################
# CHECKPOINT 1: Comprobar existencia de ficheros
###############################################
if [[ ! -f "$pang" ]]; then
    echo "ERROR: No se encuentra el fichero $pang" >&2
    exit 1
fi

if [[ ! -f "$pfam" ]]; then
    echo "ERROR: No se encuentra el fichero $pfam" >&2
    exit 1
fi

###############################################
# PROCESAMIENTO AWK
###############################################
awk -F'\t' -v OFS="\t" -v pfam="$pfam" -v no_match="$no_match" '
BEGIN {
    ###############################################
    # Cargar PFAM en memoria
    ###############################################
    while ((getline line < pfam) > 0) {
        gsub(/\r/, "", line)
        split(line, a, "\t")

        # Saltar header
        if (a[1] == "p2o_row") continue

        gene = a[3]
        pfam_ids[gene] = a[4]
        pfam_desc[gene] = a[5]
    }
    close(pfam)

    # Preparar fichero de NO MATCH
    print "" > no_match
}

NR==1 {
    ###############################################
    # Añadir columnas nuevas al header
    ###############################################
    print $0, "pfam_gene_id", "pfam_ids", "pfam_desc"
    next
}

{
    ###############################################
    # 1) Normalizar el ID del cluster
    ###############################################
    raw = $1

    # Eliminar prefijo numérico + "_"
    sub(/^[0-9]+_/, "", raw)

    # Eliminar sufijo ".fna"
    sub(/\.fna$/, "", raw)

    normalized_gene = raw

    ###############################################
    # 2) Crear versión modificada SOLO PARA MATCH
    ###############################################
    match_gene = normalized_gene

    # Sustituir BmexP. → Brame.
    sub(/^BmexP\./, "Brame.", match_gene)

    # Sustituir BmexU. → Brame.
    sub(/^BmexU\./, "Brame.", match_gene)

    ###############################################
    # 3) Buscar match en PFAM usando match_gene
    ###############################################
    if (match_gene in pfam_ids) {
        print $0, match_gene, pfam_ids[match_gene], pfam_desc[match_gene]
    } else {
        print normalized_gene >> no_match
        print $0, "", "", ""
    }
}
' "$pang" > "$out"

echo "✔ Archivo generado:"
echo "   - $out"
echo "   - $no_match"

