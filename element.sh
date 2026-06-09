#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=periodic_table -t --no-align -c"

# 如果没有参数
if [[ -z $1 ]]
then
  echo "Please provide an element as an argument."
  exit
fi

# 如果参数是数字
if [[ $1 =~ ^[0-9]+$ ]]
then
  ELEMENT_RESULT=$($PSQL "
    SELECT elements.atomic_number,
           elements.name,
           elements.symbol,
           types.type,
           properties.atomic_mass,
           properties.melting_point_celsius,
           properties.boiling_point_celsius
    FROM elements
    JOIN properties USING(atomic_number)
    JOIN types USING(type_id)
    WHERE elements.atomic_number=$1
  ")
else
  ELEMENT_RESULT=$($PSQL "
    SELECT elements.atomic_number,
           elements.name,
           elements.symbol,
           types.type,
           properties.atomic_mass,
           properties.melting_point_celsius,
           properties.boiling_point_celsius
    FROM elements
    JOIN properties USING(atomic_number)
    JOIN types USING(type_id)
    WHERE elements.symbol='$1'
       OR elements.name='$1'
  ")
fi

# 如果没找到元素
if [[ -z $ELEMENT_RESULT ]]
then
  echo "I could not find that element in the database."
else
  echo "$ELEMENT_RESULT" | while IFS="|" read ATOMIC_NUMBER NAME SYMBOL TYPE MASS MELTING BOILING
  do
    echo "The element with atomic number $ATOMIC_NUMBER is $NAME ($SYMBOL). It's a $TYPE, with a mass of $MASS amu. $NAME has a melting point of $MELTING celsius and a boiling point of $BOILING celsius."
  done
fi
