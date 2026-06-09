#!/bin/bash

# ========================================
# 数字猜测游戏 - Number Guessing Game
# ========================================

# PostgreSQL 连接命令 - PostgreSQL connection command
# -t: 去除输出中的标题和页脚 (tuples only)
# --no-align: 不对齐输出 (disable aligned output)
# -c: 执行SQL命令 (execute command)
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

# ========================================
# 用户输入和验证 - User Input & Validation
# ========================================

# 提示用户输入用户名
echo "Enter your username:"
read USERNAME

# 限制用户名最大22字符 - Limit username to max 22 characters
# ${USERNAME:0:22} 表示取前22个字符
USERNAME=${USERNAME:0:22}

# ========================================
# 检查用户是否存在 - Check if user exists
# ========================================

# 从数据库查询用户信息
USER_INFO=$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME';")

# 新用户处理 - New user processing
if [[ -z $USER_INFO ]]
then
  # 用户不存在，插入新用户
  INSERT_USER_RESULT=$($PSQL "INSERT INTO users(username) VALUES('$USERNAME');")

  echo "Welcome, $USERNAME! It looks like this is your first time here."

  # 获取新用户的ID
  USER_ID=$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME';")
else
  # 老用户处理 - Returning user processing
  USER_ID=$USER_INFO

  # 统计用户玩过的游戏数
  GAMES_PLAYED=$($PSQL "SELECT COUNT(*) FROM games WHERE user_id=$USER_ID;")

  # 获取用户最佳成绩（最少猜测次数）
  BEST_GAME=$($PSQL "SELECT MIN(guesses) FROM games WHERE user_id=$USER_ID;")

  # 显示欢迎回来信息和游戏统计
  echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi

# ========================================
# 游戏初始化 - Game Initialization
# ========================================

# 生成1到1000之间的随机数
# RANDOM 是bash内置随机数（0-32767）
# % 1000 取余数得到0-999，+1得到1-1000
SECRET_NUMBER=$(( RANDOM % 1000 + 1 ))

# 初始化猜测次数计数器
NUMBER_OF_GUESSES=0

# ========================================
# 游戏���循环 - Game Main Loop
# ========================================

# 提示开始猜数字
echo "Guess the secret number between 1 and 1000:"

# 无限循环直到猜对
while true
do
  # 读取用户输入
  read GUESS

  # ========================================
  # 输入验证 - Input Validation
  # ========================================
  
  # 检查输入是否为非负整数
  # ^[0-9]+$ 正则表达式表示：
  # ^ : 字符串开始
  # [0-9]+ : 一个或多个数字
  # $ : 字符串结束
  if [[ ! $GUESS =~ ^[0-9]+$ ]]
  then
    echo "That is not an integer, guess again:"
    continue  # 跳过计数，继续下一次循环
  fi

  # ========================================
  # 游戏逻辑 - Game Logic
  # ========================================

  # 只有有效整数才增加猜测计数
  NUMBER_OF_GUESSES=$((NUMBER_OF_GUESSES + 1))

  # 比较猜测数与秘密数字
  if [[ $GUESS -lt $SECRET_NUMBER ]]
  then
    # 用户的猜测太小
    echo "It's higher than that, guess again:"
  elif [[ $GUESS -gt $SECRET_NUMBER ]]
  then
    # 用户的猜测太大
    echo "It's lower than that, guess again:"
  else
    # 猜测正确，跳出循环
    break
  fi
done

# ========================================
# 游戏结束 - Game End
# ========================================

# 输出最终结果和成功信息
echo "You guessed it in $NUMBER_OF_GUESSES tries. The secret number was $SECRET_NUMBER. Nice job!"

# ========================================
# 保存游戏记录到数据库 - Save Game Record
# ========================================

# 将本次游戏结果插入games表
INSERT_GAME_RESULT=$($PSQL "INSERT INTO games(user_id, guesses) VALUES($USER_ID, $NUMBER_OF_GUESSES);")
