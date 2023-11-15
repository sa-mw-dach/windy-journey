#
# This little script converts the downloaded data from Kaggle into a directory 
# structured needed by Yolov5
#


echo "Hello, prep files for Yolov5 training..."

SRCDIR=NordTank-small
DATA=data/wind-turbine


rm -rf $DATA
mkdir -p $DATA/test/images
mkdir -p $DATA/test/labels
mkdir -p $DATA/train/images
mkdir -p $DATA/train/labels
mkdir -p $DATA/valid/images
mkdir -p $DATA/valid/labels

ls -1 $SRCDIR/images/*.png | shuf > images.txt
split --number=l/4 images.txt
cat xaa > test.txt
cat xab xac xad > train.txt

# rm -f xa*
wc -l *.txt

# 
cat train.txt | while read f
do
  cp $f $DATA/train/images
  echo -n .
  TXT=`echo $f | sed s/images/labels/ | sed s/png/txt/`
  test -e $TXT && cp $TXT $DATA/train/labels
done

echo
echo "Number of images for training"
ls -l $DATA/train/images | wc -l 

echo "Number of labels for training"
ls -l $DATA/train/labels | wc -l 

echo "lines in train.txt:"
wc -l train.txt


cat test.txt | while read f
do
  cp $f $DATA/valid/images
  echo -n .
  TXT=`echo $f | sed s/images/labels/ | sed s/png/txt/`
  test -e $TXT && cp $TXT $DATA/valid/labels
done

echo
echo "Number of images for training"
ls -l $DATA/valid/images | wc -l 

echo "Number of labels for training"
ls -l $DATA/valid/labels | wc -l 

echo "lines in train.txt:"
wc -l test.txt


cat <<EOF >> $DATA/data.yaml
train: $DATA/train/images
val: $DATA/valid/images
nc: 2
names: ['dirt', 'damage']
EOF
