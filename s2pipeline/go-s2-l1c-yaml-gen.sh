#!/bin/bash

module use /g/data/v10/public/modules/modulefiles

module load dea

./s2-l1c-yaml-gen --dry-run --s2-aoi Australian_tile_list_optimised.txt
