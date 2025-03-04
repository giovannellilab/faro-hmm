import os

import glob

import argparse

import pandas as pd


def process_results(
    input_dir: str,
    subfolder: str,
    object_name: str
) -> pd.DataFrame:

    final_df = []

    glob_pattern = f"{input_dir}/**/{subfolder}/**/result.txt"

    for filename in glob.glob(glob_pattern, recursive=True):
        sample_id = os.path.basename(
            os.path.dirname(filename.split(subfolder)[0])
        )

        kofam_df = pd.read_table(filename)

        # Drop empty line
        kofam_df = kofam_df.iloc[1:]

        # Get hits that pass the threshold
        kofam_df = kofam_df.dropna(subset=["#"])

        # Assign sample and MAG IDs
        kofam_df["sample"] = sample_id
        kofam_df[object_name] = kofam_df["gene name"].apply(
            lambda row: "_".join(row.split("_")[:2])
        )
        kofam_df = kofam_df.rename(columns={"gene name": "gene_name"})

        # Append to final dataframe
        final_df.append(kofam_df)

    final_df = pd.concat(final_df)

    # Sort columns
    id_cols = [
        "sample",
        object_name
    ]
    final_df = final_df[
        id_cols + [col for col in kofam_df.columns if col not in id_cols]
    ]

    output_path = os.path.join(
        input_dir,
        f"geomosaic-{subfolder}.csv"
    )
    final_df.to_csv(
        output_path,
        index=False
    )
    print(f"[+] Results from {subfolder} written to {output_path}")

    return final_df


def get_counts_orf(
    input_dir: str,
    subfolder: str,
    object_name: str,
    final_df: pd.DataFrame
) -> None:
    final_df_counts = final_df\
        .value_counts(["sample", object_name, "gene_name"])\
        .reset_index()

    output_path = os.path.join(
        input_dir,
        f"geomosaic-{subfolder}-counts-by-orf.csv"
    )
    final_df_counts.to_csv(
        output_path,
        index=False
    )
    print(f"[+] Counts per ORF written to {output_path}")

    return None


def get_counts_wide(
    input_dir: str,
    subfolder: str,
    object_name: str,
    final_df: pd.DataFrame
) -> None:
    for group_vars in (("sample",), ("sample", object_name)):

        final_df_group = final_df\
            .groupby(["KO", *group_vars], as_index=False)\
            .size()\
            .rename(columns={"size": "count"})

        final_df_group_wide = final_df_group.pivot(
            index=group_vars,
            columns="KO",
            values="count"
        )
        final_df_group_wide = final_df_group_wide.reset_index()
        final_df_group_wide = final_df_group_wide.fillna(0.0)

        vars_str = '-'.join(group_vars)

        output_path = os.path.join(
            input_dir,
            f"geomosaic-{subfolder}-by-{vars_str}-long.csv"
        )
        final_df_group.to_csv(
            output_path,
            index=False
        )
        print(f"[+] Counts per {vars_str} written to {output_path} (long)")

        output_path = os.path.join(
            input_dir,
            f"geomosaic-{subfolder}-by-{vars_str}-wide.csv"
        )
        final_df_group_wide.to_csv(
            output_path,
            index=False
        )
        print(f"[+] Counts per {vars_str} written to {output_path} (wide)")

    return None


if __name__ == "__main__":

    parser = argparse.ArgumentParser("process_geomosaic_kofam")
    parser.add_argument(
        "-i", "--input_dir",
        help="Top level Geomosaic directory containing a folder per sample.",
        type=str
    )
    parser.add_argument(
        "-l", "--level",
        help="Level at which KOfam search was performed (assembly or mags).",
        type=str,
        choices=["assembly", "mags"]
    )
    args = parser.parse_args()

    # ------------------------------------------------------------------------ #

    subfolder = None
    object_name = None

    if args.level == "assembly":
        subfolder = "kofam_scan"
        object_name = "contig"
    elif args.level == "mags":
        subfolder = "mags_kofam_scan"
        object_name = "mag"
    else:
        raise NotImplementedError

    # ------------------------------------------------------------------------ #

    final_df = process_results(
        input_dir=args.input_dir,
        subfolder=subfolder,
        object_name=object_name
    )
    get_counts_orf(
        input_dir=args.input_dir,
        subfolder=subfolder,
        object_name=object_name,
        final_df=final_df
    )
    get_counts_wide(
        input_dir=args.input_dir,
        subfolder=subfolder,
        object_name=object_name,
        final_df=final_df
    )

    print(f"[SUCCESS] KOfam {subfolder} results processed!")
