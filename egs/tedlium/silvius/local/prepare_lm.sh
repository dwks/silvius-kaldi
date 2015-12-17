#!/bin/bash 
#
# Copyright  2014 Nickolay V. Shmyrev 
# Apache 2.0


if [ -f path.sh ]; then . path.sh; fi

#arpa_lm=db/cantab-TEDLIUM/cantab-TEDLIUM-pruned.lm3.gz
arpa_lm=db/mixed.lm.gz
[ ! -f $arpa_lm ] && echo No such file $arpa_lm && exit 1;

source=data/lang_fake
dest=data/lang_fake_G
#dest2=${dest}_rescore

rm -rf $dest
cp -r $source $dest

# grep -v '<s> <s>' etc. is only for future-proofing this script.  Our
# LM doesn't have these "invalid combinations".  These can cause 
# determinization failures of CLG [ends up being epsilon cycles].
# Note: remove_oovs.pl takes a list of words in the LM that aren't in
# our word list.  Since our LM doesn't have any, we just give it
# /dev/null [we leave it in the script to show how you'd do it].
gunzip -c "$arpa_lm" | \
   grep -v '<s> <s>' | \
   grep -v '</s> <s>' | \
   grep -v '</s> </s>' | \
   arpa2fst - | fstprint | \
   utils/remove_oovs.pl /dev/null | \
   utils/eps2disambig.pl | utils/s2eps.pl | fstcompile --isymbols=$dest/words.txt \
     --osymbols=$dest/words.txt  --keep_isymbols=false --keep_osymbols=false | \
    fstrmepsilon | fstarcsort --sort_type=ilabel > $dest/G.fst


echo  "Checking how stochastic G is (the first of these numbers should be small):"
fstisstochastic $dest/G.fst

# silvius note: this is not really necessary
utils/validate_lang.pl $dest || exit 1;

#if [ ! -d $dest2 ]; then
#
#  big_arpa_lm=db/cantab-TEDLIUM/cantab-TEDLIUM-unpruned.lm4.gz
#  [ ! -f $big_arpa_lm ] && echo No such file $big_arpa_lm && exit 1;
#
#  utils/build_const_arpa_lm.sh $big_arpa_lm $dest $dest2 || exit 1;
#
#fi

exit 0;
