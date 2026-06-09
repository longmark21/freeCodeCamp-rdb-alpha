#!/bin/bash

# PostgreSQL 连接
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

# 输入用户名
echo "Enter your username:"
read USERNAME

# 限制用户名最大22字符
USERNAME=${USERNAME:0:22}

# 查询用户
USER_INFO=$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME';")

# 新用户
if [[ -z $USER_INFO ]]
then
  INSERT_USER_RESULT=$($PSQL "INSERT INTO users(username) VALUES('$USERNAME');")

  echo "Welcome, $USERNAME! It looks like this is your first time here."

  USER_ID=$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME';")
else
  USER_ID=$USER_INFO

  GAMES_PLAYED=$($PSQL "SELECT COUNT(*) FROM games WHERE user_id=$USER_ID;")

  BEST_GAME=$($PSQL "SELECT MIN(guesses) FROM games WHERE user_id=$USER_ID;")

  echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi

# 生成随机数
SECRET_NUMBER=$(( RANDOM % 1000 + 1 ))

# 猜测次数
NUMBER_OF_GUESSES=0

# 提示开始猜数字
echo "Guess the secret number between 1 and 1000:"

while true
do
  read GUESS

  # 检查是否为整数
  if [[ ! $GUESS =~ ^[0-9]+$ ]]
  then
    echo "That is not an integer, guess again:"
    continue
  fi

  # 有效整数才计数
  NUMBER_OF_GUESSES=$((NUMBER_OF_GUESSES + 1))

  # 判断大小
  if [[ $GUESS -lt $SECRET_NUMBER ]]
  then
    echo "It's higher than that, guess again:"
  elif [[ $GUESS -gt $SECRET_NUMBER ]]
  then
    echo "It's lower than that, guess again:"
  else
    break
  fi
done

# 输出成功信息
echo "You guessed it in $NUMBER_OF_GUESSES tries. The secret number was $SECRET_NUMBER. Nice job!"

# 保存游戏记录
INSERT_GAME_RESULT=$($PSQL "INSERT INTO games(user_id, guesses) VALUES($USER_ID, $NUMBER_OF_GUESSES);")