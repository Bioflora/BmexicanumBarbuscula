#!/usr/bin/env python3

import pandas as pd

FILES = [
    ("03_annual_classification.tsv",
     "05_annual_origin_nodes.tsv"),

    ("03_perennial_classification.tsv",
     "05_perennial_origin_nodes.tsv")
]

# orden desde raíz a nodos más recientes
nodes = [
    "14:n",
    "13:n",
    "12:n",
    "10:n",
    "11:n",
    "9:n",
    "8:n"
]

for infile, outfile in FILES:

    df = pd.read_csv(infile, sep="\t")

    origins = []

    for _, row in df.iterrows():

        origin = "Terminal_only"

        for node in nodes:

            try:

                if float(row[node]) > 0:

                    origin = node.replace(":n","")

                    break

            except:

                pass

        origins.append(origin)

    df["Origin_Node"] = origins

    df.to_csv(outfile,
              sep="\t",
              index=False)

    print(outfile)

