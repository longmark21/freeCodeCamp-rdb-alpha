#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --no-align -t -c"

main() {
  echo -e "\n~~~~~ MY SALON ~~~~~\n"
  echo "Welcome to My Salon, how can I help you?"

  # 显示格式为 "1) Cut" 的服务列表
  display_services

  # 验证 service_id（仅数字且存在）
  while true; do
    read SERVICE_ID_SELECTED

    # 检查是否为数字
    if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]; then
      echo "I could not find that service. What would you like today?"
      display_services
      continue
    fi

    # 检查服务是否存在
    SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")
    if [[ -z $SERVICE_NAME ]]; then
      echo "I could not find that service. What would you like today?"
      display_services
      continue
    fi

    break
  done

  # 获取电话号码
  echo "What's your phone number?"
  read CUSTOMER_PHONE

  # 检查客户是否存在
  CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")
  if [[ -z $CUSTOMER_NAME ]]; then
    # 新客户：获取姓名并插入数据库
    echo "I don't have a record for that phone number, what's your name?"
    read CUSTOMER_NAME
    $PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME')"
  fi

  # 获取预约时间
  echo "What time would you like your $SERVICE_NAME, $CUSTOMER_NAME?"
  read SERVICE_TIME

  # 获取客户ID（确保最新插入的ID）
  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")

  # 创建预约
  $PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')"

  # 输出确认消息（严格按要求格式）
  echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
}

# 专用服务列表显示函数（格式：#) Service）
display_services() {
  SERVICES=$($PSQL "SELECT service_id || ') ' || name FROM services ORDER BY service_id")
  echo "$SERVICES"
}

main