## FULL PROJECT FILE. IGNORE THIS FILE. DOES NOT ADD TO PROJECT. JUST RUNS THE WHOLE PROJECT AT ONCE, WITHOUT USING NEXTFLOW

library(tidyverse)
df <- tibble(collaborators = character(), abstract = character())

files <- list.files("data/abstracts")
files <- paste0("data/abstracts/",files)

#x <- readLines("abs0.txt")
#add_row(df, collaborators = x[4], abstract = x[5])

#a <- readLines("abs0.txt")[4]
#b <- str_split(a, "\\([0-9]*\\)")[[1]][-c(1)]
#c <- strsplit(b[1], ",", fixed = TRUE)[[1]]

### Lists all collaborators of all files, with their abstract written next to them
for (file in files) {
  
  for (line in 1:length(readLines(file))) {
    if (substr(readLines(file)[line],1,6) == "Author") {
      i <- line
    }
  }
  
  # Abstract
  abs <- casefold(readLines(file)[i+1], upper = FALSE) # converts everything to lowercase
  # Collaborators
  a <- readLines(file)[i] # Reads list of collaborators
  b <- str_split(a, "\\([0-9]*\\)")[[1]][-c(1)] # Splits into individual collaborators, omitting "Author Information" as a collaborator
  for (i in 1:length(b)) {
    c <- strsplit(b[i], ",", fixed = TRUE)[[1]] # For each collaborator, splits by commas
    df <- add_row(df, collaborators = c, abstract = abs) # For each entity in between commas, adds it as new row on dataframe (even address, etc.)
  }
}

df <- data.frame(lapply(df, trimws), stringsAsFactors = FALSE)

institutions <- read.csv("data/institutions/InstitutionCampus.csv")
parents <- levels(institutions$ParentName)
locations <- levels(institutions$LocationName)

inst <- tibble(institution = character(), exist = character())
inst <- add_row(inst, institution = parents, exist = "yes")
inst <- add_row(inst, institution = locations, exist = "yes")

inst1 <- separate_rows(inst, institution, sep=",")

inst_final <- rbind(inst, inst1)
inst_final_unique <- unique(inst_final[,1:2])

# This table has a "yes" for all rows with real institutions
df1 <- df %>%
  left_join(inst_final_unique, by = c("collaborators" = "institution")) %>%
  filter(exist == "yes") %>%
  select(collaborators,abstract) %>%
  mutate(collaborators = replace(collaborators, collaborators == "Duke University Medical Center", "Duke University")) %>%
  mutate(collaborators = replace(collaborators, collaborators == "Duke University Hospital", "Duke University")) %>%
  mutate(collaborators = replace(collaborators, collaborators == "Harvard Medical School", "Harvard University")) %>%
  mutate(collaborators = replace(collaborators, collaborators == "University of Washington School of Medicine", "University of Washington")) %>%
  mutate(collaborators = replace(collaborators, collaborators == "Vanderbilt University Medical Center", "Vanderbilt University")) %>%
  mutate(collaborators = replace(collaborators, collaborators == "Cedars Sinai Medical Center", "Cedars-Sinai Medical Center"))

# selects unique
df2 <- unique(df1)

cities <- c("Houston", "Chicago", "Atlanta", "Raleigh", "St. Louis", "Cambridge", "Inc.", "New Haven", "Birmingham", "Albuquerque", "Milwaukee")

top_institutions <- df2 %>%
  group_by(collaborators) %>%
  summarize(frequency = n()) %>%
  arrange(desc(frequency)) %>%
  filter(collaborators != "University of North Carolina at Chapel Hill") %>%
  filter(!collaborators %in% cities)

df2_combined <- df2 %>%
  group_by(collaborators) %>%
  summarise_all(funs(paste(na.omit(.), collapse = " ")))


write.csv(top_institutions, file='top_institutions.csv', row.names = FALSE)
write.csv(df2_combined, file='df2_combined.csv', row.names = FALSE)
