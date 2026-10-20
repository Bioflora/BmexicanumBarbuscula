#!/usr/bin/env python3

import pandas as pd

FILES = [
    ("output_count_ANNUALS_ONLY_families_parsimony.tab",
     "annual_classification.tsv"),

    ("output_count_PERENNIALS_ONLY_families_parsimony.tab",
     "perennial_classification.tsv")
]

for infile, outfile in FILES:

    df = pd.read_csv(infile, sep="\t")

    classes = []

    for _, row in df.iterrows():

        root = row["14:n"]

        gains = row["Gains"]

        losses = row["Losses"]

        expansions = row["Expansions"]

        if root == 0 and gains > 0:

            c = "Recent_gain"

        elif root > 0 and losses > 0:

            c = "Ancestral_with_losses"

        elif expansions > 0:

            c = "Expansion"

        else:

            c = "Other"

        classes.append(c)

    df["Evolutionary_class"] = classes

    df.to_csv(outfile,
              sep="\t",
              index=False)

    print(outfile)
