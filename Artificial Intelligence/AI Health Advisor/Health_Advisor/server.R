library(shiny)
library(plotly)
library(mlr)


## Load the source with the prdict functions
source('canc_predict.R')
source('heart_predict.R')
shinyServer(function(input, output) {
  
  ###################################### Cancer ######################################
  ###################################### 2nd layer ######################################
  output$g_canc_age <- renderPlotly({
    g_canc_age +
      geom_vline(xintercept=input$age, color="red", size=1)
  })
  output$g_canc_cigarette <- renderPlotly({
    g_canc_cigarette +
      geom_vline(xintercept=input$cigarette, color="red", size=1)
  })
  output$g_canc_exercise <- renderPlotly({
    g_canc_exercise +
      geom_vline(xintercept=input$exercise, color="red", size=1)
  })
  
  ####################################### 3rd layer ######################################
  output$g_canc_stress <- renderPlotly({
    g_canc_stress +
      geom_vline(xintercept=input$stress, color="red", size=1)
  })
  output$g_canc_grain <- renderPlotly({
    g_canc_grain +
      geom_vline(xintercept=input$grain, color="red", size=1)
  })
  output$g_canc_vegetable <- renderPlotly({
    g_canc_vegetable +
      geom_vline(xintercept=input$vegetable, color="red", size=1)
  })
  output$g_canc_meat <- renderPlotly({
    g_canc_meat +
      geom_vline(xintercept=input$meat, color="red", size=1)
  })
  
  ####################################### 4th layer ######################################
  output$g_canc_calories <- renderPlotly({
    g_canc_calories +
      geom_vline(xintercept=input$calories, color="red", size=1)
  })
  output$g_canc_alcohol <- renderPlotly({
    g_canc_alcohol +
      geom_vline(xintercept=input$alcohol, color="red", size=1)
  })
  output$g_canc_sugar <- renderPlotly({
    g_canc_sugar +
      geom_vline(xintercept=input$sugar, color="red", size=1)
  })
  
  ###################################### 5th layer ######################################
  global_inputs <- c()
  observeEvent(input$submit, {
    output$text1 <- renderText({
      inputs <- c("family_hist"=input$family_hist,"male"=input$male, 
                  "age"=input$age, "cigarette"=input$cigarette,
                  "exercise"=input$exercise, "stress"=input$stress, 
                  "grain"=input$grain, "vegetable"=input$vegetable,
                  "meat"=input$meat, "calories"=input$calories, 
                  "alcohol"=input$alcohol, "sugar"=input$sugar)
      
      pred <- prediction(inputs)

      # recomandation      
      if (pred[1, 2] > 50) {
        output$text2 <- renderText({
          "Client's disease risk rate is unusally higher than normal. We highly recommand client to do health checkup with Doctor AS SOON AS POSSIBLE."
        })
      } else if (pred[1, 2] < 20) {
        output$text2 <- renderText({
          "Client is enjoying healthy life style :)"
        })
      } else {
        output$text2 <- renderText({
          "Client is being exposed to disease risk."
        })
      }
      if (input$cigarette > 6) {
        output$text3 <- renderText({
          "Cigarette : Consuming more cigarette than recommended amount."
        })
      }
      if (input$stress > 60) {
        output$text4 <- renderText({
          "Stress : Over stressed"
        })
      }
      if (input$alcohol > 8) {
        output$text5 <- renderText({
          "Alcohol : Consuming more alcohol than recommended amount."
        })
      }
      
      # display time series prediction
      output$g_canc_future <- renderPlotly({
        ggplot(pred, aes(x=age, y=risk_rate)) +
          geom_line(colour="red", size=1) +
          ylab("Cancer Risk Rate")
      })
      
      return(paste(pred[1, 2], "%"))
    })  

  })

  
    
  
  
  ###################################### Heart ######################################
  ###################################### 2nd layer ######################################
  output$g_heart_cholesterol <- renderPlotly({
    g_heart_cholesterol +
      geom_vline(xintercept=input$cholesterol2, color="red", size=1)
  })
  output$g_heart_blood_press <- renderPlotly({
    g_heart_blood_press +
      geom_vline(xintercept=input$blood_press2, color="red", size=1)
  })
  output$g_heart_sodium <- renderPlotly({
    g_heart_sodium +
      geom_vline(xintercept=input$sodium2, color="red", size=1)
  })
  
  output$g_heart_age <- renderPlotly({
    g_heart_age +
      geom_vline(xintercept=input$age2, color="red", size=1)
  })
  
  ####################################### 3rd layer ######################################
  output$g_heart_cigarette <- renderPlotly({
    g_heart_cigarette +
      geom_vline(xintercept=input$cigarette2, color="red", size=1)
  })
  output$g_heart_exercise <- renderPlotly({
    g_heart_exercise +
      geom_vline(xintercept=input$exercise2, color="red", size=1)
  })
  output$g_heart_stress <- renderPlotly({
    g_heart_stress +
      geom_vline(xintercept=input$stress2, color="red", size=1)
  })
  output$g_heart_grain <- renderPlotly({
    g_heart_grain +
      geom_vline(xintercept=input$grain2, color="red", size=1)
  })

    ####################################### 4th layer ######################################
  output$g_heart_vegetable <- renderPlotly({
    g_heart_vegetable +
      geom_vline(xintercept=input$vegetable2, color="red", size=1)
  })
  output$g_heart_meat <- renderPlotly({
    g_heart_meat +
      geom_vline(xintercept=input$meat2, color="red", size=1)
  })
  output$g_heart_calories <- renderPlotly({
    g_heart_calories +
      geom_vline(xintercept=input$calories2, color="red", size=1)
  })
  output$g_heart_alcohol <- renderPlotly({
    g_heart_alcohol +
      geom_vline(xintercept=input$alcohol2, color="red", size=1)
  })
  output$g_heart_sugar <- renderPlotly({
    g_heart_sugar +
      geom_vline(xintercept=input$sugar2, color="red", size=1)
  })
  
  ###################################### 5th layer ######################################
  observeEvent(input$submit2, {
    output$text6 <- renderText({
      inputs <- c("family_hist"=input$family_hist2,"male"=input$male2, 
                  "age"=input$age2, "cigarette"=input$cigarette2,
                  "exercise"=input$exercise2, "stress"=input$stress2, 
                  "grain"=input$grain2, "vegetable"=input$vegetable2,
                  "meat"=input$meat2, "calories"=input$calories2, 
                  "alcohol"=input$alcohol2, "sugar"=input$sugar2,
                  "cholesterol"=input$cholesterol2, "blood_press"=input$blood_press2,
                  "sodium"=input$sodium2)
      
      pred <- prediction2(inputs)
      
      # recomandation      
      if (pred[1, 2] > 50) {
        output$text7 <- renderText({
          "Client's disease risk rate is unusally higher than normal. We highly recommand client to do health checkup with Doctor AS SOON AS POSSIBLE."
        })
      } else if (pred[1, 2] < 20) {
        output$text7 <- renderText({
          "Client is enjoying healthy life style :)"
        })
      } else {
        output$text7 <- renderText({
          "Client is being exposed to disease risk."
        })
      }
      if (input$cigarette2 > 6) {
        output$text8 <- renderText({
          "Cigarette : Consuming more cigarette than recommended amount."
        })
      }
      if (input$stress2 > 60) {
        output$text9 <- renderText({
          "Stress : Over stressed"
        })
      }
      if (input$alcohol2 > 8) {
        output$text10 <- renderText({
          "Alcohol : Consuming more alcohol than recommended amount."
        })
      }
      
      # display time series prediction
      output$g_heart_future2 <- renderPlotly({
        ggplot(pred, aes(x=age, y=risk_rate)) +
          geom_line(colour="red", size=1) +
          ylab("Heart Disease Risk Rate")
      })
      
      return(paste(pred[1, 2], "%"))
    })  
    
  })
  
})
