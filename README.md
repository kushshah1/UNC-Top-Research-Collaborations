# UNC's Top Research Collaborations and Research Topics
Repository: project-3-kshah1996

This project outputs an RShiny application that describes UNC's Top 10 research collaborations from a selected subset of research abstracts, along with the most frequent keywords associated with the abstracts from each institution.

To run this project, enter the following Shell command from the base directory of the project: `nextflow main.nf`. Then, two csvs are created (df2_combined.csv & top_institutions.csv), which are the required input datasets for the Shiny app to run (app.R). To run the RShiny application, enter the following Shell command: `docker run -d -p 3838:3838 -p 8787:8787 -e ADD=shiny -e PASSWORD=1234 -v $(pwd):/srv/shiny-server rocker/tidyverse`. Open a browser tab and access the following port: `http://<instance>:3838/`

Summary of contents:
- baseDir: `main.nf`, `app.R` [files] `bin`, `data` [folders]
- baseDir/data: `abstracts`, `institutions` [folders]
- baseDir/data/abstracts: initial input text files containing summary of multiple abstracts
- baseDir/data/institutions: input csv containing information about official US institutions
- baseDir/bin: multiple R scripts that process the input data and create output csvs needed for Shiny app to run
