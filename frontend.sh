#!/bin/bash

userid=$(id -u)
time_stamp=$(date +%F-%H-%M-%S)
script_name=$(echo $0 | cut -d "." -f1)
logfile=/tmp/$script_name-$time_stamp.log

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

VALIDATE () {
    if [ $1 -ne 0 ]
    then 
        echo -e "$2 is.. $R Failed $N"
        exit 1
    else
        echo -e "$2 is.. $G SUCCESSFUL $N"
}

if [ $userid -ne 0 ]
then
        echo "Please run the script with root user"
        exit 1
else
        echo " you are root user"
fi

dnf install nginx -y &>>$logfile
VALIDATE $? "Installation of nginx"

systemctl enable nginx &>>$logfile
VALIDATE $? "Enabling nginx service"

systemctl start nginx &>>$logfile
VALIDATE $? "Starting nginx service"

rm -rf /usr/share/nginx/html/* &>>$logfile
VALIDATE $? "removing default nginx files"

curl -o /tmp/frontend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-frontend-v2.zip &>>$logfile
VALIDATE $? "extdownload frontend code to temp directory"

cd /usr/share/nginx/html
unzip /tmp/frontend.zip
VALIDATE $? "extracting frontend code"

cp /home/ec2-user/expense-documentation/expense.conf /etc/nginx/default.d/expense.conf &>>$logfile
VALIDATE $? "copied frontend.conf"

systemctl restart nginx &>>$logfile
VALIDATE $? "Restarting nginx service"

