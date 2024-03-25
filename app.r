library(shinydashboard)
library(shiny)
library(shinyalert)
library(keras)
library(mlbench)
library(dplyr)
library(caret)
library(magrittr)
library(neuralnet)
library(plotly)
library(tidyverse)
library(imputeTS)
ui <- dashboardPage(
  dashboardHeader(),
  dashboardSidebar(
    menuItem("Welcome", tabName = "Welcome", icon = icon("dashboard")),
    menuItem("Dashboard", tabName = "dashboard", icon = icon("dashboard")),
    menuItem("Widgets", tabName = "widgets", icon = icon("th"))
  ),
  dashboardBody(
    tabItems(
      tabItem(tabName = "Welcome",
    fluidRow(
      tabPanel(title = "Home",
               imageOutput("home_img")
      )
    )
  ),
  tabItem(tabName = "dashboard",
          fluidRow(
            tabBox(width="100%",height = "100%",
              title = "Exploratory Analysis",
              # The id lets us use input$tabset1 on the server to find the current tab
              id = "tabset1",
              tabPanel("Map", 
                       plotlyOutput("graph_map")
                       ),
              tabPanel("Tab2",
                       plotlyOutput("plotly1")
                       ),
              tabPanel("Tab3",
                       plotlyOutput("plotly2")
              ),
              tabPanel("Tab4",
                       plotlyOutput("plotly3")
              ),
              tabPanel("Tab5",
                       plotlyOutput("plotly4")
              ),
              tabPanel("Tab6",
                       plotlyOutput("plotly5")
              ),
              tabPanel("Tab7",
                       plotlyOutput("plotly6")
              )
            )
          )
  ),
  tabItem(tabName = "widgets",
          fluidRow(
            tags$style(type = "text/css",
                       "label { font-size: 20px; }"
            ),
            box(width="100%",column(width = 4,
                  selectInput("location", 
                      label = "Choose location",
                      choices = c('RHODE ISLAND', 'PENNSYLVANIA', 'MARYLAND', 'CONNECTICUT', 'NEW YORK',
                                  'MASSACHUSETTS', 'NEW JERSEY'),
                      selected = "Percent White"),
          selectInput("gender",
                       label = "Select Gender:",
                       choices = c("male", "female")),
          selectInput("married",
                       label = "Select Married:",
                       choices = c("Married", "Not_Married")),
          selectInput("smoker",
                      label = "Smoker",
                      choices = c("yes", "no")),
          selectInput("model", 
                      label = "Choose Model",
                      choices = c('decision_tree_model_expensive', 'glm_logit_expensive', 
                                  'glm_probit_expensive', 'neural_network_model_expensive',
                                  'random_forest_model_expensive','svm_model_expensive')),
          actionButton("predict", "Predict")
          ),
          column(width = 4,
                 numericInput("age","Age", value = 1),
                 selectInput("education_level", 
                             label = "Choose Education",
                             choices = c('No College Degree', 'Bachelor', 
                                         'PhD', 'Master')),
                 selectInput("yearly_physical",
                              label = "Select yearly_physical:",
                              choices = c("Yes","No")),
                 sliderInput("children", "Children:",
                             min = 0, max = 10,
                             value = 2)
          ),
          column(width = 4,
                 numericInput("bmi","BMI", value = 1),
                 selectInput("exercise",
                       label = "Select Exercise:",
                       choices = c("Not-Active", "Active")),
                 selectInput("location_type",
                       label = "Select location_type:",
                       choices = c("Urban", "Country")),
                 radioButtons("hypertension",
                              label = "Select Hypertension:",
                              choices = list("Yes" = 1, "No" = 0),selected = 1)
            
  ))
          )
  )
  )
  )
)


