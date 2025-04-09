'use strict';
import {  generate_skos } from 'maven-metadata-generator-npm';
import {
    ttl,
    nt,
    jsonld,
    csv
} from './utils/variables.js';
//import {substances_by_cas} from './utils/resolve_cas_in_wikidata_test.js'
console.log = function() {}
//substances_by_cas()
generate_skos(ttl, jsonld, nt, csv);

