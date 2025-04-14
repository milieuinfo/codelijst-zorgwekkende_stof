library(dplyr)
library(xml2)
library(tidyr)
library(jsonlite)
library(data.table)
library(stringr)

setwd('/home/gehau/git/codelijst-zorgwekkende_stof/src/source')

expand_df_on_pipe <- function(df) {
  # verdubbel rijen met pipe separator
  for(col in colnames(df)) {   # for-loop over columns
    df <- df %>%
      separate_rows(col, sep = "\\|")%>%
      distinct()
  }
  return(df)
}
collapse_df_on_pipe <- function(df, id_col) {
  ## https://dplyr.tidyverse.org/articles/programming.html
  df3 <-  df %>%
    select(all_of(id_col)) %>%
    distinct()
  for(col in colnames(df)) {   # for-loop over columns
    if ( col != id_col) {
      df4 <- df %>% select(all_of(c(id_col, col)))
      names(df4)[2] <- 'naam' # hack, geef de tweede kolom een vaste naam, summarize werkt niet met variabele namen
      df2 <- df4 %>% group_by(across(all_of(id_col))) %>%
        summarize(naam = paste(sort(unique(naam)),collapse="|"))
      names(df2)[2] <- col # wijzig kolom met naam 'naam' terug naar variabele naam
      df3 <- merge(df3, df2, by = id_col)
    }
  }
  df3 <- df3 %>%
    mutate_all(~na_if(., ''))
  return(df3)
}


df1 = read.csv("codelijst-source.csv", header = TRUE)%>%select(hasTarget, casNumber, ecNumber,label_en, hasBody, pubchem)%>% mutate_all(as.character)%>% unique()

df2 = read.csv("/home/gehau/git/codelijst-chemische_stof/src/source/codelijst-source.csv", header = TRUE)

df2$pubchem <- str_replace(df2$pubchem, "compound:", "compound:CID")

df3 <- anti_join(df1, df2, by = c("hasTarget" = "uri_inchikey"))%>% 
  setnames( "hasTarget","uri_inchikey")%>%
  setnames( "hasBody","source")%>%
  setnames( "label_en","altLabel")%>%
  setnames( "ecNumber","ec_nummer")
df3$iupacName <- ''
df3$definition <- ''
df3$prefLabel <- ''
df3$notation <- ''
df3$exactMatch <- ''
df3$X_broader <- ''
df3$validatie_status <- 'status:todo'
df3$X_isReferencedBy <- ''
df3$belongsTo <- ''
df3$inScheme <- 'conceptscheme:chemische_stof'
df2$source <- ''
df3$inScheme <- 'conceptscheme:chemische_stof'
df2$source <- ''
df3$altLabel <- 

dfsommatie <- df3 %>%filter(str_detect(uri_inchikey, "^sommatie"))
dfstoffen <- df3 %>%filter(!str_detect(uri_inchikey, "^sommatie|todo"))



df2 <- rbind(df2, dfstoffen)

write.csv(df2,"/home/gehau/git/codelijst-chemische_stof/src/source/codelijst-source.csv", row.names = FALSE)


setwd('/home/gehau/git/codelijst-chemische_stof/src/source')

df = read.csv("codelijst-source.csv", header = TRUE)%>%
  separate_rows(pubchem, sep = "\\|")%>%
  distinct()
df1 = read.csv("/tmp/pubchem_preflabel_iupac.csv", header = TRUE)%>%setnames( "prefLabel","prefLabel_en")
df2 <- merge(x = df, y = df1, by = "pubchem", all.x = TRUE)%>% mutate_all(as.character)
df2$iupacName <-  ifelse(df2$iupacName == '' ,df2$iupac ,  df2$iupacName)
df2 <- collapse_df_on_pipe(df2, 'uri_inchikey') 

df2 <- df2%>%select(uri_inchikey,iupacName,prefLabel,prefLabel_en,altLabel,notation,definition,exactMatch,casNumber,ecNumber,X_broader,pubchem,validatie_status,X_isReferencedBy,belongsTo,inScheme,source)%>% mutate_all(as.character)%>% unique()
write.csv(df2,"codelijst-source.csv", row.names = FALSE)

#df6 <- df2 %>% group_by(across(all_of(id_col))) %>%
#  summarize(naam = paste(sort(unique(naam)),collapse="|"))


#df2$iupac
df3 <- df2%>% select(prefLabel, prefLabel_en, iupacName, pubchem)


df4 <- df2%>% select(source, pubchem,iupacName)%>% subset(source!='')%>% subset(pubchem!='')%>% subset(is.na(iupacName))


df5 <-df4%>% select(pubchem)
write.csv(df5,"/tmp/pubchem.csv", row.names = FALSE)

df2 <- df4 %>% group_by(across(all_of(id_col))) %>%
  summarize(naam = paste(sort(unique(naam)),collapse="|"))


