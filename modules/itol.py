import pandas as pd


def get_itol_template(
    df: pd.DataFrame,
    template_path: str
) -> str:

    # Get group name for legend
    group = df["group"].unique()[0]
    group = " ".join(group.split("-")).capitalize()

    # Get unique values for fields, colors and shapes
    df_unique = df[["field", "color", "shape"]].drop_duplicates()

    # Transform to wide format
    df_wide = df.pivot(
        index="genome_name",
        columns="field",
        values="count"
    )
    df_wide = df_wide.reset_index(drop=False).fillna(0.0)

    # Force sorting of columns
    df_unique = df_unique.sort_values("field")
    df_wide = df_wide[["genome_name"] + df_unique["field"].values.tolist()]

    # ------------------------------------------------------------------------ #

    # Add actual data
    data_lines = df_wide.to_string(
        header=False,
        index=False
    )
    data_lines = [
        line.strip().replace("  ", ",")
        for line in data_lines.split("\n")
    ]
    data_lines = "\n".join(data_lines)

    with open(template_path, mode="r") as handle:
        template = handle.read()

    # Replace fields in the template
    template = template\
        .replace(
            "$$$DATASET_LABEL$$$",
            group
        )\
        .replace(
            "$$$FIELD_LABELS$$$",
            ",".join(df_unique["field"])
        )\
        .replace(
            "$$$FIELD_COLORS$$$",
            ",".join(df_unique["color"])
        )\
        .replace(
            "$$$FIELD_SHAPES$$$",
            ",".join(df_unique["shape"])
        )\
        .replace(
            "$$$SHAPE_TYPE$$$",
            df_unique["shape"].unique()[0]
        )\
        .replace(
            "$$$ADD_DATA_HERE$$$",
            data_lines
        )

    return template
