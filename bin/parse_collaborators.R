library(tidyverse)

# Imports arguments from command line
args = commandArgs(trailingOnly = TRUE)
file <- args[1]

# Creates empty tibble; collaborators and corresponding abstracts will be added to this
df <- tibble(collaborators = character(), abstract = character())

# Saves index of line in abstract file that begins with "Author"
for (line in 1:length(readLines(file))) {
  if (substr(readLines(file)[line],1,6) == "Author") {
    i <- line
  }
}

# Converts abstract of file to lower case and saves it to abs variable
abs <- casefold(readLines(file)[i+1], upper = FALSE) # converts everything to lowercase

# Obtains collaborators from file
a <- readLines(file)[i] # Reads list of collaborators
b <- str_split(a, "\\([0-9]*\\)")[[1]][-c(1)] # Splits into individual collaborators, omitting "Author Information" as a collaborator
for (i in 1:length(b)) {
  c <- strsplit(b[i], ",", fixed = TRUE)[[1]] # For each collaborator, splits by commas
  df <- add_row(df, collaborators = c, abstract = abs) # For each entity in between commas, adds it as new row on dataframe (even address, etc.)
}

# Trims whitespace in order to match with institutions csv
df <- data.frame(lapply(df, trimws), stringsAsFactors = FALSE)

# Returns individual parsed abstract to project folder
fileConn = file("parsed_abstract.csv")
write.csv(df, file='parsed_abstract.csv', row.names = FALSE)
close(fileConn)