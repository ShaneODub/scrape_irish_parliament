
# Libraries and setup -----------------------------------------------------

# First, wipe the slate clean
rm(list = ls())

# Pacman will help to load and install any required packages
install.packages("pacman")

pacman::p_load(rvest, dplyr, stringr, tidyr)

# Use read_html to grab the webpages --------------------------------------

# This is the first part of the URL string for the pages we want to scrape:
url_stem <-
  "https://www.oireachtas.ie/en/members/tds/?term=%2Fie%2Foireachtas%2Fhouse%2Fdail%2F"

list_of_pages <- vector("list", 400)

list_position <- 0

# Now loop through the website reading & storing html pages in a list.
for (term in 1:33) {
  
  # Step 1: Check how many pages of results there are for any given Dáil
  last_page <-
    paste0(url_stem, term, '&tab=constituency&page=1') %>%
    read_html() %>%
    html_node(css = "#constituency .c-page-num__ref") %>%
    html_text() %>%
    str_remove(" 1 of ") %>%
    as.numeric()
  
  # Step 2: Download the number of pages we determined in step 1.
  for (page in 1:last_page) {
    full_url <- paste0(url_stem, term, '&tab=constituency&page=', page)
    list_position <- list_position + 1
    list_of_pages[[list_position]] <-
      full_url %>%
      read_html()
    print(paste("Term", term, "Page", page, "of", last_page))
    Sys.sleep(10)
  }
}

# We downloaded 267 pages. Dropping the null entries at the end of the list.
list_of_pages <- list_of_pages[1:267]

# Use html_nodes etc.to scrape from the downloaded webpages --------------

# Function to grab 7 pieces of information from each page and stick them in a tibble
scrape_and_tibble <- function(page) {
  tibble(
    full_name = page %>%
      html_nodes(css = "#constituency .c-member-list-item__name-content") %>%
      html_text(),
    constituency = page %>%
      html_nodes(css = "#constituency .c-member-list-item__constituency-content") %>%
      html_text(),
    party = page %>%
      html_nodes(css = "#constituency .c-member-list-item__party-content") %>%
      html_text(),
    profile_url = page %>%
      html_nodes(css = "#constituency .u-btn-secondary") %>%
      html_attr("href"),
    dail_term = page %>%
      html_nodes(css = ".text-results span") %>%
      html_text() %>%
      nth(2),
    dail_period = page %>%
      html_nodes(css = ".text-results span") %>%
      html_text() %>%
      nth(4),
    number_of_seats = page %>%
      html_nodes(css = ".text-results span") %>%
      html_text() %>%
      nth(6),
  )
}

# Make 267 tibbles and then bind them into one big tibble.
all_parliaments <-
  lapply(list_of_pages, scrape_and_tibble) %>%
  bind_rows()

saveRDS(all_parliaments, file = "output//all_parliaments_1st_scrape.rds")


# Little bit of fixing and cleaning  ----------------------------------------

all_parliaments$term_number <-
  all_parliaments$dail_term %>%
  str_remove_all("[^0-9]") %>%
  as.numeric()

all_parliaments <-
  all_parliaments %>%
  mutate(
    dail_period = replace(
      dail_period,
      dail_period == "(2016 - )",
      "(2016 - 2020)"
      ),
    constituency = replace(
      constituency,
      full_name == "Seán Ó Fearghaíl" &
        dail_term == "31st Dáil",
      "Kildare_South"
      ),
    party = replace(
      party,
      full_name == "Thomas J. Fitzpatrick" &
        dail_term == "25th Dáil",
      "Fine Gael"
      )
  )

# Save the data to local drive --------------------------------------------


saveRDS(all_parliaments,
        file = "output//all_parliaments.rds")

write.csv(all_parliaments,
          file = "output//all_parliaments.csv",
          row.names = FALSE)
