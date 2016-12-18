# setwd("~/Documents/archHack/Health_Advisor")
library(shiny)
suppressPackageStartupMessages(c(library(shinythemes),
                                 library(shiny),
                                 library(tm),
                                 library(stringr),
                                 library(markdown),
                                 library(stylo),
                                 library(plotly),
                                 library(caret)))

shinyUI(
  navbarPage(
    "Self-Motivated AI Health Care System",
    theme = shinytheme("flatly"),
    
    tabPanel("INTRO",
             
             fluidRow(
               column(2,
                      p("")),
               column(8,
                      tags$br(),
                      h1("Self-Motivated AI Health Care System"),
                      h2("Predictive Analytics and Preventive Measures"),
                      tags$br(),
                      h4("Imagine we can prevent any potential disease and know sooner than the doctor?"),
                      h4("The average cost of health check up is about 188 dollar. What if we can save that money forever, also have unlimited access to free health check up."),
                      h4("Imagine if we have access to AI-diagnosis system regarding all kinds of diseases?"),
                      h4("Imagine if we have personal one-to-one health care assistent who guides and encourage us and have healthier life?"),
                      h4("Imagine we can prevent any potential disease and know sooner than the doctor?"),
                      h4("This web-app is the prototype of those futuristic idea."),
                      tags$hr(),
                      tags$br(),
                      
                      img(src = "2.jpg", height=800, width=1200)
               ),
               column(2,
                      p(""))
             )
             
    ),
    
    tabPanel("CANCER",
             tags$head(includeScript("./js/ga-shinyapps-io.js")),
             fluidRow(
               
               column(1),
               
               column(9,
                      fluidRow(
                        column(3),
                        column(6,
                          h1("AI Cancer Diagnosis"),
                          align = "center"
                        ),
                        column(3)
                      ),
                      
                      tags$br(),
                      tags$hr(),
                      
                      fluidRow(
                        column(2),
                        
                        column(5,
                               img(src = "5.jpg", height=400, width=600)
                               
                        ),
                        
                        column(3,
                               h3("Preventing Cancer at Earily Stage with AI")
                        )
                      ),
                      
                      tags$br(),
                      tags$hr(),
                      ###################################### 1st layer ######################################
                      fluidRow(
                        column(3,
                               wellPanel(
                                 sliderInput("age", "Age", min=19, max=80, value=c(19)),
                                 plotlyOutput('g_canc_age')),
                               align = "center"
                        ),
                        column(3,
                               wellPanel(
                                 sliderInput("cigarette", "Cigarette per week", min=0, max=10, value=c(2.5)),
                                 plotlyOutput('g_canc_cigarette')),
                               align = "center"
                        ),
                        column(3,
                               wellPanel(
                                 sliderInput("exercise", "Exercise per week", min=0, max=10, value=c(3)),
                                 plotlyOutput('g_canc_exercise')),
                               align = "center"
                        ),
                        column(3,
                               wellPanel(
                                 sliderInput("stress", "Stress level", min=0, max=100, value=c(45)),
                                 plotlyOutput('g_canc_stress')),
                               align = "center"
                        )
                      ),
                      
                      ###################################### 2nd layer ######################################
                      fluidRow(
                        column(3,
                               wellPanel(
                                 sliderInput("grain", "Grain(g) per day", min=0, max=2000, value=c(755)),
                                 plotlyOutput('g_canc_grain')),
                               align = "center"
                        ),
                        column(3,
                               wellPanel(
                                 sliderInput("vegetable", "Vegetable(g) per day", min=0, max=800, value=c(415)),
                                 plotlyOutput('g_canc_vegetable')),
                               align = "center"
                        ),
                        column(3,
                               wellPanel(
                                 sliderInput("meat", "Red meat(lb) per day", min=0, max=1, value=c(.21)),
                                 plotlyOutput('g_canc_meat')),
                               align = "center"
                        ),
                        column(3,
                               wellPanel(
                                 sliderInput("calories", "Calories", min=100, max=6000, value=c(2640)),
                                 plotlyOutput('g_canc_calories')),
                               align = "center"
                        )
                      ),

                      # ###################################### 3rd layer ######################################
                      fluidRow(
                        column(3,
                               wellPanel(
                                 sliderInput("alcohol", "Alcohol(bottle) per week", min=0, max=21, value=c(8)),
                                 plotlyOutput('g_canc_alcohol')),
                               align = "center"
                        ),
                        column(3,
                               wellPanel(
                                 sliderInput("sugar", "Sugar(bottle) per week", min=0, max=40, value=c(14)),
                                 plotlyOutput('g_canc_sugar')),
                               align = "center"
                        ),
                        column(3, 
                               wellPanel(
                                 radioButtons("family_hist", "Have family member with cancer?", list("No"='a', "Yes"='b'),  selected='a')),
                               wellPanel(
                                 radioButtons("male", "Gender", list("Female"='a', "Male"='b'),  selected='a')),
                               align = "center"
                        )
                      ),

                      ###################################### 4th layer ######################################
                      tags$br(),
                      tags$hr(),
                      
                      fluidRow(
                        column(3),
                        column(6,
                               tags$head(tags$script(src = "message-handler.js")),
                               actionButton("submit", "View Result"),
                               align = "center"
                               ),
                        column(3)
                      ),
                      
                      tags$br(),
                      tags$hr(),
                      
                      fluidRow(
                        column(3),
                        column(3,
                               h1("Cancer Risk Rate"),
                               h1(textOutput("text1")),
                               align = "center"
                        ),
                        column(5,
                               h1('Recommandation'),
                               h3(textOutput("text2")),
                               h3(textOutput("text3")),
                               h3(textOutput("text4")),
                               h3(textOutput("text5"))
                               )
                      ),
                      
                      tags$br(),
                      tags$hr(),
                      
                      ####################################### 5th layer ######################################
                      fluidRow(
                               wellPanel(
                                 plotlyOutput('g_canc_future')
                                 ),
                               align = "center"
                      )
               ),
               
               
               column(1)
               )
      
    ),
    
    tabPanel("HEART DISEASE",
             tags$head(includeScript("./js/ga-shinyapps-io.js")),
             fluidRow(
               
               column(1),
               
               column(9,
                      fluidRow(
                        column(3),
                        column(6,
                               h1("AI Heart Disease Diagnosis"),
                               align = "center"
                        ),
                        column(3)
                      ),
                      
                      tags$br(),
                      tags$hr(),
                      
                      fluidRow(
                        column(2),
                        
                        column(5,
                               img(src = "1.jpg", height=400, width=600)
                               
                        ),
                        
                        column(3,
                               h3("Preventing Heart Disease in Earily Stage with AI")
                        )
                      ),
                      
                      tags$br(),
                      tags$hr(),
                      ###################################### 1st layer ######################################
                      fluidRow(
                        column(3,
                               wellPanel(
                                 sliderInput("cholesterol2", "Cholesterol", min=0, max=400, value=c(200)),
                                 plotlyOutput('g_heart_cholesterol')),
                               align = "center"
                        ),
                        column(3,
                               wellPanel(
                                 sliderInput("blood_press2", "Blood Pressure", min=50, max=250, value=c(120)),
                                 plotlyOutput('g_heart_blood_press')),
                               align = "center"
                        ),
                        column(3,
                               wellPanel(
                                 sliderInput("sodium2", "Sodium", min=0, max=3000, value=c(1500)),
                                 plotlyOutput('g_heart_sodium')),
                               align = "center"
                        ),
                        column(3,
                               wellPanel(
                                 sliderInput("age2", "Age", min=19, max=80, value=c(19)),
                                 plotlyOutput('g_heart_age')),
                               align = "center"
                        )
                      ),
                      
                      ###################################### 2nd layer ######################################
                      fluidRow(
                        column(3,
                               wellPanel(
                                 sliderInput("cigarette2", "Cigarette per week", min=0, max=10, value=c(2.5)),
                                 plotlyOutput('g_heart_cigarette')),
                               align = "center"
                        ),
                        column(3,
                               wellPanel(
                                 sliderInput("exercise2", "Exercise per week", min=0, max=10, value=c(3)),
                                 plotlyOutput('g_heart_exercise')),
                               align = "center"
                        ),
                        column(3,
                               wellPanel(
                                 sliderInput("stress2", "Stress level", min=0, max=100, value=c(45)),
                                 plotlyOutput('g_heart_stress')),
                               align = "center"
                        ),
                        column(3,
                               wellPanel(
                                 sliderInput("grain2", "Grain(g) per day", min=0, max=2000, value=c(755)),
                                 plotlyOutput('g_heart_grain')),
                               align = "center"
                        )
                      ),
                      
                      ###################################### 3nd layer ######################################
                      fluidRow(
                        column(3,
                               wellPanel(
                                 sliderInput("vegetable2", "Vegetable(g) per day", min=0, max=800, value=c(415)),
                                 plotlyOutput('g_heart_vegetable')),
                               align = "center"
                        ),
                        column(3,
                               wellPanel(
                                 sliderInput("meat2", "Red meat(lb) per day", min=0, max=1, value=c(.21)),
                                 plotlyOutput('g_heart_meat')),
                               align = "center"
                        ),
                        column(3,
                               wellPanel(
                                 sliderInput("calories2", "Calories", min=100, max=6000, value=c(2640)),
                                 plotlyOutput('g_heart_calories')),
                               align = "center"
                        ),
                        column(3,
                               wellPanel(
                                 sliderInput("alcohol2", "Alcohol(bottle) per week", min=0, max=21, value=c(8)),
                                 plotlyOutput('g_heart_alcohol')),
                               align = "center"
                        )
                      ),
                      
                      # ###################################### 4rd layer ######################################
                      fluidRow(
                        column(3,
                               wellPanel(
                                 sliderInput("sugar2", "Sugar(bottle) per week", min=0, max=40, value=c(14)),
                                 plotlyOutput('g_heart_sugar')),
                               align = "center"
                        ),
                        column(3, 
                               wellPanel(
                                 radioButtons("family_hist2", "Have family member with heart disease?", list("No"='a', "Yes"='b'),  selected='a')),
                               wellPanel(
                                 radioButtons("male2", "Gender", list("Female"='a', "Male"='b'),  selected='a')),
                               align = "center"
                        )
                      ),
                      
                      ###################################### 5th layer ######################################
                      tags$br(),
                      tags$hr(),
                      
                      fluidRow(
                        column(3),
                        column(6,
                               tags$head(tags$script(src = "message-handler.js")),
                               actionButton("submit2", "View Result"),
                               align = "center"
                        ),
                        column(3)
                      ),
                      
                      tags$br(),
                      tags$hr(),
                      
                      fluidRow(
                        column(2),
                        column(4,
                               h1("Heart Disease Risk Rate"),
                               h1(textOutput("text6")),
                               align = "center"
                        ),
                        column(6,
                               h1('Recommandation'),
                               h3(textOutput("text7")),
                               h3(textOutput("text8")),
                               h3(textOutput("text9")),
                               h3(textOutput("text10"))
                        )
                      ),
                      
                      tags$br(),
                      tags$hr(),
                      
                      ####################################### 6th layer ######################################
                      fluidRow(
                        wellPanel(
                          plotlyOutput('g_heart_future2')
                        ),
                        align = "center"
                      )
               ),
               
               
               column(1)
             )
             
             ),
    
    tabPanel("ABOUT",
             
             fluidRow(
               column(2,
                      p("")),
               column(8,
                      includeMarkdown("./about/README.md")),
               column(2,
                      p(""))
             )
             
    ),
    

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
