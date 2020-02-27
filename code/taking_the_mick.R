
# Libraries and setup -----------------------------------------------------

# First, wiple the slate clean
rm(list = ls())

# Pacman will help to load and install any required packages
install.packages("pacman")

pacman::p_load(rvest, dplyr)


# Scrape the data and store it in a tibble  ------------------------------

# Members of current and previous parliaments are listed on this URL:
url <-
  "https://www.oireachtas.ie/en/members/tds/?term=%2Fie%2Foireachtas%2Fhouse%2Fdail%2F"

# We'll start with the 33rd parliament, on page 1 of the list of members.
# # term <- 26
# current_term <- 33
# page <- 1
# last_page <- 9

# We'll store the pages after scraping
list_of_pages <- vector("list", 72)

# Now loop through the 26th to 33rd Dail, grabbing and storing 9 pages from each.
for (term in 26:33) {
  for (page in 1:9){
    list_of_pages[[page + 9 * (term - 26)]] <-
      paste0(url, term, '&tab=constituency&page=', page) %>%
      read_html()
    Sys.sleep(3)
    print(page + 9 * (term - 26))
  }
}

extracted_data <- tibble(term = integer(1500),
                         member = character(1500),
                         constituency = character(1500),
                         party = character(1500))

for (term in 26:33) {
  for (page in 1:9){
    for (td in 1:20) {
    extracted_data$term[[20 * (page - 1) + 9 * (term - 26) + td]] <- term
    extracted_data$member[[20 * (page - 1) + 9 * (term - 26) + td]] <-
      html_text(html_nodes(list_of_pages[[page + 9 * (term - 26)]],
                           css = "#constituency .c-member-list-item__name-content"))[[td]]
    }
  }
}

# need something much simpler

