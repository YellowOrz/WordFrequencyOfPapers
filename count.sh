#!/bin/bash

# 整合文本
echo "Please input direction of txts [default: ./Papers]"
read path
if [ -z "$path" ];then
    path="./Papers"
fi
result="dictionary_"$(echo $path|tr 'A-Z' 'a-z'|sed 's/[^a-z]//g')".txt"
echo "save result to $result"
echo "" >  $result
 for i in $(find $path -name "*txt")
    do
        cat "$i" >> $result
    done

# 统计词频
cat $result |tr 'A-Z' 'a-z' |                                            #大写转小写
                            sed 's/[^a-z'-']/ /g'|                          #将除了字母和-以外的变成空格
                            tr -s ' ' '\n'|                                           #将空格变成换行
                            sed 's/s$//g'|                                      #删除单词结尾的s
                            grep -v '\-$'|grep -v '^\-'|                #去除以-为首or结尾的单词
                            awk '{print length($0) " " $0}'|    #统计单词长度
                            grep -v -w [1-4]|                                 #去除长度为1-4的单词
                            awk '{if($2!="") print $2}'|             #去除长度和空行
                            sort|                                                        #根据首字母排序
                            uniq -c|                                                  #统计单词频率
                            grep -v -w [1-9]|                                  #删除出现频率小于5次的单词
                            sort -r -n|                                               #根据词频排序
                            awk '{print $2" "$1}'>$result        #输出单词+词频

# 整理黑名单
cat blacklist.txt|tr 'A-Z' 'a-z' |                                       #大写转小写
                                sed 's/[^a-z'-']/ /g'|                           #将除了字母和-以外的变成空格
                                tr -s ' ' '\n'|                                           #将空格变成换行
                                awk '{print length($0) " " $0}'|    #统计单词长度
                                grep -v -w [1-4]|                                 #去除长度为1-4的单词
                                awk '{if($2!="") print $2}'|            #去除长度和空行
                                sort|                                                       #排序
                                uniq > temp.txt                                 #去除重复行后输出
cat temp.txt  > blacklist.txt
rm temp.txt

# 从结果中剔除黑名单里的单词
for i in $(cat blacklist.txt)
do
    line=$(cat $result|grep -n -w $i|grep -v "-" | cut -f 1 -d ':')
    if [ -n "$line" ];then
        sed -i ''$line'd' $result
    fi
done