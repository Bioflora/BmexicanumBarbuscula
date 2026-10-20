#!/usr/bin/env python3

import pandas as pd

FILES = [
    ("05_annual_origin_nodes.tsv",
     "10_annual_mechanisms.tsv"),

    ("05_perennial_origin_nodes.tsv",
     "10_perennial_mechanisms.tsv")
]

for infile, outfile in FILES:

    df = pd.read_csv(infile, sep="\t")

    mechanisms = []

    for _, row in df.iterrows():

        origin = row["Origin_Node"]

        losses = row["Losses"]

        expansions = row["Expansions"]

        if origin in [14,13,12] and losses > 0:

            mechanism = "Ancestral_retention_plus_losses"

        elif origin in [11,10,9,8]:

            mechanism = "Derived_gain"

        else:

            mechanism = "Unresolved"

        if expansions > 0:

            mechanism += "_with_expansion"

        mechanisms.append(mechanism)

    df["Mechanism"] = mechanisms

    df.to_csv(outfile,
              sep="\t",
              index=False)

    print(outfile)

    print(
        df["Mechanism"]
        .value_counts()
    )
