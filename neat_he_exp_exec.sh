#!/bin/bash


git clone https://github.com/perhurt/neat_he.git tmp
mv tmp/* .
rmdir tmp
/bin/bash neat_he_exp_exec.sh

exit 0
