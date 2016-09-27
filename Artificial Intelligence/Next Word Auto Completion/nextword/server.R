library(shiny)
library(data.table)
library(stylo)
library(wordcloud)
library(RColorBrewer)
library(ggplot2)
library(grid)
library(scales)

## Load the source with the prdict functions
source('predict.R')
shinyServer(function(input, output, session) {
     
     observeEvent(input$text, {
          n <- nchar(input$text)
          
          # Previous input was space
          if (substr(input$text, n, n) == " ") {
               # Next word
               text <- tail(unlist(strsplit(input$text, split = ' ')), 3)
               
               predVal <- predictWord(text)
               predVal2 <<- predVal
               
               output$txt1 <- renderUI({ actionButton("action1", label = predVal[1]) })
               output$txt2 <- renderUI({ actionButton("action2", label = predVal[2]) })
               output$txt3 <- renderUI({ actionButton("action3", label = predVal[3]) })
               output$txt4 <- renderUI({ actionButton("action4", label = predVal[4]) })
               output$txt5 <- renderUI({ actionButton("action5", label = predVal[5]) })

               # get data               
               length = length(text)
               dataDF <- getTable(text, length)
               
               # cloude
               output$wordCloud <- renderPlot({
                    wordcloud(dataDF$output, dataDF$smle, 
                              scale=c(6,1.5), random.order=FALSE, 
                              use.r.layout = FALSE, rot.per = 0.35,
                              colors=brewer.pal(8, "Dark2"), 
                              random.color = TRUE, 
                              max.words = dim(dataDF)[1])
               })
               
               # table
               output$predictedWords <- renderDataTable({dataDF},
                                                        options = list(
                                                             lengthMenu = list(c(10, 20, -1), c('10', '20', 'All')),
                                                             pageLength = 10
                                                        ))
               
               # plot
               output$myplot <- renderPlot({
                    plot  <- ggplot(head(dataDF, 20), aes(x=reorder(output,smle), y=smle, fill=smle)) +
                         geom_bar(stat='identity', alpha=0.9) +
                         labs(y = "\n Maximum Likelihood Estimation") +
                         labs(x = "Prediction") +
                         coord_flip() +
                         scale_fill_gradient2(high = '#08519c') +
                         theme_minimal(base_size = 15) +
                         guides(fill=FALSE) +
                         theme(axis.ticks.x=element_blank()) +
                         theme(axis.ticks.y=element_blank()) +
                         theme(panel.grid.major.y = element_blank()) +
                         theme(panel.grid.major = element_line(color = "black"))
                    gt <- ggplot_gtable(ggplot_build(plot))
                    gt$layout$clip[gt$layout$name == "panel"] <- "off"
                    grid.draw(gt)
               })
               
               
          } else {
               # Auto completion
               text <- tail(unlist(strsplit(input$text, split = ' ')), 1)
               
               predVal <- predictWord2(text)
               predVal3 <<- predVal
               
               output$txt1 <- renderUI({ actionButton("action6", label = predVal[1]) })
               output$txt2 <- renderUI({ actionButton("action7", label = predVal[2]) })
               output$txt3 <- renderUI({ actionButton("action8", label = predVal[3]) })
               output$txt4 <- renderUI({ actionButton("action9", label = predVal[4]) })
               output$txt5 <- renderUI({ actionButton("action10", label = predVal[5]) })
          }
     })
     
     observeEvent(input$action1, {
          updateTextInput(session,"text", value = paste0(str_trim(input$text), " ", predVal2[1], sep=" "))
     })
     observeEvent(input$action2, {
          updateTextInput(session,"text", value = paste0(str_trim(input$text), " ", predVal2[2], sep=" "))
     })
     observeEvent(input$action3, {
          updateTextInput(session,"text", value = paste0(str_trim(input$text), " ", predVal2[3], sep=" "))
     })
     observeEvent(input$action4, {
          updateTextInput(session,"text", value = paste0(str_trim(input$text), " ", predVal2[4], sep=" "))
     })
     observeEvent(input$action5, {
          updateTextInput(session,"text", value = paste0(str_trim(input$text), " ", predVal2[5], sep=" "))
     })
     observeEvent(input$action6, {
          idx <- length(gregexpr(" ", input$text)[[1]])
          idx <- gregexpr(" ", input$text)[[1]][idx]
          updateTextInput(session,"text", value = paste(substr(input$text, 1, idx), predVal3[1], " ", sep=""))
     })
     observeEvent(input$action7, {
          idx <- length(gregexpr(" ", input$text)[[1]])
          idx <- gregexpr(" ", input$text)[[1]][idx]
          updateTextInput(session,"text", value = paste(substr(input$text, 1, idx), predVal3[2], " ", sep=""))
     })
     observeEvent(input$action8, {
          idx <- length(gregexpr(" ", input$text)[[1]])
          idx <- gregexpr(" ", input$text)[[1]][idx]
          updateTextInput(session,"text", value = paste(substr(input$text, 1, idx), predVal3[3], " ", sep=""))
     })
     observeEvent(input$action9, {
          idx <- length(gregexpr(" ", input$text)[[1]])
          idx <- gregexpr(" ", input$text)[[1]][idx]
          updateTextInput(session,"text", value = paste(substr(input$text, 1, idx), predVal3[4], " ", sep=""))
     })
     observeEvent(input$action10, {
          idx <- length(gregexpr(" ", input$text)[[1]])
          idx <- gregexpr(" ", input$text)[[1]][idx]
          updateTextInput(session,"text", value = paste(substr(input$text, 1, idx), predVal3[5], " ", sep=""))
     })
})