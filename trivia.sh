#!/bin/zsh
CUR_PATH=`pwd`
DOWNLOAD_PATH="${CUR_PATH}/download"
URLS="${DOWNLOAD_PATH}/.urls"
FILE_TMP="${DOWNLOAD_PATH}/.temp"

#下载资源
function download(){
  echo "客官稍等,下载资源"
  if [[ ! -e ${URLS} ]]; then
    #statements
    echo "资源列表不存在"
    exit 1
  fi
  exec <  ${URLS} 
  read URL
  while [[ $? -eq 0 ]]
  do 
    #检查url的有效性
    #echo "读取到一个网址 ${URL}"
    #下载html文件
    echo ".\c"
    #`wget -P "${DOWNLOAD_PATH}" "${URL}" >>"${DOWNLOAD_PATH}/.log" 2>&1 `
    `wget -P "${DOWNLOAD_PATH}" "${URL}" >/dev/null 2>&1`
    read URL 
  done
  echo "download done"
  for file in  ${DOWNLOAD_PATH}/[^.]* ; do
    #statements
    #echo "文件 : $file"
    if [[ -r $file && $file == *.html ]]; then
      #statements
      # echo "$file 满足条件"


    #获取下载到的文件 筛选出信息 导入 临时文件中
    cat $file | grep "<p>\d\+\..*</p>" >> $FILE_TMP 
    #删除 <p> 标签


    fi
  done

#去除标签信息
sed -i ''  \
  -e "s/<p>//g"  -e "s/<\/p>//g" \
  -e  "s/<a.*a>//g" -e "s/\[.*\]//g"  \
  -e"s/<div.*>//g" -e  "s/^[0-9]\{1,10\}\.//g" \
  $FILE_TMP 
}

function getOneMsg(){

#获取到  行数
line=`wc -l $FILE_TMP |awk '{print $1 }'`
if [[ $line -eq 0 ]]; then
  #statements
  echo "没有获取到有效信息"
  exit 1
fi
#echo "lines: $line "
#生成一个随机数
num=`echo $RANDOM`
#echo "随机数:$num"
#随机选择条信息输出
((num=$num % $line ))
#echo "num : $num"
#打印这条信息
echo "小主，这是您的冷知识^_^:"
msg=`sed -n "${num}p" ${FILE_TMP} `
echo $msg |  awk '{print "【#"  $0 "#】"  }'
}

function checkTools(){

  indicateHomeBrew=`command -v brew`
  if [[ ! -x `command -v brew` ]]; then
    echo "安装brew..."
    /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
    if [[ $? -ne 0 ]]; then
      #statements
     { echo "安装brew失败,请重试" ;   exit 1 ;}
      exit 1
    fi
  fi

  if [[ !  -x `command -v wget` ]]; then
    #statements
    echo "安装wget"
    brew install wget
     if [[ $? -ne 0 ]]; then
      #statements
      { echo "安装wget失败,请重试" ;   exit 1 ;}
    fi
  fi

}

checkTools
if [[ -r $FILE_TMP ]]; then
  #statements
  getOneMsg 
else
  download
  getOneMsg
fi





