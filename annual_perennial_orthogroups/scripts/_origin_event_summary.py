#!/usr/bin/env python3

import pandas as pd

FILES = [
    ("05_annual_origin_nodes.tsv",
     "08_annual_origin_event_summary.tsv"),

    ("05_perennial_origin_nodes.tsv",
     "08_perennial_origin_event_summary.tsv")
]

for infile, outfile in FILES:

    df = pd.read_csv(infile, sep="\t")

    summary = []

    for node in sorted(df["Origin_Node"].unique()):

        sub = df[df["Origin_Node"] == node]

        summary.append({

            "Origin_Node": node,

            "Families": len(sub),

            "Mean_Gains": sub["Gains"].mean(),

            "Mean_Losses": sub["Losses"].mean(),

            "Mean_Expansions": sub["Expansions"].mean(),

            "Mean_Contractions": sub["Contractions"].mean(),

            "Families_with_Losses":
                (sub["Losses"] > 0).sum(),

            "Families_with_Gains":
                (sub["Gains"] > 0).sum(),

            "Families_with_Expansions":
                (sub["Expansions"] > 0).sum(),

            "Families_with_Contractions":
                (sub["Contractions"] > 0).sum()
        })

    pd.DataFrame(summary).to_csv(
        outfile,
        sep="\t",
        index=False
    )

    print(outfile)
