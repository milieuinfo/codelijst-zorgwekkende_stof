library(dplyr)
library(xml2)
library(tidyr)
library(jsonlite)
library(data.table)
library(stringr)
library(xlsx)


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

#df <- read.csv("done2.csv", header = TRUE)
#write.csv(df,"ZS-Basislijst_v1_20250321_inchikey.csv", row.names = FALSE)
df <- read.xlsx("ZS-Basislijst_v1_20250321_inchikey.xlsx", sheetName="ZS-Basislijst")
df2 <- read.csv("wikidata.csv", header = TRUE)
df3 <- merge(x = df, y = df2, by.x = "CAS.nummer",by.y = "cas", all.x = TRUE)%>% mutate_all(as.character)

df3$hasTarget <- ifelse(is.na(df3$hasTarget), df3$inchikey,  df3$hasTarget)
df3$EC.Nummer <- ifelse(is.na(df3$EC.Nummer), df3$ecnr,  df3$EC.Nummer)
df3$hasTarget <- ifelse(is.na(df3$hasTarget), paste("sommatie_stoffen:", df3$CAS.nummer , sep = ""),  df3$hasTarget)
df3 <-df3 %>%select(hasTarget, Stofnaam_IUPAC, CAS.nummer, EC.Nummer, CLP_Aanwezig, SVHC_Aanwezig, Restrict_Aanwezig, POP_Aanwezig, OSPAR_Aanwezig, WFD_Aanwezig, Gewas_Aanwezig, Biociden_Aanwezig)%>% mutate_all(as.character)%>% unique()
write.xlsx(df3, "ZS-Basislijst_v1_20250409_inchikey.xlsx", sheetName="ZS-Basislijst", row.names = FALSE)

df1 <- df3%>% 
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
  unite(uri, motivatedBy , casNumber, sep = "_", remove = FALSE, na.rm = TRUE)%>% 
  unique()
df1$uri <- paste("annotation:", df1$uri , sep = "")
df1$motivatedBy <- paste("zorgwekkende_stof:", df1$motivatedBy , sep = "")
df1$hasBody <- "zorgwekkende_stof:zorgwekkende_stof"

write.csv(df1,"codelijst-source.csv", row.names = FALSE)




