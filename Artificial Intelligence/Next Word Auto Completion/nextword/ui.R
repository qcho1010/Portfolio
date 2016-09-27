# setwd("E:/Google Drive/College/1-Data Science/17-Capston/nextword")

suppressPackageStartupMessages(c(library(shinythemes),
                                 library(shiny),
                                 library(tm),
                                 library(stringr),
                                 library(markdown),
                                 library(stylo)))

shinyUI(
     navbarPage(
          "Next Word Auto-Completion",
          theme = shinytheme("flatly"),
          
          tabPanel(
               "APP",
               tags$head(includeScript("./js/ga-shinyapps-io.js")),
               fluidRow(column(4),
                        column(
                             5,
                             tags$div(
                                  
                                  textInput(
                                       "text",
                                       label = h3("Enter your text here:"),
                                       value = ,
                                       width = "100%"
                                  ),
                                   
                                  tags$span(style = "color:grey",("Only English words are supported.")),
                                  tags$br(),
                                  tags$hr(),
                                  
                                  fluidRow(
                                       column(width=1, offset=1, uiOutput("txt1")),
                                       column(width=1, offset=1, uiOutput("txt2")),
                                       column(width=1, offset=1, uiOutput("txt3")),
                                       column(width=1, offset=1, uiOutput("txt4")),
                                       column(width=1, offset=1, uiOutput("txt5"))
                                  ),
                                  align = "center"
                             )
                        ),
                        column(4))
          ),
          
          tabPanel("VISUALIZATION",
                   fluidRow(
                        column(2,
                               p("")),
                        column(8,
                               fluidRow(
                                    column(4,
                                           h3('Word Cloud'),
                                           plotOutput("wordCloud"),
                                           align = "center"
                                    ),
                                    column(4, 
                                           h3('Prediction Plot'),
                                           em('Top 10 Word Predictions vs. MLE score (0-1, 1 = best)'),
                                           plotOutput('myplot',
                                                      height = "400px", width = "600px"),
                                           align = "center"
                                    )      
                               ),
                               tags$br(),
                               tags$hr(),
                               h3('Prediciton Table'),
                               dataTableOutput("predictedWords"),
                               align = "center"
                               ),
                        column(2,
                               p(""))
                   )),
          
          tabPanel("ANALYSIS",
                   fluidRow(
                        column(2,
                               p("")),
                        column(8,
                               includeMarkdown("./report/milestone_report.md")),
                        column(2,
                               p(""))
                   )),
          tabPanel("ABOUT",
                   fluidRow(
                        column(2,
                               p("")),
                        column(8,
                               includeMarkdown("./about/about.md")),
                        column(2,
                               p(""))
                   )),
          
          ############################### ~~~~~~~~F~~~~~~~~ ##############################
          ## Footer
          tags$hr(),
          tags$br(),
          tags$span(
               style = "color:grey",
               tags$footer(("© 2016 - "),
                           tags$a(href = "https://github.com/jamin567/DataScienceCapston",
                                  target = "_blank",
                                  "Kyu S. Cho"),
                           tags$br(),
                           ("Built with"), tags$a(href = "http://www.r-project.org/",
                                                  target = "_blank",
                                                  "R"),
                           ("&"), tags$a(href = "http://shiny.rstudio.com",
                                         target = "_blank",
                                         "Shiny."),
                           align = "center"
               ),
               tags$br()
          )
     )
)
