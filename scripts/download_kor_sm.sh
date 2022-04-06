#!/bin/bash
mkdir -p kor
cd kor

url=https://raw.githubusercontent.com/haven-jeon/ko_en_neural_machine_translation/master/korean_parallel_corpora/korean-english-v1/korean-english-park
splits=(train dev test)
langs=(en ko)


#download datasets
for split in "${splits[@]}"; do
    for lang in "${langs[@]}"; do
      wget $url.$split.$lang
    done
done

#change data name simply
orig_name=korean-english-park
for split in "${splits[@]}"; do
    for lang in "${langs[@]}"; do
      mv $orig_name.$split.$lang $split.$lang
    done
done

mv dev.en valid.en
mv dev.ko valid.ko