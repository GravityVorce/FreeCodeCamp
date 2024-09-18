#!/bin/bash

# PSQL variable
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

# Random number generator between 1 and 1000
SECRET_NUMBER=$(( $RANDOM%1000 + 1 ))

# Prompt to enter username
echo "Enter your username:"
read USERNAME
USERNAME_RESULTS=$($PSQL "SELECT * FROM users LEFT JOIN games USING (user_id) WHERE username='$USERNAME'")

# If user not found
if [[ -z $USERNAME_RESULTS ]]
then
  echo "Welcome, $USERNAME! It looks like this is your first time here."
  ADD_USERNAME=$($PSQL "INSERT INTO users(username) VALUES('$USERNAME')")
  USER_ID=$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME'")

# If user found
else
  USER_ID=$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME'")  
  GAMES_PLAYED=$(echo $($PSQL "SELECT * FROM users LEFT JOIN games USING(user_id) WHERE user_id=$USER_ID")  | wc -l)
  BEST_GAME=$($PSQL "SELECT MIN(number_of_guesses) FROM users LEFT JOIN games USING (user_id) WHERE user_id=$USER_ID")

  echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi

# Guess Number Function
GET_GUESS() {
  if [[ -z $1 ]]
  then
    echo "Guess the secret number between 1 and 1000:"
    COUNT=0
  else
    echo $1
  fi
  read GUESS
  COUNT=$(( $COUNT + 1 ))
}

GET_GUESS

# Guess is not an integer
while [[ $GUESS -ne $SECRET_NUMBER ]]
do
  if [[ ! $GUESS =~ [0-9]+ ]]
  then
    echo $GUESS
    GET_GUESS "That is not an integer, guess again:"

  # Guess is lower than number    
  elif [[ $GUESS -lt $SECRET_NUMBER ]]
  then
    GET_GUESS "It's higher than that, guess again:"

  # Guess is higher than number
  elif [[ $GUESS -gt $SECRET_NUMBER ]]
  then
    GET_GUESS "It's lower than that, guess again:"
  fi
done

# Guess is the number
ADD_GAME=$($PSQL "INSERT INTO games(user_id, secret_number, number_of_guesses) VALUES($USER_ID, $SECRET_NUMBER, $COUNT)")
echo "You guessed it in $COUNT tries. The secret number was $SECRET_NUMBER. Nice job!"
