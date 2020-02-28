
# Libraries and setup -----------------------------------------------------

# First, wiple the slate clean
rm(list = ls())

# Pacman will help to load and install any required packages
install.packages("pacman")

pacman::p_load(rvest, dplyr)

# Use read_html to grab the webpages --------------------------------------

# Members of current and previous parliaments are listed on this URL:
url <-
  "https://www.oireachtas.ie/en/members/tds/?term=%2Fie%2Foireachtas%2Fhouse%2Fdail%2F"

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

# Output the list so I won't have to scrape again
saveRDS(list_of_pages, file = "output//list_of_pages.rds")


# Use html_nodes etc.to scrape from the downloaded webpages --------------

list_of_pages <- readRDS("output//list_of_pages.rds")

tibble_list = vector("list", 72)
for (i in 1:72){
  
  tibble_list[[i]] <-
    tibble(
      full_name = list_of_pages[[i]] %>%
      html_nodes(css = "#constituency .c-member-list-item__name-content") %>%
      html_text(),
    constituency = list_of_pages[[i]] %>% 
      html_nodes(css = "#constituency .c-member-list-item__constituency-content") %>%
      html_text(),
    party = list_of_pages[[i]] %>% 
      html_nodes(css = "#constituency .c-member-list-item__party-content") %>%
      html_text(),
    profile_url = list_of_pages[[i]] %>% 
      html_nodes(css = "#constituency .u-btn-secondary") %>%
      html_attr("href"),
    dail_term = list_of_pages[[i]]  %>% 
      html_nodes(css = ".text-results span") %>%
      html_text() %>%
      nth(2),
    dail_period = list_of_pages[[i]]  %>% 
      html_nodes(css = ".text-results span") %>%
      html_text() %>%
      nth(4)
  )
}
  
eight_dail_terms <- bind_rows(tibble_list)
  


