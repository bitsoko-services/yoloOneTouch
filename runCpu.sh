
#Pre
#Linux-Ubuntu-16.04
apt-get update && apt-get -y install wget git build-essential checkinstall libreadline-gplv2-dev libncursesw5-dev libssl-dev libsqlite3-dev tk-dev libgdbm-dev libc6-dev libbz2-dev
cd /usr/src
wget https://www.python.org/ftp/python/3.5.1/Python-3.5.1.tgz
tar xzf Python-3.5.1.tgz
cd Python-3.5.1 && ./configure
make altinstall
python3 -V

apt-get -y install python3-pip
pip3 install --upgrade pip


cd /tflow
#install conda
bash Miniconda3-latest-Linux-x86_64.sh -b -p /root/miniconda3

#bash Miniconda2-latest-Linux-x86_64.sh -b -p /root/miniconda2


git clone https://github.com/silicon-valley-data-science/RNN-Tutorial
cd RNN-Tutorial
echo "export RNN_TUTORIAL=${PWD}" >> ~/.profile
echo "export PYTHONPATH=${PWD}/src:${PYTHONPATH}" >> ~/.profile
source ~/.profile

#create conda
conda create --name tf-rnn python=3
source activate tf-rnn
cd $RNN_TUTORIAL
pip3 install -r requirements.txt
pip3 install --user numpy scipy matplotlib ipython jupyter pandas sympy nose python_speech_features

pip3 install --upgrade\
 https://storage.googleapis.com/tensorflow/linux/cpu/tensorflow-1.0.1-cp35-cp35m-linux_x86_64.whl --ignore-installed

cd /tflow
mkdir logs
#tensorboard --logdir=logs/
python3 $RNN_TUTORIAL/src/tests/train_framework/tf_train_ctc_test.py


