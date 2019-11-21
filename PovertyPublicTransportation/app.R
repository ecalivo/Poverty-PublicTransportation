#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(sf)
library(fs)


# Define UI for application that draws a histogram
ui <- navbarPage("Poverty & Public Transportation in Silicon Valley",
                 tabPanel("About", HTML('<center><img src = "https://upload.wikimedia.org/wikipedia/commons/e/eb/View_from_Communications_Hill_%28cropped%29.jpg",
                                        width = "100%", height = "100%"></center>'),
                          p("I grew up in San Jose, at the southern end of the San Francisco Bay Area. Growing up, both of my parents worked for public transportation companies, which meant
                            that I became familiar with taking public buses and trains pretty early on in my childhood. While I thought the idea of intricate networks of interconnectedness were
                            fascinating and exciting, I quickly learned that many people did not feel the same way. Instead, public transportation was thought of as inefficient, unsanitary, and 
                            associated with poverty and low socioeconomic status."),
                          p("This is a view that is commonly taken across the United States, and especially in the car-happy state of California. However, it is one that is rapidly changing. 
                            Given the rapid population growth in the area combined with movements to exurbs and towns on the Bay's periphery, one of these areas is public transportation. A Bay 
                            Area that moves faster and more efficiently is in the interest of all residents, providing a path towards decreased dependencies on cars, greater regional cooperation in 
                            one of the nation's most important megalopolises, and encouraging urban design that is heavily focused on walkability, productive interpersonal interaction, and environmental sustainability."),
                          p("This is an issue that I've thought about almost my entire life: both of my parents worked for public transit agencies during my childhood, giving me a somewhat unique insight into the ways that 
                            certain populations rely on transit to get around. Here at Harvard, I have pursued urban studies through the Government and History of Art and Architecture departments, allowing me to learn more 
                            about how urban infrastructure, including public transit, shape the way that people live, work, and thrive."),
                          p("In order to improve these infrastructures, we have to know how they currently work -- and don't work. Enter this project, which was created by Emmanuel Calivo (eacalivo@gmail.com). I took data from 
                            the open data portal for the Santa Clara Valley Transportation Authority (VTA), as well as the government of Santa Clara County and the Census Brueau, in order to see if there is a relationship between
                            access to public transit and median income levels."),


                 ),
                 tabPanel("Data & Map",
                          leafletOutput("map", height = 500)
                 ),
                 tabPanel("Model",
                          textOutput("text")
                 )
)

# Define server logic required to draw a histogram
server <- function(input, output, session) {
  output$map <- renderLeaflet({
    leaflet() %>% 
      addProviderTiles("Stamen.Terrain") %>% 
      addPolygons(data = zip_list,
                  color = "black",
                  weight = 1.5,
                  opacity = 1,
                  fillColor = "white",
                  fillOpacity = 0.5,
                  highlightOptions = highlightOptions(color = "red"),
                  popup = ~ZCTA, ~stop_count) %>%
      addCircleMarkers(data = bus_stop_geojson,
                       radius = 4,
                       popup = ~stopname,
                       color = "navy",
                       fillColor = "navy",
                       clusterOptions = markerClusterOptions())
      })
  
  output$text <- renderText({
    "I've had continued trouble getting the model to perform the way that it should, but I intend to conduct a linear regression in order to see what sort
    of correlation exists between access to public transit and median household income levels."
  })
}

# Run the application 
shinyApp(ui = ui, server = server)


