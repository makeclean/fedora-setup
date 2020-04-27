#!/bin/bash

set -ue

./software_core.sh
./dagmc_stack.sh
./moose_stack.sh
