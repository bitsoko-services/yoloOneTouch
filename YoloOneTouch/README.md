
# YoloOneTouch


Getting started with yolo model can be a painful experience
Especially in data preparation as yolo expects data in a certain format
The basic steps involved:
1. Prepare data using labelImg <a href='https://github.com/tzutalin/labelImg'>
    labelImg</a><br>
2. labelImg generates xml files for every image in your dataset containing <br>
    [filename,width,height,class,xmin,ymin,xmax,ymax]  - Yolo expects <br>
    [category number object center in X object center in Y object width in X object width in Y] <br>
3. All these steps generates unnecessary files in your disk space <br>
4. You have to modify three yolo configuration files <br>
      1.obj.names
      2.obj.data
      3.yolo-obj.cfg

    and Then <br>
5. Manually move these files into darknet relative folder for yolo to find them. <br>
6. Also you need to manually create train and test files <br>

 YoloOneTouch automates all these processes all the way to auto-training launch <br>
  and allows you to focus only with <a href='https://github.com/tzutalin/labelImg'>
     labelImg</a><br>



Contributions to the script are welcome.



## Maintainers

* Mike @ BitsokoServices (https://github.com/bitsoko)


## Table of contents

Quick Start:

  * <a href='https://github.com/pjreddie/darknet'>
      Quick Yolo Model: Installation Instructions</a><br>
  * <a href="https://github.com/tzutalin/labelImg">labelImg</a><br>

Running:

  * Python3 YoloOneTouch.py



<b>Thanks to contributors</b>: Mike Antony
