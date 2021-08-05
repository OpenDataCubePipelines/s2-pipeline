#!/usr/bin/env python
# coding=utf-8

import pathlib
from itertools import chain

from setuptools import setup, find_packages


HERE = pathlib.Path(__file__).parent

README = (HERE / "README.md").read_text()

setup(
    name="s2-pipeline",
    description="Pipeline for S2 yaml generation and ARD processing.",
    long_description=README,
    long_description_content_type="text/markdown",
    author="Open Data Cube",
    #version=versioneer.get_version(), # currently not set up to work
    version="0.0.1",
    packages=find_packages(exclude=("tests", "tests.*", "module")),
    package_data={"": ["*.json", "*.yaml"]},
    license="Apache Software License 2.0",
    classifiers=[
        "License :: OSI Approved :: Apache Software License",
        "Programming Language :: Python :: 3",
        "Programming Language :: Python :: 3.6",
        "Programming Language :: Python :: 3.7",
        "Operating System :: OS Independent",
    ],
    url="https://github.com/OpenDataCubePipelines/s2-pipeline",
    install_requires=[
        "click",
    #    "eo-datasets", # Haven't set this up in NCI. NCI uses the module system
    ],
    entry_points="""
        [console_scripts]
        eo3-validate=eodatasets3.validate:run
        eo3-prepare=eodatasets3.scripts.prepare:run
        eo3-recompress-tar=eodatasets3.scripts.recompress:main
        eo3-package-wagl=eodatasets3.scripts.packagewagl:run
        eo3-to-stac=eodatasets3.scripts.tostac:run
    """,
)
