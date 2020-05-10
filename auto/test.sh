#!/bin/bash

source completion.sh

echo $(autocomplete_option "--no-argument1" "")
echo $(autocomplete_option "--no-argument2" "")
echo $(autocomplete_option "--no-argument2" "--argument1" "")

echo $(autocomplete_argument2_arg)
