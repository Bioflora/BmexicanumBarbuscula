#!/usr/bin/env python3

import pandas as pd

FILES = [
    "output_count_ANNUALS_ONLY_families_parsimony.tab",
    "output_count_PERENNIALS_ONLY_families_parsimony.tab"
]

for f in FILES:

    df = pd.read_csv(f, sep="\t")

    print("\n==========================")
    print(f)
    print("==========================")

    print("Families:", len(df))

    print("Gain events:", (df["Gains"] > 0).sum())
    print("Loss events:", (df["Losses"] > 0).sum())

    print("Expansion events:", (df["Expansions"] > 0).sum())
    print("Contraction events:", (df["Contractions"] > 0).sum())

    print("\nMeans")

    print("Gains:", df["Gains"].mean())
    print("Losses:", df["Losses"].mean())
    print("Expansions:", df["Expansions"].mean())
    print("Contractions:", df["Contractions"].mean())
