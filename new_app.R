#--- library ---#
library(shiny)
library(DBI)
library(rJava)
library(RJDBC)
library(RWeka)
library(ggplot2)

#--- Configuration ---#
dbjarhome <- c('C:/Program Files/Java/jdk1.8.0_91/jre','D:/ojdbc14-10.2.0.4.0.jar') 
urldetails <- c('oracle.jdbc.driver.OracleDriver','jdbc:oracle:thin:@ip:port','username','password')
options(java.parameters="-Xmx6g")
Sys.setenv(JAVA_HOME=dbjarhome[[1]])

ui <- fluidPage(
  titlePanel("No of rows in the table : "),
  numericInput("nrows", "Enter the number of rows to display:", 1000),
  textInput("text", "Enter the Day:", "Tuesday"),
  
  plotOutput("plot"),
  tableOutput("tbl")
)

server <- function(input, output, session) {
  output$plot <- renderPlot({
    # Add a little noise to the cars data
    drv = JDBC(urldetails[[1]],dbjarhome[[2]], identifier.quote='`')
    conn <- dbConnect(drv, urldetails[[2]], urldetails[[3]], urldetails[[4]])
    on.exit(dbDisconnect(conn), add = TRUE)
    query <- c(paste0("SELECT * FROM TABLE where DAY IN (","'",c(input$text),"'",")"))
    rs = dbSendQuery(conn, query)
    firstBatch = fetch(rs, n = input$nrows)
    open <- firstBatch
    
    #--- plotting ---#
    ggplot(open, aes(x=UNIQUECLICK, y=TOTALCLICK)) + 
      geom_boxplot(outlier.colour="red", outlier.shape=8,outlier.size=4)+
      geom_text(aes(label = open$TEMPLATE_NAME), vjust = 1)
    
  },height = 400, width = 600)
    output$tbl <- renderTable({
    drv = JDBC(urldetails[[1]],dbjarhome[[2]], identifier.quote='`')
    conn <- dbConnect(drv, urldetails[[2]], urldetails[[3]], urldetails[[4]])
    on.exit(dbDisconnect(conn), add = TRUE)
    query <- c(paste0("SELECT * FROM TABLE where DAY IN (","'",c(input$text),"'",")"))
    rs = dbSendQuery(conn, query)
    firstBatch = fetch(rs, n = input$nrows)
  })

}

shinyApp(ui, server)
