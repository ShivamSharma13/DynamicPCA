library(shiny)
library(shinythemes)
library(shinycssloaders)


ui <- fluidPage(
    theme = shinytheme("flatly"),
    style='padding:0px;margin:0px;',
    navbarPage("BIOL8803 (2022) Welcome to our PCA app!"),
    fluidRow(align = 'center',
             style='border: 2px solid gray; margin: 4px;',
        column(12, 
               h4("Select 1000 genome populations to include in PCA (Amerindian populations are already selected )", align = 'center'),
               
        ),
        column(1),
        column(2,
               style='border: 2px solid #999999;; margin: 4px; height: 250px;',
               checkboxGroupInput("african_ancestry", 
                                h3("African"), 
                                choices = list("YRI" = "YRI", 
                                                "ESN" = "ESN",
                                                "GWD" = "GWD",
                                                "LWK" = "LWK",
                                                "MSL" = "MSL"))
        ),
        column(2,  
               style='border: 2px solid #999999;; margin: 4px; height: 250px;',
               checkboxGroupInput("european_ancestry", 
                                  h3("European"), 
                                  choices = list("GBR" = "GBR", 
                                                 "TSI" = "TSI",
                                                 "CEU" = "CEU",
                                                 "IBS" = "IBS",
                                                 "FIN" = "FIN"))
        ),
        column(2, 
               style='border: 2px solid #999999;; margin: 4px; height: 250px;',
               checkboxGroupInput("south_asian_ancestry", 
                                  h3("South Asian"), 
                                  choices = list("STU" = "STU", 
                                                 "ITU" = "ITU",
                                                 "GIH" = "GIH",
                                                 "BEB" = "BEB",
                                                 "PJL" = "PJL"))
        ),
        column(2,
               style='border: 2px solid #999999;; margin: 4px; height: 250px;',
               checkboxGroupInput("east_asian_ancestry", 
                                  h3("East Asian"), 
                                  choices = list("CDX" = "CDX", 
                                                 "CHS" = "CHS",
                                                 "JPT" = "JPT",
                                                 "KHV" = "KHV",
                                                 "CHB" = "CHB"))
        ),
        column(2,
               style='border: 2px solid #999999;; margin: 4px; height: 250px;',
               checkboxGroupInput("amerindian_ancestries", 
                                  h3("Amerindian"), 
                                  choices = list("ACB" = "YRI", 
                                                 "ASW" = "ESN",
                                                 "CLM" = "GWD",
                                                 "PUR" = "LWK",
                                                 "PEL" = "PEL",
                                                 "MXL" = "MXL"))
        ),
        column(1),
        
    ),
    fluidRow(align = 'center',
             style='border: 2px solid gray; margin: 4px;',
             
        column(2),
        column(8,

            shinycssloaders::withSpinner(
                plotOutput(outputId = "distPlot", height = "600px"),
                type = 6
            )
        ),
        column(2)
    )
)