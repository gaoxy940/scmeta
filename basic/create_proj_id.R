
basic.create_proj_id <- function(){
  
  # create proj_id
  id <- paste0(sprintf('%05X', as.integer(format(Sys.time(), '%y%m%d'))),
                sprintf('%05X', as.integer(format(Sys.time(), '%H%M%S'))),
                sprintf('%02X',sample(0:127, 1)))
  proj_id <- paste0('P', id)

  return(proj_id)
  
}