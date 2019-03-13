library(tidyverse)

# Imports command line arguments
args = commandArgs(trailingOnly = TRUE)

df <- as.tibble(read.csv(args[1]))
institutions <- as.tibble(read.csv(args[2]))

parents <- levels(institutions$ParentName)
locations <- levels(institutions$LocationName)

# Taking institutions csv, and combining LocationName and ParentName columns into one long list (and removing duplicates)
inst <- tibble(institution = character(), exist = character())
inst <- add_row(inst, institution = parents, exist = "yes")
inst <- add_row(inst, institution = locations, exist = "yes")

inst1 <- separate_rows(inst, institution, sep=",")

inst_final <- rbind(inst, inst1)
inst_final_unique <- unique(inst_final[,1:2])

# This table has a "yes" for all rows with real institutions
# Changed a couple important university naming conventions
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

# Cities to remove from final dataframe
cities <- c("Houston", "Chicago", "Atlanta", "Raleigh", "St. Louis", "Cambridge", "Inc.", "New Haven", "Birmingham", "Albuquerque", "Milwaukee")

# Creates final list of top institutions (in terms of number of collaborations) and arranges descending
top_institutions <- df2 %>%
  group_by(collaborators) %>%
  summarize(frequency = n()) %>%
  arrange(desc(frequency)) %>%
  filter(collaborators != "University of North Carolina at Chapel Hill") %>%
  filter(!collaborators %in% cities)

# Writes top institutions csv file back to project directory
fileConn = file("top_institutions.csv")
write.csv(top_institutions, file='top_institutions.csv', row.names = FALSE)
close(fileConn)