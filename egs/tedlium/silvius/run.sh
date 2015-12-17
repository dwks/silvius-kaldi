#!/bin/bash
. cmd.sh
. path.sh

corpus=corpus.txt
. utils/parse_options.sh # accept options

pretrained=http://kaldi-asr.org/downloads/build/9/trunk/egs/tedlium/s5/archive.tar.gz

if [ ! -f archive.tar.gz ]; then
	echo "Download pretrained model..."
	wget $pretrained
fi
if [ ! -d archive ]; then
	mkdir archive && tar xf archive.tar.gz -C archive
fi

if [ ! -d data/lang_fake ]; then
	mkdir -p data
	cp -ar ./archive/data/lang data/lang_fake
fi
if [ ! -d exp/tri_fake ]; then
	mkdir -p exp/tri_fake
	cp ./archive/exp/nnet2_online/nnet_ms_sp_online/tree exp/tri_fake
	cp ./archive/exp/nnet2_online/nnet_ms_sp_online/final.mdl exp/tri_fake
fi

# download pretrained English ARPA LM
mkdir -p db
local/download_data.sh || exit 1

# created mixed ARPA LM
./mix-lm.sh corpus.txt || exit 1

# convert LM -> G.fst
local/prepare_lm.sh || exit 1

# convert G.fst -> HCLG.fst
./mix-hclg.sh graph || exit 1

# copy files into new location
mkdir -p model
for n in $(seq 1 1000); do
	if [ ! -d "model/$n" ]; then
		out=model/$n
		echo "Copying data into $out"
		cp -ar ./archive/exp/nnet2_online/nnet_ms_sp_online $out
		cp $corpus $out
		cp db/mixed.lm.gz $out
		cp data/lang_fake_G/G.fst $out
		cp exp/tri_fake/graph/HCLG.fst $out
		break
	fi
done
