library(shiny)
library(tidyverse)

# Reads in two datasets: top_institutions and df2_combined
top_institutions_shiny <- as.tibble(read.csv("top_institutions.csv"))
colnames(top_institutions_shiny) <- c("Institution", "Collaborations")
df2_combined_shiny <- as.tibble(read.csv("df2_combined.csv"))

# This function takes in a long string and outputs a list of the top 10 words and their frequencies, ignoring some common words
wordcounts1 <- function(input) {
  sentences <- gsub("\\.", "", input)
  sentences <- gsub("\\,", "", sentences)
  words <- strsplit(sentences, " ")
  words.freq <- table(unlist(words))
  table <- as.tibble(cbind.data.frame(names(words.freq),as.integer(words.freq)))
  colnames(table) <- c("word", "count")
  common_words <- c("the", "be", "to", "of", "and", "a", "in", "that", "have", "i",
                    "it", "for", "not", "on", "with", "as", "do", "at", "this", "but",
                    "by", "from", "they", "we", "or", "an", "will", "my", "one", "were",
                    "was", "is", "had", "are", "both", "95%", "than", "between", "may",
                    "among", "=", "ci", "these", "has", "cin2", "1", "2", "3", "4", "p", "(p",
                    "open", "after", "hr", "(hr", "us", "h", "bc", "no", "blfc", "(95%")
  table <- table %>% arrange(desc(count)) %>% filter(!word %in% common_words)
  return(table[1:10,])
}

# This function uses the last function, but passes to it a single institution so that the outputted top 10 words are specific to a certain institution
find_wordcounts1 <- function(dataframe, institution) {
  row <- dataframe %>%
    filter(collaborators == institution)
  abs <- row[[2]]
  return (wordcounts1(abs))
}

# Main panel consists of two things: The list of UNC's top collaborations, and a graph of top keywords associated with a single institution from the list
ui <- fluidPage(
  mainPanel(
    h2("Top Collaborating Institutions with UNC:"),
    dataTableOutput(outputId = "top10table"),
    p(""),
    p("As expected initially, there are a large amount of research collaborations with Duke University. It was interesting to note that NC State did not make the list, at least with regard to the research abstracts selected for this analysis. The only Ivy League institution in the top 10 is Harvard University, but the strength of the remaining collaborations suggest that UNC is in a high tier of research, associated with some of the United States' leading universities and institutions."),
    h3("Choose an institution from the above list to view associated keywords:"),
    uiOutput("choose_institution"),
    plotOutput(outputId = "topwords"),
    p("From the above graphs, we notice that for the top ten instituions, an overwhelming number of abstracts deal with the subject of cancer. Specifically, we observe many mentions of breast cancer. Many also mention data, suggesting the usage of statistical analyses across multiple absracts. It is interesting to note that only Baylor's top 10 words included anything related to genetics, suggesting that Baylor is an important collaborator for UNC with regards to genetics studies. It would be worthwhile to further this analysis by including many more abstracts in the original dataset, potentially across multiple UNC departments, to historically view the university's most important collaborations over time.")
  )
)

# Server side creates a list of top institutions, and also creates a ggplot (bar graph) using top words
server <- function(input, output) {
  output$top10table <- renderDataTable({top_institutions_shiny[1:10,]},
                                       options = list(info = FALSE,
                                                      searching = FALSE,
                                                      paging = FALSE))
  output$choose_institution <- renderUI({
    selectInput("clicked_institution", "Institution", as.list(top_institutions_shiny[1:10,1]), selected = NULL)
    # Above imports the list of top 10 institutions into the dropdown input that users can choose from
  })
  output$topwords <- renderPlot({
    # Edits final dataset for use in top words bar graph
    institution_words <- find_wordcounts1(df2_combined_shiny,input$clicked_institution)
    institution_words$word <- factor(institution_words$word, levels = institution_words$word)
    # Code to create final bar plot from latest data
    ggplot(institution_words, aes(x = word, y = count, fill = word)) + 
      geom_bar(stat = "identity") +
      coord_flip() +
      xlab("Keyword") +
      ylab("Number of Mentions") +
      scale_fill_discrete(guide = FALSE) +
      scale_x_discrete(limits = rev(levels(institution_words$word)))
  })
}

# Needed to run RShiny app
shinyApp(ui = ui, server = server)