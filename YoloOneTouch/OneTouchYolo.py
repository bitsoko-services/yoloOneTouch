
"""
           YoloOneTouch - Tested on Ubuntu 16.04LTS, Python3  - @Bitsoko
                                      ----    .    _ _ _
                                      |   |   |    |
                                      |   |   |    |_ _
                                      |---|   |    |
                                      |   |   |    |_ _ _
                                      ----
           1. Data preparation to yolo format
           2.Yolo config files auto editing and generation (yolo cfg, obj.data , obj.names)
           3.Automatic training launch
           4.Automatic classes determination
           5.Automatoc pre-trained weights download if not present
           6.Yolo installation check

           #YoloOneTouch, lets you focus on the data ONLY using labelImg! It does the rest!

           DEPENDS ON:
           -yolo cfg starter file - will be modified automatically - already provided in this repo
           -Data set folder as generated by labelimg - https://github.com/tzutalin/labelImg
           -require darknet yolo model installation
           		-$git clone https://github.com/pjreddie/darknet
           		-$cd darknet
           		-$make
           		$pwd

"""

darknet_path = '/home/bitsoko/darknet'
image_path = 'images'
# Directory where the data will reside, relative to './darknet'
#also serves as your custom model name
output_path = 'bitsoko_model'
#test size percentage
percentage_test = 10
#your gpus, i have three
gpus = '0,1,2'
#should be in darknet folder
weights ='darknet19_448.conv.23'
weights_url = "https://pjreddie.com/media/files/darknet19_448.conv.23"
yolo_cfg = 'yolo-obj.cfg'


import os
import glob
import xml.etree.ElementTree as ET
from PIL import Image
import shutil
import sys
import urllib.request

def yolo_model_installed():
	if not os.path.exists(darknet_path):
		print('Yolo Darknet not installed!')
		sys.exit()

def weights_check_or_download():
	if not os.path.exists(darknet_path+'/'+weights):
		print('Weights not found,Downloading...')
		file_name = weights_url.split('/')[-1]
		u = urllib.request.urlopen(weights_url)
		f = open(darknet_path+'/'+file_name, 'wb')
		file_size = int(u.headers["Content-Length"])
		print ("Downloading: %s MBs: %s" % (file_name, file_size/1000000))
		file_size_dl = 0
		block_sz = 8192
		while True:
		    buffer = u.read(block_sz)
		    if not buffer:
		        break
		    file_size_dl += len(buffer)
		    f.write(buffer)
		    status = r"%s  [%3.2f%%]" % ('Downloading...', file_size_dl * 100. / file_size)
		    status = status + chr(8)*(len(status)+1)
		    sys.stdout.write(status)
		    sys.stdout.flush()

		f.close()

def confirm_images_path():
	if not os.path.exists(image_path):
	    print('Images directory not found!')
	    sys.exit()

def confirm_output_path():
	if not os.path.exists(output_path):
	    os.makedirs(output_path)

def xml_reader(path):
    xml_list = []
    for xml_file in glob.glob(path + '/*.xml'):
        tree = ET.parse(xml_file)
        root = tree.getroot()
        for member in root.findall('object'):
            value = (root.find('filename').text,
                     int(root.find('size')[0].text),
                     int(root.find('size')[1].text),
                     member[0].text,
                     int(member[4][0].text),
                     int(member[4][1].text),
                     int(member[4][2].text),
                     int(member[4][3].text)
                     )
            xml_list.append(value)
    return xml_list

#yolo bboxes format
def convert(size, box):
    dw = 1./size[0]
    dh = 1./size[1]
    x = (box[0] + box[1])/2.0
    y = (box[2] + box[3])/2.0
    w = box[1] - box[0]
    h = box[3] - box[2]
    x = x*dw
    w = w*dw
    y = y*dh
    h = h*dh
    return (x,y,w,h)

def save_data(filename,cls_id,bb):
	with open(output_path+'/'+filename+'.txt','a') as f:
		f.write(str(cls_id) + " " + " ".join([str(a) for a in bb]) + '\n')

def unique_labels(xml_list):
	unique_classes = []
	for line in xml_list:
		if line[3] not in unique_classes and line[3] != 'class':
			unique_classes.append(line[3])
	return unique_classes

def to_yolo(xml_list,unique_classes):
	for line in xml_list:
		filename,width,height,_class,xmin,ymin,xmax,ymax = line[0],line[1],line[2],line[3],line[4],line[5],line[6],line[7]
		print(filename,width,height,_class,xmin,ymin,xmax,ymax)
		shutil.copy(image_path+'/'+filename, output_path+'/')
		im = Image.open(image_path+'/'+filename)
		w = int(im.size[0])
		h = int(im.size[1])
		b = (float(xmin), float(xmax), float(ymin), float(ymax))
		bb = convert((w,h),b)
		print(bb)
		save_data(filename.split('.')[0],unique_classes.index(_class),bb)


def split_data():
	# Create and/or truncate train.txt and test.txt
	file_train = open(output_path+'/train.txt', 'w')
	file_test = open(output_path+'/test.txt', 'w')
	counter = 1
	index_test = round(100 / percentage_test)
	# Populate train.txt and test.txt
	for pathAndFilename in glob.iglob(os.path.join(output_path, "*.jpg")):
	    title, ext = os.path.splitext(os.path.basename(pathAndFilename))

	    if counter == index_test:
	        counter = 1
	        file_test.write(output_path+'/' + title + '.jpg' + "\n")
	    else:
	        file_train.write(output_path+'/' + title + '.jpg' + "\n")
	        counter = counter + 1

def generate_yolo_obj_names_file(unique_classes):
	with open(output_path+'/'+output_path+".names", 'a') as f:
		for c in unique_classes:
			f.write(c + '\n')

def generate_yolo_obj_data_file(n):
	obj_data = open(output_path+'/'+output_path+'.data','w')
	obj_data.write('classes='+str(n)+'\n')
	obj_data.write('train  = train.txt'+'\n')
	obj_data.write('valid  = test.txt '+'\n')
	obj_data.write(output_path+'/'+output_path+".names"+'\n')
	obj_data.write('backup = backup/')

def generate_yolo_cfg_file(n):
	with open(yolo_cfg, 'r') as file:
		data = file.readlines()
		data[236],data[243] = 'filters='+str((n+5)*5)+'\n','classes='+str(n)+'\n'
		with open(output_path+'/'+output_path+'.cfg','w') as f:
			f.writelines(data)

def move_to_darknet():
	shutil.move(output_path, darknet_path)

def launch_training():
	command = "./darknet detector train "+output_path+"/"+output_path+".data"+" "+output_path+"/"+output_path+".cfg"+" "+weights+" -gpus "+gpus
	os.system("gnome-terminal -e 'bash -c \"cd "+darknet_path+" && "+command+" ; exec bash\"'")

def launch_testing():
	print('Testing command: ',"cd "+darknet_path+" && "+"./darknet detector train "+output_path+"/"+output_path+".cfg"+" <weights>")
	print("Weights file(s) found in ",darknet_path+"/backup")

def main():
    yolo_model_installed()
    weights_check_or_download()
    confirm_images_path()
    confirm_output_path()
    xml_list = xml_reader(image_path)
    unique_classes = unique_labels(xml_list)
    print('Classes found: ',unique_classes)
    to_yolo(xml_list,unique_classes)
    split_data()
    generate_yolo_obj_names_file(unique_classes)
    n = len(unique_classes)
    generate_yolo_obj_data_file(n)
    generate_yolo_cfg_file(n)
    move_to_darknet()
    launch_training()
    launch_testing()

if __name__ == '__main__':
	main()
