#!/bin/bash

################################################################
##
##   MySQL Database To Amazon S3
##   Written By: Bipul
################################################################

###################################
HOME=/home/ubuntu
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
backup_dir="//"
webapp_path="//"
database_name="database"
database_user="backup"
database_pwd=")3<&h%QC:q!%&[)["
#database_host="localhost"
s3_bucket_name="bucketname"
retention_days=2
##################################

date=`date +%m-%d-%Y`
file_date=`date +%Y-%m-%dT%I-%M%P`
path="$backup_dir$date"
echo $date
mkdir -p $path > /dev/null 2>&1
chmod -R 777 $path > /dev/null 2>&1
if [ $? -eq 0 ]; then
    echo "-Successfully  created directory $path"

    mysqldump -u $database_user -p$database_pwd -h $database_host --quick  $database_name | gzip > $path/$file_date.sql.gz

    if [ $? -eq 0 ]; then
        echo "-Successfully created database dump"
        /usr/local/bin/aws s3api put-object --body $path/$file_date.sql.gz --bucket $s3_bucket_name --key $file_date.sql.gz
            if [ $? -eq 0 ]; then
                echo "AWS syncing completed"
            else
                echo "AWS syncing failed, but backup still present in the local server" && exit 1
            fi

            old_date=`date --date="$retention_days day ago" +%m-%d-%Y`
            old_path="$backup_dir$old_date"

            ls $old_path > /dev/null 2>&1
            if [ $? -eq 0 ]; then
                rm -rf $old_path > /dev/null 2>&1
            if [ $? -eq 0 ]; then
                echo "-Sucessfully removed old backup on $old_date"
            else
                echo "-Failed old backup removal $old_path" && exit 1
                echo "-Failed old backup removal $old_path" && exit 1
            fi
        fi
    else
        echo "-Failed creating database dump, backup process failed" && exit 1
    fi

else
    echo "-Failed creating directory $path, backup process failed" && exit 1
fi                                                    
