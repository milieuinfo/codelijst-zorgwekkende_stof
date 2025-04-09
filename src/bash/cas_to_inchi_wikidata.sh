#!/bin/bash

#curl 'https://query.wikidata.org/sparql?query=select%20%3Fs%0Awhere%0A%7B%3Fs%20%3Chttp%3A%2F%2Fwww.wikidata.org%2Fprop%2Fdirect%2FP231%3E%20%221606-67-3%22%7D'  -H 'Accept: application/sparql-results+json'

cas='1606-67-3'
curl "https://query.wikidata.org/sparql?query=construct%20%0A%7B%3Fs%20%3Fp%20%3Fo%7D%0Awhere%0A%7B%3Fs%20%3Chttp%3A%2F%2Fwww.wikidata.org%2Fprop%2Fdirect%2FP231%3E%20%22${cas}%22%20%3B%0A%3Fp%20%3Fo%20.%7D" -H 'Accept: application/ld+json' # -H 'Accept: application/sparql-results+json'
sparql --data=../wikidata.nt --query ../../sparql/query_inchikey_cas_wikidata.rq --results=CSV > ../wikidata.csv
while read line ; do
  grep '"'$line'" .' /home/gehau/git/codelijst-zorgwekkende_stof/src/source/test.nt ;
  done < src/source/casnrs > /home/gehau/git/codelijst-zorgwekkende_stof/src/source/result.nt
