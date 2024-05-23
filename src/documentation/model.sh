#!/bin/bash
  sparql --results=TTL --data=../main/resources/be/vlaanderen/omgeving/data/id/conceptscheme/zorgwekkende_stof/zorgwekkende_stof.ttl  --query model.rq  > model.ttl
  rdf2dot  model.ttl | dot -Tpng > model.png
  rdf2dot  model.ttl  > model.dot
