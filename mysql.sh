#!/bin/bash

userid=$(id -u)
time_stamp=$(date +%F-%H-%M-%S)
script_name=$(echo $0 | cut -d "." -f1)
logfile=/tmp/$script_name-$time_stamp.log

echo "Please enter DB password:"
read -s mysql_root_password

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

dnf install mysql-server -y &>>$logfile
VALIDATE $? " Installation of mysql server"

systemctl enable mysql-d $>>$logfile
VALIDATE $? "enabling of mysql server"

systemctl start mysql-d $>>$logfile
VALIDATE $? "starting of mysql server"

#mysql_secure_installation --set-root-pass ExpenseApp@1 &>>$logfile
# VALIDATE $? "Setting up root password"

#Below code will be useful fir idempotent nature (replace 43 & 44 line)
mysql -h localhost -u root -p ${mysql_root_password} -e 'show databases;' &>>$logfile
if [ $? -ne 0 ]
then
    mysql_secure_installation --set-root-pass ${mysql_root_password} &>>$logfile
    VALIDATE $? "My sql root password setup"
else
    echo -e "Mysql root password is already setup.. $Y SKIPPING $N"
fi
    






