#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

echo "Enter your username:"
read USERNAME
ID=$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME';")
        
if [[ -z $ID ]]
then
  SURPRESS=$($PSQL "INSERT INTO users(username) VALUES('$USERNAME');")
  ID=$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME';")
  echo "Welcome, $USERNAME! It looks like this is your first time here."
else
  GAMES_PLAYED=$($PSQL "SELECT COUNT(game_id) FROM games WHERE player_id=$ID;")
  BEST_GAME=$($PSQL "SELECT MIN(guesses_made) FROM games WHERE player_id=$ID;")
  echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi

SECRET_NUMBER=$(( $RANDOM % 1000 + 1 ))
NUMBER_OF_GUESSES=1
        
echo "Guess the secret number between 1 and 1000:"
read GUESS

while [[ $GUESS -ne $SECRET_NUMBER ]]
do
  if [[ $GUESS =~ ^[0-9]+$ ]]
  then
    NUMBER_OF_GUESSES=$(( $NUMBER_OF_GUESSES + 1 ))
    if [[ $GUESS -lt $SECRET_NUMBER ]]
    then
      echo "It's higher than that, guess again:"
    else [[ $GUESS -gt $SECRET_NUMBER ]]
      echo "It's lower than that, guess again:"
    fi
  else
    echo "That is not an integer, guess again:"
  fi
  read GUESS
done

SURPRESS=$($PSQL "INSERT INTO games(player_id, guesses_made) VALUES($ID, $NUMBER_OF_GUESSES);")
echo "You guessed it in $NUMBER_OF_GUESSES tries. The secret number was $SECRET_NUMBER. Nice job!"
