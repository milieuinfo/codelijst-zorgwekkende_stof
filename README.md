# codelijst-zorgwekkende_stof


## Samenvatting
Lijst van zorgwekkende chemische stoffen.


## Model
![Model](src/documentation/model.png)

## Gebruik

### Voeg een definitie van een nieuwe zorgwekkende chemische stof toe aan $PROJECT_HOME/src/source/codelijst-source.csv

### Voer het het transformatiescript uit:
```
cd $PROJECT_HOME/src/
node 01_codelijst_skos_from_csv.js
```

### run een maven build ( testen worden uitgevoerd en metadata aangemaakt)
```
cd $PROJECT_HOME
mvn clean install
```

## Dependencies

**_nodejs_**

### Installeer nodejs en npm
```
apt-get install node
apt-get install npm
```

### Installeer libraries in package.json
```
cd $PROJECT_HOME
/usr/bin/node /usr/lib/node_modules/npm/bin/npm-cli.js install --scripts-prepend-node-path=auto
```

```mermaid
flowchart TD
    A[Start luchtzuiveringssysteem] --> B[Meten van relevante parameters]
    B --> C{Type systeem?}
    C -->|Luchtwasser| D[Luchtwasser parameters meten:\npH, geleidbaarheid, spuiwaterproductie,\ndrukval, draaiuren, debiet]
    C -->|Biobed| E{Zijn parameters gedefinieerd in systeembeschrijving?}
    E -->|Ja| F[Gebruik gedefinieerde parameters]
    E -->|Nee| G[Biobed parameters meten: draaiuren, drukval 3 sensoren,\nluchtvochtigheid boven/midden/onder]

    D --> H[Registreer parameters minimaal 1x per uur]
    F --> H
    G --> H

    H --> I[Elektronische opslag van gegevens]
    I --> J[Dagelijkse verzending naar overheid via internetloket]

    J --> K{Internetloket beschikbaar?}
    K -->|Ja| L[Verzending OK]
    K -->|Nee| M[Wacht & verzend zodra mogelijk]

    I --> N[Minimaal 5 jaar digitale opslag ter plaatse]
    N --> O[Toegang voor exploitant, Mestbank, toezichthouder]

    H --> P[Elektronisch alarmsysteem]
    P --> Q{Overschrijding grenswaarde?}
    Q -->|Ja| R[Alarm gaat af]
    Q -->|Nee| S[Normale werking voortzetten]

    style A fill:#e0f7fa,stroke:#00838f,stroke-width:2px
    style D fill:#fff9c4,stroke:#fbc02d
    style G fill:#ffe0b2,stroke:#ef6c00
    style P fill:#fce4ec,stroke:#d81b60

```