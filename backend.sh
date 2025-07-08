#!/bin/bash

userid=$(id -u)
time_stamp=$(date +%F-%H-%M-%S)
script_name=$(echo $0 | cut -d "." -f1)
logfile=/tmp/$script_name-$time_stamp.log

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

echo "enter mysql root password:"
read -s mysql_root_password


VALIDATE () {
    if [ $1 -ne 0 ]
    then 
        echo -e "$2 is.. $R Failed $N"
        exit 1
    else
        echo -e "$2 is.. $G SUCCESSFUL $N"
    fi
}

if [ $userid -ne 0 ]
then
        echo "Please run the script with root user"
        exit 1
else
        echo " you are root user"
fi

dnf module disable nodejs -y &>>$logfile
VALIDATE $? "disabling nodejs default module"

dnf module enable nodejs:20 -y &>>$logfile
VALIDATE $? "enablish nodejs:20 version"

dnf install nodejs -y &>>$logfile
VALIDATE $? "installing nodejs"

id expnese &>>$logfile
if [ $? -ne 0 ]
then
    useradd expense &>>$logfile
    VALIDATE $? "Creating expense user"
else
    echo -e "expense user already created $Y.. SKIPPING $N"
fi

mkdir -p /app &>>$logfile  ## this command will create /app directory if not exist, -p checks if direcoty exist and it not it creates it
VALIDATE $? "Creating app directory"

curl -o /tmp/backend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-backend-v2.zip &>>$logfile
VALIDATE $? "Downloding application code to temp directory"

cd /app &>>$logfile
rm -rf /app/*
unzip /tmp/backend.zip &>>$logfile
VALIDATE $? "unzip backend.zip file located on /tmp to /app directory"

npm install &>>$logfile
VALIDATE $? "installation of nodejs dependencies"

cp /home/ec2-user/expense-documentation/backend.service /etc/systemd/system/backend.service &>>$logfile
VALIDATE $? "copied backend services"

systemctl daemon-reload &>>$logfile
VALIDATE $? "Daemon reload"

systemctl enable backend &>>$logfile
VALIDATE $? "Enabling backend"

systemctl start backend &>>$logfile
VALIDATE $? "Starting backend service"

dnf install mysql -y &>>$logfile
VALIDATE $? "installing of mysql client"

mysql -h db.omansh.fun -uroot -p${mysql_root_password} < /app/schema/backend.sql &>>$logfile
VALIDATE $? "Schema loading"

systemctl restart backend &>>$LOGFILE
VALIDATE $? "Restarting Backend"










    






