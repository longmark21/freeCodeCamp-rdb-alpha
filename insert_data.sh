#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.
# 1. 清空表数据 (TRUNCATE 会重置自增 ID，CASCADE 处理外键依赖)
echo $($PSQL "TRUNCATE TABLE games, teams RESTART IDENTITY CASCADE;")

# 2. 读取 CSV 文件并处理数据
#    --skip-headers: 跳过第一行标题
#    -F,: 指定分隔符为逗号
cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT W_GOALS O_GOALS
do
  # 过滤掉标题行（如果 skip-headers 未生效或为了双重保险）
  if [[ $YEAR != "year" ]]
  then
    # --- 插入队伍到 teams 表 ---
    # 插入获胜队
    INSERT_WINNER_RESULT=$($PSQL "INSERT INTO teams(name) VALUES('$WINNER') ON CONFLICT DO NOTHING;")
    
    # 插入对手队
    INSERT_OPPONENT_RESULT=$($PSQL "INSERT INTO teams(name) VALUES('$OPPONENT') ON CONFLICT DO NOTHING;")

    # --- 获取队伍 ID ---
    # 查询获胜队 ID
    WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")
    
    # 查询对手队 ID
    OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")

    # --- 插入比赛数据到 games 表 ---
    # 注意：这里使用了变量 $WINNER_ID 和 $OPPONENT_ID，而不是硬编码数字
    INSERT_GAME_RESULT=$($PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES($YEAR, '$ROUND', $WINNER_ID, $OPPONENT_ID, $W_GOALS, $O_GOALS);")
    
    # 可选：打印调试信息（如果测试不通过可以打开看看）
     echo "Inserted: $WINNER vs $OPPONENT"
  fi
done