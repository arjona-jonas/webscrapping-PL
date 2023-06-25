

#links das partidas
match_link_root <- paste0("https://footballapi.pulselive.com/football/stats/match/",
                          seq(74911,75290))

#request ao API
APIreq <- map(match_link_root,colect_api)

#coleta e conversão do body da response 
partidas <- map(APIreq,colect_info)
names(APIreq) <- paste0("id",seq(74911,75290))

#limpeza das infos de cada partida
match_info <- map_dfr(partidas,clean_match_info)

#limpeza das estatísticas de cada partida
match_stats <- map_dfr(partidas,clean_match_stats)

#uniao dos infos com as estatisticas: db pronta para analise
premierdb_22_23 <- inner_join(match_info,match_stats,
                              by="pk") 

premierdb_22_23[is.na(premierdb_22_23)] <- 0

vars <- head(premierdb_22_23,n = 20)

write.csv(vars,"vars.csv")
