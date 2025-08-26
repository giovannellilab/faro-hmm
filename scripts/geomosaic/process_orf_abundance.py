import os
import glob

import argparse

import pandas as pd


def get_rpkm(
    count: int,
    gene_length: int,
    total_count: int
) -> float:
    return count / ((gene_length / 1000) * (total_count / 1e6))


def get_cpm(
    count: int,
    total_count: int
) -> float:
    return 1e6 * count / total_count


def process_results(input_dir: str) -> pd.DataFrame:

    results_df = []

    glob_pattern = f"{input_dir}/**/mags_orf_abundance/mag_*/*_orf_depth.tsv"

    for filename in glob.glob(glob_pattern, recursive=True):
        sample_id = os.path.basename(
            os.path.dirname(filename.split("orf_abundance")[0])
        )

        counts_df = pd.read_table(filename)

        # Assign ID columns
        counts_df["sample_id"] = sample_id

        if "mag_" in filename:
            counts_df["mag_id"] = os.path.basename(
                os.path.dirname(filename)
            )

        # Append to final dataframe
        results_df.append(counts_df)

    # Concatenate all MAG results
    results_df = pd.concat(results_df)

    # Normalize raw read counts
    results_df["readcountmapped"] = results_df["readcount"].sum()
    results_df["orf_length"] = (results_df["end"] - results_df["start"])

    for suffix in ("sample", "mapped"):
        results_df[f"rpkm_{suffix}"] = results_df.apply(
            lambda row: get_rpkm(
                count=row["readcount"],
                gene_length=row["orf_length"],
                total_count=row[f"readcount{suffix}"]
            ),
            axis=1
        )
        results_df[f"cpm_{suffix}"] = results_df.apply(
            lambda row: get_cpm(
                count=row["readcount"],
                total_count=row[f"readcount{suffix}"]
            ),
            axis=1
        )

    out_path = os.path.join(
        os.path.dirname(filename.split("mags_orf_abundance")[0]),
        "mags_orf_abundance",
        "mags_orf_depth.tsv"
    )
    results_df.to_csv(
        out_path,
        index=False
    )

    return None


if __name__ == "__main__":

    parser = argparse.ArgumentParser("process_geomosaic_kofam")
    parser.add_argument(
        "-i", "--input_dir",
        help="Sample directory containing the mags_orf_abundance folder.",
        type=str
    )
    args = parser.parse_args()

    process_results(args.input_dir)

    print("[FINISHED] Normalization of raw read counts.")
