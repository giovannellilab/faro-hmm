import os

import shutil

import argparse

import pandas as pd


# ---------------------------------------------------------------------------- #
# USAGE:

# python scripts/process_profiles_filter.py \
#   -m data/runs/closing-circuit/gene-table-oxidoreductases.xlsx \
#   -c data/runs/carbon-fixation/ko_carbon_metab.csv \
#   -p data/profiles/ \
#   -o data/profiles/closing-circuit

# find data/profiles/closing-circuit/ \
#   -name "*.hmm" \
#   -type f \
#   -exec hmmconvert {} \; > \
#   data/profiles/pipeline.hmm

# ---------------------------------------------------------------------------- #


def get_hmm_files(name: str, dir: str) -> pd.DataFrame:
    return pd.DataFrame([
        {
            "hmm_file": name,
            "hmm_path": os.path.join(root, name)
        }
        for root, dirs, files in os.walk(dir)
        if name in files
    ])


if __name__ == "__main__":

    parser = argparse.ArgumentParser("process_profiles_filter")
    parser.add_argument(
        "-m", "--metadata_path",
        help="Metadata filepath.",
        type=str
    )
    parser.add_argument(
        "-c", "--carbon_path",
        help="Carbon fixation filepath.",
        type=str
    )
    parser.add_argument(
        "-p", "--hmm_dir",
        help="HMM directory.",
        type=str
    )
    parser.add_argument(
        "-o", "--out_dir",
        help="Output directory.",
        type=str
    )
    args = parser.parse_args()

    # ------------------------------------------------------------------------ #

    metadata_df = pd.read_excel(
        args.metadata_path,
        sheet_name="genes"
    )

    # Remove KO files from METABOLIC in favor of KOfam
    metadata_df = metadata_df[
        ~metadata_df["hmm_file"].str.contains("^K\\d{5}", na=False)
    ]

    # Read carbon fixation related ones
    carbon_df = pd.read_csv(args.carbon_path)
    carbon_df["hmm_file"] = carbon_df["ko"] + ".hmm"

    # ------------------------------------------------------------------------ #

    final_hmm_list = \
        metadata_df["hmm_file"].dropna().unique().tolist() + \
        carbon_df["hmm_file"].dropna().unique().tolist()

    final_hmm_list = list(set(final_hmm_list))

    hmm_path_df = [
        get_hmm_files(name=hmm_file, dir=args.hmm_dir)
        for hmm_file in final_hmm_list
    ]
    hmm_path_df = pd.concat(hmm_path_df)

    # Check there are no duplicates
    assert hmm_path_df["hmm_file"].value_counts().sum() == len(hmm_path_df), \
        "[ERROR] Found multiple files for the same HMM!"

    # ------------------------------------------------------------------------ #

    os.makedirs(args.out_dir, exist_ok=True)

    # Copy to output directory
    for _, row in hmm_path_df.iterrows():
        shutil.copyfile(
            row["hmm_path"],
            os.path.join(
                args.out_dir,
                row["hmm_file"]
            )
        )
