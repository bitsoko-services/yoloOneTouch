PRETRAINED_CHECKPOINT_DIR=tmp/checkpoints

OUTPUT_DIR=output
DATA_DIR=data
CAPTIONS_DIR="${DATA_DIR}/captions"
IMG_TRAIN_DIR="${DATA_DIR}/val"
IMG_VAL_DIR="${DATA_DIR}/val"


# Where the training (fine-tuned) checkpoint and logs will be saved to.
TRAIN_DIR=models/inception_v3

apt-get install wget

# Where the dataset is saved to.
DATASET_DIR=output/dataset

# Download the pre-trained checkpoint.
if [ ! -d "$PRETRAINED_CHECKPOINT_DIR" ]; then
  mkdir ${PRETRAINED_CHECKPOINT_DIR}
fi
if [ ! -f ${PRETRAINED_CHECKPOINT_DIR}/inception_v3.ckpt ]; then
  wget http://download.tensorflow.org/models/inception_v3_2016_08_28.tar.gz
  tar -xvf inception_v3_2016_08_28.tar.gz
  mv inception_v3.ckpt ${PRETRAINED_CHECKPOINT_DIR}/inception_v3.ckpt
  rm inception_v3_2016_08_28.tar.gz
fi


#prepare data

python prepro.py --train_image_dir="${IMG_TRAIN_DIR}"  --val_image_dir="${IMG_VAL_DIR}"  --train_captions_file="${CAPTIONS_DIR}/val.json" --val_captions_file="${CAPTIONS_DIR}/val.json" --output_dir="${OUTPUT_DIR}/tf" --word_counts_output_file="${OUTPUT_DIR}/word_counts.txt" 

python train.py \
  --input_file_pattern="${MSCOCO_DIR}/tf/val-?????-of-00256" \
  --inception_checkpoint_file="${INCEPTION_CHECKPOINT}" \
  --train_dir="${OUTPUT_DIR}/tf/val" \
  --train_inception=false \
  --number_of_steps=1000000

