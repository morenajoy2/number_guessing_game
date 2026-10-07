#!/bin/bash

# set up database
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

# enter username
echo "Enter your username:"
read USERNAME_ENTER

USER_ID=$($PSQL "SELECT user_id FROM users WHERE username = '$USERNAME_ENTER'")

if [[ -z $USER_ID ]]; then
  echo -e "\nWelcome, $USERNAME_ENTER! It looks like this is your first time here."

  INSERT_USER=$($PSQL "INSERT INTO users(username) VALUES('$USERNAME_ENTER')")
  USER_ID=$($PSQL "SELECT user_id FROM users WHERE username = '$USERNAME_ENTER'")
else
  USERNAME=$($PSQL "SELECT username FROM users WHERE username = '$USERNAME_ENTER'")
  GAME_PLAYED=$($PSQL "SELECT COUNT(*) FROM games WHERE user_id = $USER_ID")
  BEST_GAME=$($PSQL "SELECT MIN(guesses) FROM games WHERE user_id = $USER_ID")

  echo -e "\nWelcome back, $USERNAME! You have played $GAME_PLAYED games, and your best game took $BEST_GAME guesses."
fi

#generate random number
SECRET_NUMBER=$(( RANDOM % 1000 + 1 ))
GUESS_COUNT=0

# enter guess number
echo -e "\nGuess the secret number between 1 and 1000:"
read GUESS

while [[ $GUESS != $SECRET_NUMBER ]]; do

  # if not integer
  if ! [[ $GUESS =~ ^[0-9]+$ ]]; then
    echo -e "\nThat is not an integer, guess again:"

  # if lower number
  elif [[ $GUESS -gt $SECRET_NUMBER ]]; then
    echo -e "\nIt's lower than that, guess again:"

  # if higher number
  else
    echo -e "\nIt's higher than that, guess again:"
  fi

  read GUESS
  (( GUESS_COUNT++ ))
  
done

(( GUESS_COUNT++ ))

# success guess
echo "You guessed it in $GUESS_COUNT tries. The secret number was $SECRET_NUMBER. Nice job!"
INSERT_GAME=$($PSQL "INSERT INTO games(user_id, guesses) VALUES($USER_ID, $GUESS_COUNT)")