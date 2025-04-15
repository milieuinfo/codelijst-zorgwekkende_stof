#!/bin/bash

sparql --data=../main/resources/be/vlaanderen/omgeving/data/id/conceptscheme/zorgwekkende_stof/zorgwekkende_stof.ttl\
  --query ../sparql/select_input_csv_from_turtle.rq\
  --results=CSV \
  | sed -e 's;https://data.omgeving.vlaanderen.be/id/concept/sommatie_stoffen/;sommatie_stoffen:;g'\
  | sed -e 's;https://data.omgeving.vlaanderen.be/id/concept/chemische_stof/;;g' > /tmp/ZS-Basislijst.csv
#\