#!/bin/bash

. cmd.sh
. path.sh

commands=db/commands.lm
output=db/mixed.lm
lambda=0.2

# count words in corpus
ngram-count -lm $commands -text $@

# mix language models
if [ ! -f db/cantab-TEDLIUM/cantab-TEDLIUM-pruned.lm3 ]; then
	gunzip -k db/cantab-TEDLIUM/cantab-TEDLIUM-pruned.lm3.gz
fi
ngram -lm db/cantab-TEDLIUM/cantab-TEDLIUM-pruned.lm3 -mix-lm $commands -lambda $lambda -write-lm $output

# compress, this is what the prepare_lm.sh script wants
rm -f $output.gz
gzip -k $output
