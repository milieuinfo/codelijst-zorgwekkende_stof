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

df = read.csv("ZS-Basislijst.csv", header = TRUE)
#df6 = read.csv("codelijst-source.csv", header = TRUE)%>%select(hasTarget,pubchem)%>%unique()
#df5 <- merge(x = df, y = df6, by = "hasTarget", all.x = TRUE)%>% mutate_all(as.character)
#df5 <- df5 %>% group_by(across(all_of('hasTarget'))) %>%
#  summarize(pubchem = paste(sort(unique(pubchem)),collapse="|"))
#df <- merge(x = df, y = df5, by = "hasTarget", all.x = TRUE)%>% mutate_all(as.character)
#write.csv(df,"ZS-Basislijst.csv", row.names = FALSE)

df1 <- df%>% 
  mutate(CLP_Aanwezig = ifelse(as.character(CLP_Aanwezig) == "1", "zorgwekkende_stof:CLP_Aanwezig", NA))%>% 
  mutate(SVHC_Aanwezig = ifelse(as.character(SVHC_Aanwezig) == "1", "zorgwekkende_stof:SVHC_Aanwezig", NA))%>% 
  mutate(Restrict_Aanwezig = ifelse(as.character(Restrict_Aanwezig) == "1", "zorgwekkende_stof:Restrict_Aanwezig", NA))%>% 
  mutate(POP_Aanwezig = ifelse(as.character(POP_Aanwezig) == "1", "zorgwekkende_stof:POP_Aanwezig", NA))%>% 
  mutate(OSPAR_Aanwezig = ifelse(as.character(OSPAR_Aanwezig) == "1", "zorgwekkende_stof:OSPAR_Aanwezig", NA))%>% 
  mutate(WFD_Aanwezig = ifelse(as.character(WFD_Aanwezig) == "1", "zorgwekkende_stof:WFD_Aanwezig", NA))%>% 
  mutate(Gewas_Aanwezig = ifelse(as.character(Gewas_Aanwezig) == "1", "zorgwekkende_stof:Gewas_Aanwezig", NA))%>% 
  mutate(Biociden_Aanwezig = ifelse(as.character(CLP_Aanwezig) == "1", "zorgwekkende_stof:Biociden_Aanwezig", NA))%>% 
  unite( motivatedBy, CLP_Aanwezig, SVHC_Aanwezig, Restrict_Aanwezig, POP_Aanwezig, OSPAR_Aanwezig, WFD_Aanwezig, Gewas_Aanwezig, Biociden_Aanwezig, sep = "|", remove = TRUE, na.rm = TRUE)%>%
  separate_rows("motivatedBy", sep = "\\|")%>%
  unite(uri, motivatedBy , hasTarget, sep = "_", remove = FALSE, na.rm = TRUE)
df1$uri <- gsub('sommatie_stoffen:', '', df1$uri)
df1$uri <- gsub('zorgwekkende_stof:', 'annotation:', df1$uri)
df1$hasBody <- "zorgwekkende_stof:zorgwekkende_stof"
df1$prefLabel <- ""
df1$definition <- ""
df1$topConceptOf <- ""
df1$broader <- ""


df1 <- df1%>%
  select(uri,prefLabel,label_en,definition,topConceptOf,broader,casNumber,ecNumber,hasTarget,motivatedBy,hasBody,pubchem)

write.csv(df1,"codelijst-source.csv", row.names = FALSE)





