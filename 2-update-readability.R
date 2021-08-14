###########################################################################
################################# MASTER R ################################ 
###########################################################################
# This is the code to create the datasets used to generate Figure D.2 and
# the tables in Appendix L of the paper "Publishing while female".
# Author: Erin Hengel
# Date: 9 August 2021

# Load required packages (downloading them if necessary).
packages = c("RSQLite", "tidyverse","haven", "pacman")
package.check <- lapply(
  packages,
  FUN = function(x) {
    if (!require(x, character.only = TRUE)) {
      install.packages(x, dependencies = TRUE)
      library(x, character.only = TRUE)
    }
  }
)

# Load readability package (https://github.com/trinker/readability)
p_load_gh(c('trinker/lexicon','trinker/textclean','trinker/textshape','trinker/syllable', 'trinker/readability'))
p_load(syllable, readability)

# Create database connection.
con <- dbConnect(RSQLite::SQLite(), "0-data/fixed/read.db")

# Fetch article-level data.
query <- dbSendQuery(con, "SELECT ArticleID, Abstract FROM Article WHERE Language='English' AND Title NOT LIKE '%corrigendum%' AND Title NOT LIKE '%erratum%' AND Title NOT LIKE '%: a correction%' AND Title NOT LIKE '%: correction%';")
abstract = dbFetch(query)
(readstat <- with(abstract, readability(Abstract, ArticleID)))
readstat <- subset(readstat, subset=!is.na(Flesch_Kincaid)&!is.na(Gunning_Fog_Index)&!is.na(SMOG), select=c("ArticleID", "Flesch_Kincaid", "Gunning_Fog_Index", "SMOG"))
names(readstat) <- c("ArticleID", "_r_fleschkincaid_score", "_r_gunningfog_score", "_r_smog_score")

# Multiply by negative 1. (So that larger scores correspond to better written text.)
readstat$"_r_fleschkincaid_score" <- readstat$"_r_fleschkincaid_score" * (-1)
readstat$"_r_gunningfog_score" <- readstat$"_r_gunningfog_score" * (-1)
readstat$"_r_smog_score" <- readstat$"_r_smog_score" * (-1)

# Export data for processing in Stata.
write_dta(readstat, "0-data/generated/readstat.dta")

# Fetch and generate NBER readability statistics.
query <- dbSendQuery(con, "SELECT NberID, Abstract FROM NBER;")
nber = dbFetch(query)
(nberstat <- with(nber, readability(Abstract, NberID)))
nberstat <- subset(nberstat, select=c("NberID", "Flesch_Kincaid", "Gunning_Fog_Index", "SMOG"))
names(nberstat) <- c("NberID", "nber_r_fleschkincaid_score", "nber_r_gunningfog_score", "nber_r_smog_score")

# Multiply scores by negative 1.
nberstat$nber_r_fleschkincaid_score <- nberstat$nber_r_fleschkincaid_score * (-1)
nberstat$nber_r_gunningfog_score <- nberstat$nber_r_gunningfog_score * (-1)
nberstat$nber_r_smog_score <- nberstat$nber_r_smog_score * (-1)

# Export data for processing in Stata.
write_dta(nberstat, "0-data/generated/nberstat.dta")

# Read in Kleven's database of full article texts.
kleven = read_delim("0-data/fixed/introduction_text.txt", delim="|")

# Calculate readability scores.
(articlestat <- with(kleven, readability(Text, NberID)))
articlestat <- subset(articlestat, select=c("NberID", "Flesch_Kincaid", "Gunning_Fog_Index", "SMOG"))
names(articlestat) <- c("NberID", "article_r_fleschkincaid_score", "article_r_gunningfog_score", "article_r_smog_score")

# Multiply scores by negative 1.
articlestat$article_r_fleschkincaid_score <- articlestat$article_r_fleschkincaid_score * (-1)
articlestat$article_r_gunningfog_score <- articlestat$article_r_gunningfog_score * (-1)
articlestat$article_r_smog_score <- articlestat$article_r_smog_score * (-1)

write_dta(articlestat,"0-data/generated/articlestat.dta")
###########################################################################
