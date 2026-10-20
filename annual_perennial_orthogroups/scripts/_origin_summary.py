#!/usr/bin/env python3

import pandas as pd

FILES = [
    "05_annual_origin_nodes.tsv",
    "05_perennial_origin_nodes.tsv"
]

for infile in FILES:

    print("\n")
    print("="*60)
    print(infile)
    print("="*60)

    df = pd.read_csv(infile, sep="\t")

    summary = df["Origin_Node"].value_counts()

    print(summary)

    summary.to_csv(
        infile.replace(".tsv",
        "_origin_counts.tsv"),
        sep="\t"
    )
