from typing import List

import os

import glob

import argparse

import pandas as pd

from Bio import SeqIO


def get_bigec_hmm_results(
    bigec_dir: str,
    selected_hmm: List[str]
) -> pd.DataFrame:

    hyd_df = []

    for filename in os.listdir(bigec_dir):
        mag_df = pd.read_table(
            os.path.join(
                bigec_dir,
                filename
            )
        )
        mag_df = mag_df[mag_df["HMM"].isin(hyd_hmm_list)]
        hyd_df.append(mag_df)

    hyd_df = pd.concat(hyd_df)

    hyd_df["sample_id"] = hyd_df["organism"].str.split("_").str[0]
    hyd_df["mag_id"] = hyd_df["organism"].apply(
        lambda row: "_".join(row.split("_")[1:])
    )
    hyd_df["orf_id"] = hyd_df["protein"].apply(
        lambda row: "_".join(row.split("_")[2:])
    )

    return hyd_df


def get_orf_sequences(
    geomosaic_dir: str,
    hmm_df: pd.DataFrame
) -> pd.DataFrame:

    base_dir = "{geomosaic_dir}/{sample_id}/mags_prodigal/{mag_id}/"

    for row_idx, row in hyd_df.iterrows():
        filepath = os.path.join(
            base_dir.format(
                geomosaic_dir=geomosaic_dir,
                sample_id=row["sample_id"],
                mag_id=row["mag_id"]
            ),
            "orf_predicted.faa"
        )

        with open(filepath) as handle:
            for record in SeqIO.parse(handle, "fasta"):
                if record.id == row["orf_id"]:
                    hyd_df.loc[row_idx, "sequence"] = str(record.seq)

    return hyd_df


if __name__ == "__main__":

    parser = argparse.ArgumentParser("process_geomosaic_kofam")
    parser.add_argument(
        "-b", "--bigec_dir",
        help="Top level Geomosaic directory containing a folder per campaign.",
        type=str
    )
    parser.add_argument(
        "-g", "--geomosaic_dir",
        help="Ouput path for the concatenated results.",
        type=str
    )
    args = parser.parse_args()

    hyd_hmm_list = [
        "fe.hmm",
        "fefe-group-a13.hmm",
        "fefe-group-a2.hmm",
        "fefe-group-a4.hmm",
        "fefe-group-b.hmm",
        "fefe-group-c1.hmm",
        "fefe-group-c2.hmm",
        "fefe-group-c3.hmm",
        "nife-group-1.hmm",
        "nife-group-2ade.hmm",
        "nife-group-2bc.hmm",
        "nife-group-3abd.hmm",
        "nife-group-3c.hmm",
        "nife-group-4a-g.hmm",
        "nife-group-4hi.hmm"
    ]

    print("[+] Retrieving hydrogenases hits")
    hmm_results_dir = os.path.join(
        args.bigec_dir,
        "hmm_results"
    )
    hyd_df = get_bigec_hmm_results(
        bigec_dir=hmm_results_dir,
        selected_hmm=hyd_hmm_list
    )

    print("[+] Retrieving hydrogenases sequences")
    hyd_df = get_orf_sequences(
        geomosaic_dir=args.geomosaic_dir,
        hmm_df=hyd_df
    )

    out_path = os.path.join(
        args.bigec_dir,
        "hydrogenases-hits.csv"
    )
    hyd_df.to_csv(
        out_path,
        index=False
    )
    print(f"[+] Saved hydrogenases information to: {out_path}")
