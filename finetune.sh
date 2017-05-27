#!/bin/bash
#
# This script performs the following operations:
# 1. Downloads the Flowers dataset
# 2. Fine-tunes an InceptionV4 model on the Flowers training set.
# 3. Evaluates the model on the Flowers validation set.
#
# Usage:
# cd slim
# ./slim/scripts/finetune_inceptionv4_on_flowers.sh
set -e

# Where the pre-trained InceptionV4 checkpoint is saved to.
PRETRAINED_CHECKPOINT_DIR=checkpoints
FINETUNED_CHECKPOINT_DIR=tmp/checkpoints
RAWIMG=tmp/rawimg
FINETUNED_GRAPH_DIR=ConvNets

# Where the training (fine-tuned) checkpoint and logs will be saved to.
TRAIN_DIR=tmp/products-models/inception_v4

# Where the dataset is saved to.
DATASET_DIR=Dataset/items


# Remove temporary files
rm -fr tmp
mkdir tmp
mkdir ${FINETUNED_CHECKPOINT_DIR}
mkdir ${RAWIMG}

# Download the pre-trained checkpoint.
if [ ! -d "$PRETRAINED_CHECKPOINT_DIR" ]; then
  mkdir ${PRETRAINED_CHECKPOINT_DIR}
fi
if [ ! -f ${PRETRAINED_CHECKPOINT_DIR}/inception_v4.ckpt ]; then
  cd tmp
  wget http://download.tensorflow.org/models/inception_v4_2016_09_09.tar.gz
  tar -xvf inception_v4_2016_09_09.tar.gz
  mv inception_v4.ckpt ../${PRETRAINED_CHECKPOINT_DIR}/inception_v4.ckpt
  rm inception_v4_2016_09_09.tar.gz
  cd ../
fi
if [ ! -f ${FINETUNED_GRAPH_DIR}/inception_v4.pb ]; then
  

# Download the dataset
python download_and_convert_data.py \
  --dataset_name=products \
  --dataset_dir=${DATASET_DIR}


# Fine-tune only the new layers for 10000 steps.
python train_image_classifier.py \
  --train_dir=${TRAIN_DIR} \
  --dataset_name=products \
  --dataset_split_name=train \
  --dataset_dir=${DATASET_DIR} \
  --model_name=inception_v4 \
  --checkpoint_path=${PRETRAINED_CHECKPOINT_DIR}/inception_v4.ckpt \
  --checkpoint_exclude_scopes=InceptionV4/Logits,InceptionV4/AuxLogits \
  --trainable_scopes=InceptionV4/Logits,InceptionV4/AuxLogits \
  --max_number_of_steps=1 \
  --batch_size=10 \
  --learning_rate=0.01 \
  --learning_rate_decay_type=fixed \
  --save_interval_secs=60 \
  --save_summaries_secs=60 \
  --log_every_n_steps=100 \
  --optimizer=rmsprop \
  --weight_decay=0.00004

# Run evaluation.
python eval_image_classifier.py \
  --checkpoint_path=${TRAIN_DIR} \
  --eval_dir=${TRAIN_DIR} \
  --dataset_name=products \
  --dataset_split_name=validation \
  --dataset_dir=${DATASET_DIR} \
  --model_name=inception_v4

# Fine-tune all the new layers for 50 steps.
python train_image_classifier.py \
  --train_dir=${TRAIN_DIR}/all \
  --dataset_name=products \
  --dataset_split_name=train \
  --dataset_dir=${DATASET_DIR} \
  --model_name=inception_v4 \
  --checkpoint_path=${TRAIN_DIR} \
  --max_number_of_steps=1 \
  --batch_size=2 \
  --learning_rate=0.0001 \
  --learning_rate_decay_type=fixed \
  --save_interval_secs=60 \
  --save_summaries_secs=60 \
  --log_every_n_steps=10 \
  --optimizer=rmsprop \
  --weight_decay=0.00004

# Run evaluation
python eval_image_classifier.py \
  --checkpoint_path=${TRAIN_DIR}/all \
  --eval_dir=${TRAIN_DIR}/all \
  --dataset_name=products \
  --dataset_split_name=validation \
  --dataset_dir=${DATASET_DIR} \
  --model_name=inception_v4

# Move tuned graph to caption trainer
python preprocessing/freeze_graph.py \
--input_graph=tmp/products-models/inception_v4/all/graph.pbtxt \
--input_checkpoint=tmp/products-models/inception_v4/all/model.ckpt-0.data-00000-of-00001  \
--output_graph=${FINETUNED_GRAPH_DIR}/inception_v4.pb --output_node_names=softmax

fi


# Train the tuned model on product caption
python main.py --mode train 

# Test the Model
python main.py --mode test --image_path test.jpg


