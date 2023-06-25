library(httr2)
library(jsonlite)
library(lubridate)
library(tidyverse)

pluck_multiple <- function(obj_list,to_keep){
  obj_list %>% 
    keep(names(.) %in% to_keep)
}

colect_api <- function(link_root){
  request(link_root) %>% 
    req_headers(Origin="https://www.premierleague.com") %>%
    req_perform()
  }

colect_info <- function(dados_api){
  dados_api$body %>% 
    rawToChar() %>% 
    fromJSON()
  }

clean_match_info <- function(list_info){
  info_id_pk <- paste0(list_info[["entity"]][["teams"]][["team"]][["id"]],
                        "_",
                        list_info[["entity"]][["id"]])
  info_df <- data.frame(list_info[1]) %>% 
    unnest_wider(col=entity.teams.team,
                 names_repair = "minimal",
                 names_sep = "_")
  info_df_comp <- info_df %>%  
    mutate(entity.kickoff.label=dmy_hm(entity.kickoff.label)) %>%
    select(entity.gameweek.gameweek,entity.kickoff.label,entity.teams.team_name,
           entity.teams.team_id,entity.teams.score,entity.id) %>% 
    cbind("Team_status"=c("Home","Away"),
          info_id_pk)
  names(info_df_comp) <- c("Gameweek","Date_of_match","Team_name",
                           "Team_id","Team_score","Match_id",
                           "Team_status","pk")
  return(info_df_comp)
}

clean_match_stats <- function(list_stats){
  stats_id_pk <- paste0(names(list_stats[[2]]),
                        "_",
                        list_stats[["entity"]][["id"]])
  stats_df <- list_flatten(list_stats[[2]]) %>% 
    map(pluck_multiple,c("name","value"))

  stats_df_f <- stats_df %>% 
    map(~pivot_wider(.x,names_from="name")) %>% 
    bind_rows() %>% 
    cbind(pk=stats_id_pk)
  return(stats_df_f)}






