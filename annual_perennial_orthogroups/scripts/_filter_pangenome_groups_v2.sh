#!/bin/bash

# ============================
# CONFIGURACIÓN DEL USUARIO
# ============================

# Fichero input
INPUT="pangenome_matrix_t0.tr_pfam.tab"

# Ficheros output

OUTPUT_KEEP="Core_subgenomic_pangenome.tab"
OUTPUT_REMOVE="Core_subgenomic_pangenome_removed.tmp"

#OUTPUT_KEEP="Core_species_pangenome.tab"
#OUTPUT_REMOVE="Core_species_pangenome_removed.tmp"

#OUTPUT_KEEP="Perennial_only_pangenome.tab"
#OUTPUT_REMOVE="Perennial_only_pangenome_removed.tmp"

#OUTPUT_KEEP="Annual_only_pangenome.tab"
#OUTPUT_REMOVE="Annual_only_pangenome_removed.tmp"

#OUTPUT_KEEP="Annual_plus_Bmex_only_pangenome.tab"
#OUTPUT_REMOVE="Annual_plus_Bmex_only_pangenome_removed.tmp"


#--------------------------------------------------------------

# Especies que deben tener valor = 0  (AND)

ZERO=() # core species/subgenomes and genomes

#ZERO=("Bdis" "Bsta" "BhybD" "BhybS") # Only Perennial filter

#ZERO=("Barb" "Bsyl" "BmexP" "BmexU") # Only Annual filter

#ZERO=("Barb" "Bsyl") #  Annual plus Bmex

#--------------------------------------------------------------


# Especies que deben tener valor != 0 (AND)

NONZERO=("Bsta" "Bdis" "Barb" "Bsyl" "BhybD" "BhybS" "BmexP" "BmexU") # core subgenomic

#NONZERO=("Bsta" "Bdis" "Barb" "Bsyl") # core species

#NONZERO=("Barb" "Bsyl") # Only Perennial filter

#NONZERO=("Bsta" "Bdis") # Only Annual filter or Annual plus Bmex


# Reglas OR: al menos una debe ser = 0

OR_ZERO=() # Only Perennial/Annual filter

# Reglas OR: al menos una debe ser != 0

#OR_NONZERO_GROUPS=("BmexP,BmexU") # Only Perennial filter

#OR_NONZERO_GROUPS="BhybD,BhybS" # Only Annual

#OR_NONZERO_GROUPS="BhybD,BhybS;BmexP,BmexU" # Annual plus Bmex filter OR Core species




# ============================
# PROCESAMIENTO
# ============================

# Crear cabecera de salida
head -n 1 "$INPUT" > "$OUTPUT_KEEP"
head -n 1 "$INPUT" > "$OUTPUT_REMOVE"

# Procesar con awk
awk -v ZERO="${ZERO[*]}" \
    -v NONZERO="${NONZERO[*]}" \
    -v OR_ZERO="${OR_ZERO[*]}" \
    -v OR_NONZERO_GROUPS="$OR_NONZERO_GROUPS" \
    '
BEGIN {
    # Convertir listas en arrays
    split(ZERO, zero_arr)
    split(NONZERO, nonzero_arr)
    split(OR_ZERO, or_zero_arr)
}

NR==1 {
    # Guardar cabecera y mapear columnas
    for(i=1;i<=NF;i++){
        header[i]=$i
        col[$i]=i
    }
    next
}

{
    keep=1

    # Reglas AND: valor = 0
    for(z in zero_arr){
        sp = zero_arr[z]
        if($col[sp] != 0){
            keep=0
        }
    }

    # Reglas AND: valor != 0
    for(n in nonzero_arr){
        sp = nonzero_arr[n]
        if($col[sp] == 0){
            keep=0
        }
    }

    # Reglas OR: al menos una = 0
    if(length(or_zero_arr) > 0){
        ok_or_zero=0
        for(o in or_zero_arr){
            sp = or_zero_arr[o]
            if($col[sp] == 0){
                ok_or_zero=1
            }
        }
        if(ok_or_zero==0){
            keep=0
        }
    }

# Reglas OR por grupos: cada grupo debe cumplir "al menos una != 0"

if (OR_NONZERO_GROUPS != "") {

    # Dividir los grupos por ";"
    split(OR_NONZERO_GROUPS, group_list, ";")

    # Cada elemento de group_list es un grupo separado por comas
    for (g in group_list) {

        # Dividir especies dentro de cada grupo por ","
        split(group_list[g], species_group, ",")

        ok_group = 0

        # Evaluar el grupo: al menos una != 0
        for (s in species_group) {
            sp = species_group[s]
            if ($col[sp] != 0) {
                ok_group = 1
            }
        }

        # Si un grupo no se cumple → descartar fila
        if (ok_group == 0) {
            keep = 0
        }
    }
}


    # Escribir en el fichero correspondiente
    if(keep==1){
        print $0 >> "'"$OUTPUT_KEEP"'"
    } else {
        print $0 >> "'"$OUTPUT_REMOVE"'"
    }
}
' "$INPUT"

