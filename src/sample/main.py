from numpy.random import random


def run():
    sample = random(size=100)
    print("Sample mean is ", sample.mean())
