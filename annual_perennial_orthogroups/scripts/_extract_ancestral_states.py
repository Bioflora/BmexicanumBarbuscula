#!/usr/bin/env python3

import pandas as pd

FILES = [
    ("output_count_ANNUALS_ONLY_families_parsimony.tab",
     "annuals_ancestral_states.tsv"),

    ("output_count_PERENNIALS_ONLY_families_parsimony.tab",
     "perennials_ancestral_states.tsv")
]

nodes = [
    "8:n",
    "9:n",
    "10:n",
    "11:n",
    "12:n",
    "13:n",
    "14:n"
]

for infile, outfile in FILES:

    df = pd.read_csv(infile, sep="\t")

    cols = ["Family"] + nodes

    out = df[cols]

    out.to_csv(outfile,
               sep="\t",
               index=False)

    print(outfile)
