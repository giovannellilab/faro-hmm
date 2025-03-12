import os

import glob

import argparse

import pandas as pd


def process_results(input_dir: str) -> pd.DataFrame:

    results_df = []

    glob_pattern = f"{input_dir}/**/geomosaic/**/funprof/ko_profiles.csv"

    for filename in glob.glob(glob_pattern, recursive=True):
        sample_id = os.path.basename(
            os.path.dirname(filename.split("funprof")[0])
        )
        exp_id = os.path.basename(
            os.path.dirname(filename.split("geomosaic")[0])
        )

        print(f"[+] Processing {exp_id}-{sample_id}")

        sample_df = pd.read_csv(filename)

        # Assign sample and campaign IDs
        sample_df["sample_id"] = sample_id
        sample_df["exp_id"] = exp_id

        # Sort columns
        sample_df = sample_df[
            ["exp_id", "sample_id"] + \
            [
                col for col in sample_df.columns
                if col not in ["exp_id", "sample_id"]
            ]
        ]

        # Append to final dataframe
        results_df.append(sample_df)

    return pd.concat(results_df)


if __name__ == "__main__":

    parser = argparse.ArgumentParser("process_geomosaic_kofam")
    parser.add_argument(
        "-i", "--input_dir",
        help="Top level Geomosaic directory containing a folder per campaign.",
        type=str
    )
    parser.add_argument(
        "-o", "--out_file",
        help="Ouput path for the concatenated results.",
        type=str
    )
    args = parser.parse_args()

    results_df = process_results(args.input_dir)

    results_df.to_csv(
        args.out_file,
        index=False
    )
