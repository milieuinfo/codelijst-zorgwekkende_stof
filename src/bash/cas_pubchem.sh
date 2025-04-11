#!/bin/bash

while read cas ; do
  url=`curl "https://pubchem.ncbi.nlm.nih.gov/compound/$cas"   -H 'accept: text/html' | grep alternate | tr '"' '\n' |grep http | sort -u ` ;
  echo $cas,$url >> /tmp/cas-url2.csv ;
  curl -OL $url -H 'Accept: text/turtle' ;
done < /tmp/cas

cat << EOF > /tmp/casno
13755-33-4
14429-88-0
90388-10-6
13453-62-8
13767-78-7
EOF

echo 'casnumber,inchikey' > /tmp/cas_to_inchikey.csv
while read cas ; do
  url=`curl "https://pubchem.ncbi.nlm.nih.gov/compound/$cas"   -H 'accept: text/html' | grep alternate | tr '"' '\n' |grep http | sort -u ` ;
  iko=`curl -L $url.nt  | grep -i inchikey | cut -d '>' -f 1 | sed -e 's/<//'`
  inchikey=`curl -L  $iko.nt | grep SIO_000300 | cut -d '"' -f 2`
  echo ${cas},${inchikey} >> /tmp/cas_to_inchikey.csv
done < /tmp/casno


/tmp/cas_to_inchikey2.csv
while read i ; do
  inchikey=`echo $i | cut -d ',' -f 1`\
  cp=`curl -L http://rdf.ncbi.nlm.nih.gov/pubchem/inchikey/$inchikey.nt | tr '<' '\n' | tr '>' '\n' | grep compound | tr '\n' '|'`
  echo ${i},${cp} >> /tmp/cas_to_inchikey2.csv
done < /tmp/inchi_cas.csv