#!/bin/bash

wget --no-check-certificate 'https://docs.google.com/uc?export=download&id=11ln6BiC4l1kk-vCvKGgQngSzoDOai4iP' -O wmt_sm.tar.gz
tar -zxvf wmt_sm.tar.gz
rm *gz

cd wmt_sm
mkdir -p raw
mv train* valid* test* raw/
cd ../../