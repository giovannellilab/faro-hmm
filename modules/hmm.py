import re

from io import StringIO

import pandas as pd


def get_hits(filepath: str, sep: str = "$") -> pd.DataFrame:

    hmmer_colnames = [
        "target_name",
        "target_accession",
        "query_name",
        "query_accession",
        "e_value_full_seq",
        "score_full_seq",
        "bias_full_seq",
        "e_value_best_dom",
        "score_best_dom",
        "bias_best_dom",
        "exp",
        "reg",
        "clu",
        "ov",
        "env",
        "dom",
        "rep",
        "inc",
        "description_of_target"
    ]

    with open(filepath, mode="r") as handle:
        hits = handle.readlines()

        # Remove comment lines
        hits = [line for line in hits if not line.startswith("#")]

        # Remove whitespaces in description of target column
        hits = [re.sub("#\\s.*\\sID", "ID", line) for line in hits]

        # Replace multiple whitespaces by separator
        hits = [re.sub("\\s+", sep, line) for line in hits]

        # Remove trailing separator
        hits = [line.rstrip(sep) for line in hits]

        # Concatenate by new line character
        hits = "\n".join(hits)

    return pd.read_csv(
        StringIO(hits),
        names=hmmer_colnames,
        sep=sep
    )
