#!/bin/bash

echo "Which action would you like to perform?"
echo "[1] Create new logged file"
echo "[2] Open file"
echo "[0] Exit"

read -p "Enter a Number" num

case &num in 
    1)