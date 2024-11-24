#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=periodic_table -t --no-align -c"

# Check if an argument is provided
if [[ -z $1 ]]; then
  echo "Please provide an element as an argument."
  exit 0
fi

# Determine whether the argument is numeric (atomic number) or a string (symbol/name)
if [[ $1 =~ ^[0-9]+$ ]]; then
  CONDITION="e.atomic_number = $1"
else
  CONDITION="e.symbol = '$1' OR e.name = '$1'"
fi

# Query the database
ELEMENT_INFO=$($PSQL "
SELECT e.atomic_number, e.name, e.symbol, p.atomic_mass, t.type, 
       p.melting_point_celsius, p.boiling_point_celsius 
FROM elements e 
INNER JOIN properties p ON e.atomic_number = p.atomic_number 
INNER JOIN types t ON p.type_id = t.type_id 
WHERE $CONDITION;")

# Check if the element exists
if [[ -z $ELEMENT_INFO ]]; then
  echo "I could not find that element in the database."
  exit 0
fi

# Parse the output
IFS="|" read ATOMIC_NUMBER NAME SYMBOL MASS TYPE MELTING_POINT BOILING_POINT <<< "$ELEMENT_INFO"

# Output element information
echo "The element with atomic number $ATOMIC_NUMBER is $NAME ($SYMBOL). It's a $TYPE, with a mass of $MASS amu. $NAME has a melting point of $MELTING_POINT celsius and a boiling point of $BOILING_POINT celsius."