server <- function(input, output,session) { 
  output$home_img <- renderImage({
    
    list(src = "www/SEO-865-bs-Doctor-With-Medical-Healthcare-213017662-1200x675.jpeg",
         width = "100%",
         height = 500
         )
    
  }, deleteFile = F)
  
  observeEvent(input$predict, {
    age = input$age
    bmi = input$bmi
    exercise = input$exercise
    location_type = input$location_type
    yearly_physical = input$yearly_physical
    education_level = input$education_level
    model = input$model
    married = input$married
    children = input$children
    gender = input$gender
    hypertension = input$hypertension
    location = input$location
    smoker = input$smoker
    
    df_pred <- data.frame(X = 1000000,
               age = as.integer(age),
               bmi = as.numeric(bmi),
               children = as.character(children),
               location = as.character(location),
               smoker = as.character(smoker),
               location_type = as.character(location_type),
               education_level = as.character(education_level),
               yearly_physical = as.character(yearly_physical),
               exercise = as.character(exercise),
               married = as.character(married),
               hypertension = as.character(hypertension),
               gender = as.character(gender),
               smoker = as.character(smoker)
               )
    
    read_model = paste0(as.character(model),".rds")
    read_model = paste0("/Users/aatmajjanardanan/Desktop/R_dash/",read_model)
    my_model <- readRDS(read_model)
    print(read_model)
    if (model == "neural_network_model_expensive") {
      my_model <- load_model_tf("/Users/aatmajjanardanan/Desktop/R_dash/neural_network_model_expensive_1.1")
      m <- readRDS("/Users/aatmajjanardanan/Desktop/R_dash/column_means_nn.rds")
      s <- readRDS("/Users/aatmajjanardanan/Desktop/R_dash/column_sd_nn.rds")
      dummy <- readRDS("/Users/aatmajjanardanan/Desktop/R_dash/dummies_nn.rds")
      df_pred$cost <- 0
      df_pred$expensive <- 0
      df_1_c_pred <- data.frame(predict(dummy, newdata=df_pred))
      df_pred_c <- scale(df_1_c_pred %>% subset(select = - c(X, cost, expensive)), center = m, scale = s)
      test_y_pred <- as.numeric(my_model %>% predict(df_pred_c) > 0.5)
      }else if (model == "decision_tree_model_expensive"){
      test_y_pred <- predict(my_model, newdata = df_pred, type = "class")
    }else if (model == "svm_model_expensive"){
      test_y_pred < - as.numeric(predict(my_model,newdata = df_test) > 0.5)
    }
    else{
      test_y_pred <- as.numeric(predict(my_model, newdata = df_pred, type = "response") > 0.5)
    }
    if (test_y_pred == 1){
      shinyalert("This customer will spend a significant amount of money on healthcare next year", type = "success")
    } else {
      shinyalert("This customer will not spend a significant amount of money on healthcare next year", type = "error")
    }
    
  })
  source <- "https://intro-datascience.s3.us-east-2.amazonaws.com/HMO_data.csv"
  df <- read_csv(source)
  df$children <- as.factor(df$children) 
  df$smoker <- as.factor(df$smoker) 
  df$location <- as.factor(df$location)
  df$location_type <- as.factor(df$location_type) 
  df$education_level <- as.factor(df$education_level) 
  df$yearly_physical <- as.factor(df$yearly_physical) 
  df$exercise <- as.factor(df$exercise) 
  df$married <- as.factor(df$married) 
  df$hypertension <- as.factor(df$hypertension) 
  df$gender <- as.factor(df$gender) 
  
  df$hypertension <- replace_na(df$hypertension, as.factor(0))
  df$bmi <- na_interpolation(df$bmi)
  
  output$graph_map <- renderPlotly({
    df_gr <- df %>% group_by(location) %>% summarize(smoker_perc = sum(smoker == "yes")/n()*100,
                                                     hypertension_perc = sum(hypertension == 1)/n()*100,
                                                     yearly_physical_perc = sum(yearly_physical == "Yes")/n()*100,
                                                     active_perc = sum(exercise == "Active")/n()*100,
                                                     avg_age = mean(age),
                                                     avg_bmi = mean(bmi),
                                                     count = n(),
                                                     avg_cost = mean(cost)
    )
    
    df_gr$hover <- with(df_gr, paste(location, '<br>',
                                     "count", count, "<br>",
                                     "smoker_perc", round(smoker_perc,2), "<br>",
                                     "hyoertension_perc", round(hypertension_perc,2), "<br>",
                                     "yearly_physical_perc", round(yearly_physical_perc,2), "<br>",
                                     "active_perc", round(active_perc,2), "<br>",
                                     "avg_age", round(avg_age,2), "<br>",
                                     "avg_bmi", round(avg_bmi,2), "<br>",
                                     "avg_cost", round(avg_cost,2), "<br>"
    ))
    
    df_sc<- read.csv("https://raw.githubusercontent.com/plotly/datasets/master/2011_us_ag_exports.csv")
    
    df_sc <- df_sc[,c("state", "code")]
    df_sc$state <- tolower(df_sc$state)
    
    df_gr$state<- tolower(df_gr$location)
    
    df_gr <- merge(df_gr,df_sc,by.x="state",by.y="state")
    
    # give state boundaries a white border
    l <- list(color = toRGB("white"), width = 2)
    # specify some map projection/options
    g <- list(
      scope = 'usa',
      projection = list(type = 'albers usa'),
      showlakes = TRUE,
      lakecolor = toRGB('white')
    )
    fig <- plot_geo(df_gr, locationmode = 'USA-states')
    fig <- fig %>% add_trace(
      z = ~avg_cost, text = ~hover, locations = ~code,
      color = ~avg_cost, colors = 'Purples'
    )
    fig <- fig %>% colorbar(title = "Average Cost")
    fig <- fig %>% layout(
      title = 'Summary Statistics of All States',
      geo = g
    )
    fig
  }
  )
  
  output$plotly1 <- renderPlotly({
    fig <- plot_ly(df, y = ~cost, color = ~smoker, type = "box")
    fig <- fig %>% layout(title = "Variation in Cost in smokers and non smokers")
    fig
  })
  
  output$plotly2 <- renderPlotly({
    fig <- plot_ly(df, y = ~cost, color = ~children, type = "box")
    fig <- fig %>% layout(title = "Cost vs Number of Children")
    fig
  })
  
  output$plotly3 <- renderPlotly({
    fig <- plot_ly(df, y = ~cost, color = ~exercise, type = "box", boxpoints = 'all')
    fig <- fig %>% layout(title = "Cost vs Exercise")
    fig
  })
  
  output$plotly4 <- renderPlotly({
    fig <- plot_ly(df, x =~age, y = ~cost, color = ~exercise, type = 'scatter')
    fig <- fig %>% layout(title = "Cost vs Age")
    fig
    
  })
  
  output$plotly5 <- renderPlotly({
    fig <- plot_ly(df, x = ~children, y = ~cost, color = ~smoker, type = "box")
    fig <- fig %>% layout(boxmode = "group")
    fig
  })
  
  output$plotly6 <- renderPlotly({
    fig <- plot_ly(alpha = 0.6)
    fig <- fig %>% add_histogram(x = df[df$exercise == "Active",]$cost, name = "Active")
    fig <- fig %>% add_histogram(x = df[df$exercise == "Not-Active",]$cost, name = "Not Active")
    fig <- fig %>% layout(barmode = "stack")
    fig
  })
  
  
  }

shinyApp(ui, server)