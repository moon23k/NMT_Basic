#!/bin/bash
mkdir -p data
cd data



while getopts d:t: flag; do
    case "${flag}" in
        d) dataset=${OPTARG};;
        t) tokenizer=${OPTARG};;
    esac
done




splits=(train valid test)
langs=(en de)



#Download datasets
bash ../scripts/download_datasets.sh
bash ../scripts/download_mecab.sh
bash ../scripts/pretokenize.sh



if [ $dataset -eq kor ]; then
    bash ../scripts/download_kor.sh
    bash ../scripts/download_mecab.sh
    bash ../utils/mecab_tok.py


elif [ $dataset -eq wmt_sm ]; then
    bash ../scripts/download_wmt_sm.sh

    #Pre Tokenize with sacremoses
    python3 -m pip install -U sacremoses
    for split in "${splits[@]}"; do
        for lang in "${langs[@]}"; do
            mkdir -p ${dataset}/tok
            sacremoses -l ${lang} -j 8 tokenize < $wmt_sm/raw/${split}.${lang} > $wmt_sm/tok/${split}.${lang}
        done
    done
fi






#get sentencepiece
git clone https://github.com/google/sentencepiece.git
cd sentencepiece
mkdir build
cd build
cmake ..
make -j $(nproc)
sudo make install
sudo ldconfig
cd ../../



#concat all files into one file to build vocab
cat ${dataset}/tok/* >> ${dataset}/concat.txt



#Build Vocab
for dataset in "${datasets[@]}"; do
    mkdir -p ${dataset}/vocab
    for tokenizer in "${tokenizers[@]}"; do
        bash ../scripts/build_vocab.sh -i ${dataset}/concat.txt -p ${dataset}/vocab/${tokenizer} -t ${tokenizer}
    done
    rm ${dataset}/concat.txt
done



#tokens to ids
for dataset in "${datasets[@]}"; do
    mkdir -p ${dataset}/ids
    for split in "${splits[@]}"; do
        for tokenizer in "${tokenizers[@]}"; do
            for lang in "${langs[@]}"; do
                mkdir -p ${dataset}/ids/${tokenizer}
                spm_encode --model=${dataset}/vocab/${tokenizer}.model --extra_options=bos:eos \
                --output_format=id < ${dataset}/tok/${split}.${lang} > ${dataset}/ids/${tokenizer}/${split}.${lang}
            done
        done
    done
done


#remove sentencepiece
rm -r sentencepiece


