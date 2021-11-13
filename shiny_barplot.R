library(stringr)
library(dplyr)
library(gridExtra)
library(grid)
library(ggplot2)
library(shiny)
select <- dplyr::select

d.state <- read_csv("./derived_data/Salary_State.csv")
d.major <- d.state %>% filter(O_GROUP == "major") %>% mutate(SOC = str_sub(OCC_CODE, 1, 2))


# Define Barplot function==================================================

make.barplot <- function(OCC_input="11-0000", title = "", legtitle = "Mean Hourly Wage") {

  d <- d.major %>%
    filter(SOC == OCC_input) %>%
    group_by(PRIM_STATE) %>%
    summarise(emp = sum(TOT_EMP), h_mean = mean(H_MEAN),
              a_mean = mean(A_MEAN)) %>%
    arrange(desc(emp))

  g.mid <-ggplot(data = d,aes(x=1,y=reorder(PRIM_STATE, emp)))+
    geom_text(aes(label=PRIM_STATE))+
    geom_segment(aes(x=0.94,xend=0.96,yend=PRIM_STATE))+
    geom_segment(aes(x=1.04,xend=1.065,yend=PRIM_STATE))+
    ggtitle("")+
    ylab(NULL)+
    scale_x_continuous(expand=c(0,0),limits=c(0.94,1.065))+
    theme(axis.title=element_blank(),
          panel.grid=element_blank(),
          axis.text.y=element_blank(),
          axis.ticks.y=element_blank(),
          panel.background=element_blank(),
          axis.text.x=element_text(color=NA),
          axis.ticks.x=element_line(color=NA),
          plot.margin = unit(c(1,-1,1,-1), "mm"))

  g1 <- ggplot(data = d, aes(x = reorder(PRIM_STATE, emp), y = emp)) +
    geom_bar(stat = "identity") + ggtitle("Total Employment") +
    theme(axis.title.x = element_blank(),
          axis.title.y = element_blank(),
          axis.text.y = element_blank(),
          axis.ticks.y = element_blank(),
          plot.margin = unit(c(1,-1,1,0), "mm")) +
    scale_y_reverse() + coord_flip()

  g2 <- ggplot(data = d, aes(x = reorder(PRIM_STATE, emp), y = h_mean)) +xlab(NULL)+
    geom_bar(stat = "identity") + ggtitle("Mean hourly wage") +
    theme(axis.title.x = element_blank(), axis.title.y = element_blank(),
          axis.text.y = element_blank(), axis.ticks.y = element_blank(),
          plot.margin = unit(c(1,0,1,-1), "mm")) +
    coord_flip()

  gg1 <- ggplot_gtable(ggplot_build(g1))
  gg2 <- ggplot_gtable(ggplot_build(g2))
  gg.mid <- ggplot_gtable(ggplot_build(g.mid))

  p <- grid.arrange(gg1,gg.mid,gg2,ncol=3,widths=c(4/9,1/9,2/9)) +
    coord_fixed(ratio = 5)
  print(p)
}

# Define ui and server ====================================================

ui <- fluidPage(

  titlePanel(
    h3("Total Employment and Hourly Wage by State within an Occupation"),
    br()),

  sidebarLayout(

    sidebarPanel(

      selectInput("code",
                  label = "Choose an Occupation (SOC Code)",
                  choices = c("11", "13", "15", "17", "19", "21", "23", "25",
                              "27", "29", "31", "33", "35", "37", "39", "41",
                              "43", "45", "47", "49", "51", "53")
      ),

      tags$div(
        tags$a(href= "https://www.bls.gov/oes/special.requests/oesm20all.zip",
               "Source Data"),
        tags$p("from U.S. BUREAU OF LABOR STATISTICS")),
      br(), br(), br(),


      p('11  -  Management'),
      p('13  -  Finance'),
      p('15  -  CS and Math'),
      p('17  -  Architecture and Engineering'),
      p('19  -  Science'),
      p('21  -  Social Service'),
      p('23  -  Legal'),
      p('25  -  Education'),
      p('27  -  Arts'),
      p('29  -  Healthcare Practitioners'),
      p('31  -  Healthcare Support'),
      p('33  -  Protective Service'),
      p('35  -  Food'),
      p('37  -  Building'),
      p('39  -  Personal Care'),
      p('41  -  Sales'),
      p('43  -  Administry'),
      p('45  -  Farming'),
      p('47  -  Install'),
      p('49  -  Maintenance'),
      p('51  -  Production'),
      p('53  -  Transportation')
    ),

    mainPanel(
      h1(textOutput("codeval")),
      br(),

      plotOutput("barplot", height = "800", width = "400"),

      br(),
      br(),

      h3("Summary Table"),
      dataTableOutput("outtb")
    )
  )
)

server <- function(input, output) {
  output$barplot <- renderPlot({
    make.barplot(input$code)
  })

  output$codeval <- renderText({
    d.major %>% filter(SOC == input$code) %>%
      pull(OCC_TITLE) %>% head(1)
  })

  output$outtb <- renderDataTable({
    d.major %>% filter(SOC == input$code) %>%
      group_by(PRIM_STATE) %>%
      summarise(emp = sum(TOT_EMP), h_mean = mean(H_MEAN),
                a_mean = mean(A_MEAN)) %>%
      arrange(desc(emp))
  }, options = list(pageLength = 5))
}

# Run shiny app
shinyApp(ui = ui, server = server)