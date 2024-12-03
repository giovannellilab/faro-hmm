from itertools import product

import numpy as np


def get_redox_metabolic_index(
    donors: list[str],
    acceptors: list[str]
) -> float:
    return np.log10(len(set(donors)) * len(set(acceptors)))


def get_metal_plasticity_index(
    donor_metals: list[str],
    acceptor_metals: list[str]
) ->float:
    return list(product(donor_metals, acceptor_metals))
