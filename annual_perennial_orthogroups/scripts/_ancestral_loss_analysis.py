#!/usr/bin/env python3

import pandas as pd

FILES = [
    ("05_annual_origin_nodes.tsv",
     "09_annual_ancestral_losses.tsv"),

    ("05_perennial_origin_nodes.tsv",
     "09_perennial_ancestral_losses.tsv")
]

for infile, outfile in FILES:

    df = pd.read_csv(infile, sep="\t")

    ancestral = df[
        (df["Origin_Node"].isin([14,13,12]))
    ]

    ancestral = ancestral[
        ancestral["Losses"] > 0
    ]

    ancestral.to_csv(
        outfile,
        sep="\t",
        index=False
    )

    print(
        infile,
        "ancestral+losses:",
        len(ancestral)
    )
