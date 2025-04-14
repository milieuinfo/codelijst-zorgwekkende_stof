library(dplyr)
library(xml2)
library(tidyr)
library(jsonlite)
library(data.table)
library(stringr)



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

setwd('/home/gehau/git/codelijst-zorgwekkende_stof/src/source')

df1 = read.csv("codelijst-source.csv", header = TRUE)%>%
  filter(str_detect(hasTarget, "^sommatie"))%>%
  select(hasTarget, casNumber, ecNumber,label_en, hasBody, pubchem)%>%
  mutate_all(as.character)%>% 
  unique()%>%
  setnames( "hasTarget","uri")%>%
  setnames( "hasBody","source")%>%
  setnames( "label_en","altlabel_en")
df1$notation <- ''
df1$prefLabel <- ''
df1$prefLabel_en <- ''
df1$definition <- ''
df1$collections <- ''
df1$inScheme <- 'conceptscheme:sommatie_stoffen'
df1$theme <- ''
df1$topConceptOf <- 'conceptscheme:sommatie_stoffen'
df1$broader <- ''
df1$exactMatch <- ''
df1$broadMatch <- ''
df1$narrowMatch <- ''
df1$comment <- ''
df1$belongsTo <- ''
df1$altLabel <- ''


df2 = read.csv("/home/gehau/git/codelijst-sommatie_stoffen/src/source/codelijst-source.csv", header = TRUE)%>%
  setnames( "seeAlso","pubchem")
df2$ecNumber <- ''
df2$altlabel_en <- ''
df2$source <- ''

colnames(df1)
colnames(df2)

df <- rbind(df1, df2) %>%select(uri, prefLabel,prefLabel_en, casNumber,ecNumber,altLabel,altlabel_en,comment,definition,broader,broadMatch,collections,exactMatch,narrowMatch,notation,pubchem,source,theme,topConceptOf,inScheme,belongsTo)

df <- collapse_df_on_pipe(df, 'uri')

write.csv(df,"/home/gehau/git/codelijst-sommatie_stoffen/src/source/codelijst-source.csv", row.names = FALSE)




