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

df1 = read.csv("ZS-Basislijst_v1_20250321.csv", header = TRUE)

df2 = read.csv("/home/gehau/git/codelijst-chemische_stof/src/source/codelijst-source.csv", header = TRUE)
df2 <- df2 %>%
  separate_rows("casNumber", sep = "\\|")%>%
  distinct() %>%
  select(uri, casNumber)
dfx = read.csv("test.csv", header = TRUE)%>% setnames( "hasTarget", "uri") 
df2 <- bind_rows(df2,dfx)%>% unique()
df3 <- merge(x = df1, y = df2, by.x = "CAS.nummer",by.y = "casNumber", all.x = TRUE)%>%relocate(uri)%>%setnames( "uri", "hasTarget")%>% mutate_all(as.character)%>% unique()
df3todo <- subset(df3, is.na(hasTarget))
#write.csv(df3todo,"todo.csv", row.names = FALSE)
df3done <- subset(df3, !is.na(hasTarget))
#write.csv(df3done,"done.csv", row.names = FALSE)
df3$hasTarget <-replace_na(df3$hasTarget, "")
df4 <- df3 %>% mutate_all(as.character)%>% 
  mutate(CLP_Aanwezig = ifelse(as.character(CLP_Aanwezig) == "1", "CLP_Aanwezig", NA))%>% 
  mutate(SVHC_Aanwezig = ifelse(as.character(SVHC_Aanwezig) == "1", "SVHC_Aanwezig", NA))%>% 
  mutate(Restrict_Aanwezig = ifelse(as.character(Restrict_Aanwezig) == "1", "Restrict_Aanwezig", NA))%>% 
  mutate(POP_Aanwezig = ifelse(as.character(POP_Aanwezig) == "1", "POP_Aanwezig", NA))%>% 
  mutate(OSPAR_Aanwezig = ifelse(as.character(OSPAR_Aanwezig) == "1", "OSPAR_Aanwezig", NA))%>% 
  mutate(WFD_Aanwezig = ifelse(as.character(WFD_Aanwezig) == "1", "WFD_Aanwezig", NA))%>% 
  mutate(Gewas_Aanwezig = ifelse(as.character(Gewas_Aanwezig) == "1", "Gewas_Aanwezig", NA))%>% 
  mutate(Biociden_Aanwezig = ifelse(as.character(CLP_Aanwezig) == "1", "Biociden_Aanwezig", NA))%>%  
  unite( motivatedBy, CLP_Aanwezig, SVHC_Aanwezig, Restrict_Aanwezig, POP_Aanwezig, OSPAR_Aanwezig, WFD_Aanwezig, Gewas_Aanwezig, Biociden_Aanwezig, sep = "|", remove = TRUE, na.rm = TRUE)%>%
  setnames( "CAS.nummer", "casNumber")%>%
  setnames( "EC.Nummer", "ecNumber")%>%
  setnames( "Stofnaam_IUPAC", "label_en")%>%
  separate_rows("motivatedBy", sep = "\\|")%>%
  unite(uri, motivatedBy , casNumber, sep = "_", remove = FALSE, na.rm = TRUE)
df4$uri <- paste("annotation:", df4$uri , sep = "")
df4$motivatedBy <- paste("zorgwekkende_stof:", df4$motivatedBy , sep = "")

df4$hasBody <- "zorgwekkende_stof:zorgwekkende_stof"



write.csv(df3,"ZS-Basislijst_v1_20250321_inchikey.csv", row.names = FALSE)
write.csv(df4,"codelijst-source.csv", row.names = FALSE)




