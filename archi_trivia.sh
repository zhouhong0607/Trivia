curPath=`pwd`
downloadPath="${curPath}/download"
host="http://sprite.phys.ncku.edu.tw/astrolab/mirrors/apod"
indexUrl="${host}/archivepix.html"
indexPath="${curPath}/download//archivepix.html"
indexFile="${curPath}/download/archi_index.txt"


if [[ -e ${indexPath}  ]]; then
  #statements
  echo "index 文件存在 删除"
  rm $indexPath
fi
echo "客官稍等,下载资源......"
wget -P "$downloadPath"  "$indexUrl" >>"${downloadPath}/.log" 2>&1
if [[ ! $? -eq 0 ]]; then
  #statements
  echo "下载失败,请检查网络"
  exit 1
fi
echo "index下载完成"
cat "${downloadPath}/archivepix.html" \
| grep "^[0-9|a-z|A-Z].*<a href=.*</a>" > "${indexFile}"

 sed -i '' -f  "${downloadPath}/.sed_config" "${indexFile}"


#获取到  行数
line=`wc -l $indexFile |awk '{print $1 }'`
if [[ $line -eq 0 ]]; then
  #statements
  echo "没有获取到有效信息"
  exit 1
fi
num=`echo $RANDOM`
((num=$num % $line ))
suffix=`sed -n "${num}p" ${indexFile} `
 url="${host}/${suffix}" 
  echo "URL: $url"
targetFile="${downloadPath}/${suffix}"
if [[ -e targetFile ]]; then
  #statements
  rm $targetFile
fi
touch $targetFile
if [[ -n $suffix ]]; then
  #statements
  curl "$url" > "$targetFile"  
  charset=`cat $targetFile | grep "charset=big5"`
  if [[ -n $charset ]]; then
    #转码
    echo "转码"
    a=`iconv  -f big5 -t UTF-8  $targetFile`
    echo $a > $targetFile
  fi

fi

if [[ -r $targetFile ]]; then
  #statements
  echo "冷知识:"
  cat $targetFile > "${targetFile}_1"
  msg=`cat $targetFile | sed -e '/<b> 說明/,/<p> <center>/!d'  `
  echo "截取后信息:$msg"
  if [[ -n $msg ]]; then
    #statements
    echo "获取不到有效信息"
    exit 1
  fi
  msg=` echo $msg | xargs`
  echo "合并行后:$msg"
  echo $msg > $targetFile
  msg=`sed  's/<[^>]*>//g ' $targetFile `
  echo $msg | awk '{print "【#"  $0 "#】"  }'

fi





