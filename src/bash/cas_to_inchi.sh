#!/bin/bash

while read i;
do cas=$(echo $i | cut -d '"' -f 2)
  echo $cas
  inchikey=$(curl https://cactus.nci.nih.gov/chemical/structure/${cas}/stdinchikey | cut -d '=' -f 2 )
  line=$(echo $i | cut -d '"' -f 2-25)
  echo '"'$inchikey'","'$line >> ../source/result.csv
  sleep 5
done < ../source/todo.csv