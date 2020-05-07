#!/bin/bash

source completion.sh

echo $(autocompletion_generate_options "--no-argument1" "")
echo $(autocompletion_generate_options "--no-argument2" "")
echo $(autocompletion_generate_options "--no-argument2" "--argument1" "")
