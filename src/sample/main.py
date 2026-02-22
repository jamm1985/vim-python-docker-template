"""Main template."""

import numpy as np


def get_sample(k: int) -> list[float]:
    """Example of random sample.

    Args:
        k: how much samples to get

    Returns:
        list of sample of size k
    """
    rng = np.random.default_rng(seed=42)
    floats = rng.random(k)
    return floats.tolist()


def run(k: int) -> list[float]:
    """Example of run.

    Args:
        k: samples to get

    Returns:
        list samples of size k
    """
    return get_sample(k)
