#! /bin/bash
PSQL="psql --username=freecodecamp --dbname=periodic_table -t --no-align -c"

# Argument empty
if [[ -z $1 ]]
then
  # statement
  echo "Please provide an element as an argument."

else
  # if argument is element's atomic number
  if [[ $1 =~ [0-9]+ ]]
  then
    ATOMIC_NUMBER=$1
    RESULT=$($PSQL "SELECT atomic_number, symbol, name, type, atomic_mass, melting_point_celsius, boiling_point_celsius FROM elements FULL JOIN properties USING(atomic_number) FULL JOIN types USING (type_id) WHERE atomic_number=$ATOMIC_NUMBER")

  # if argument is element's symbol
  elif [[ $(echo -n $1 | wc -c) -le 2 ]]
  then
    SYMBOL=$1
    RESULT=$($PSQL "SELECT atomic_number, symbol, name, type, atomic_mass, melting_point_celsius, boiling_point_celsius FROM elements FULL JOIN properties USING(atomic_number) FULL JOIN types USING (type_id) WHERE symbol='$SYMBOL'")

  # if argument is element's name
  else
    NAME=$1
    RESULT=$($PSQL "SELECT atomic_number, symbol, name, type, atomic_mass, melting_point_celsius, boiling_point_celsius FROM elements FULL JOIN properties USING(atomic_number) FULL JOIN types USING (type_id) WHERE name='$NAME'")
  fi

  if [[ -z $RESULT ]]
  then 
    echo "I could not find that element in the database."
  else
    echo $RESULT | while IFS="|" read ATOMIC_NUMBER SYMBOL NAME TYPE MASS MELTING BOILING
    do
      echo "The element with atomic number $ATOMIC_NUMBER is $NAME ($SYMBOL). It's a $TYPE, with a mass of $MASS amu. $NAME has a melting point of $MELTING celsius and a boiling point of $BOILING celsius."
    done
  fi
fi