# proj.upload

core.data_upload.func.proj_upload <- function(dbpath, file_path, proj_name) {

  if (is.null(dbpath)) {return(NULL)}
  if (is.null(file_path)) {return(NULL)}
  if (is.null(proj_name)) {return(NULL)}
  
  # create proj_id
  id <- paste0(sprintf('%05X', as.integer(format(Sys.time(), '%y%m%d'))),
                sprintf('%05X', as.integer(format(Sys.time(), '%H%M%S'))),
                sprintf('%02X',sample(0:127, 1)))
  proj_id <- paste0('P', id)


  if(basic.is_repeat_proj(dbpath, proj_id, proj_name)){
    showModal(modalDialog(
        title = "Invalid Input",
        paste("The", proj_id, proj_name,"project already exists!"),
        alertType = "warning"
    ))
    return(NULL)
  }   
  
  # create proj_dir
  proj_dir <- file.path(dbpath, proj_id)
  dir.create(proj_dir)
  
  progress <- Progress$new()
  
  # unzip file_path
  progress$set(value = 0.3, message = 'Decompressing...')
  splited_basename <- strsplit(basename(file_path), '.', fixed = T)[[1]]
  if (splited_basename[length(splited_basename)] == 'zip') {    
    unzip(file_path, exdir = proj_dir, overwrite = T)    
  } else if (splited_basename[length(splited_basename)] == 'tar') {    
    untar(file_path, exdir = proj_dir, overwrite = T)    
  }

  # check&read group.txt, get proj_info
  result_group_file <- file.path(proj_dir, 'result/group.txt')
  result_group_filter <- file.path(proj_dir, 'result/group_filtered.txt')
  proj_group_file <- file.path(proj_dir, 'group.txt')
  proj_group_filter <- file.path(proj_dir, 'group_filtered.txt')
  if(!file.exists(proj_group_file) && file.exists(result_group_file))
   file.copy(from = result_group_file, to = proj_group_file)
  if(!file.exists(proj_group_filter) && file.exists(result_group_filter))
   file.copy(from = result_group_filter, to = proj_group_filter)

  if(file.exists(proj_group_filter)){

    group <-  read.table(proj_group_filter, header = TRUE, sep = "\t")
    File_Count = length(readLines(proj_group_filter)) - 1
    if('Single' %in% group[[2]]){
      Proj_Group = 'Single'
    } else {Proj_Group = 'Control + Treat'}

  } else if(file.exists(proj_group_file)){

    group <-  read.table(proj_group_file, header = TRUE, sep = "\t")
    File_Count = length(readLines(proj_group_file)) - 1
    if('Single' %in% group[[2]]){
      Proj_Group = 'Single'
    } else {Proj_Group = 'Control + Treat'}

  } else {

    showModal(modalDialog(
      title = "Invalid Input",
      "The project does not match, please upload the result file returned by SCMETA! If you want to upload the sequencing data, please select 'Create a new project'.",
      alertType = "warning"
    ))
    return(NULL)

  }

  # refresh json
  progress$set(value = 0.8, message = 'Creating...')
  Projs <- fromJSON(file.path(dbpath, "Projs.json"))
  new_data <- list(Proj.ID = proj_id, Proj.Name = proj_name,
                    Sample.Count = File_Count, Proj.Group = Proj_Group,
                    Proj.Path = proj_dir)
  new_Projs <- rbind(Projs,new_data)
  Projs <- toJSON(new_Projs, pretty = T)
  cat(Projs, file = (con <- file(file.path(dbpath, "Projs.json"), 'w', encoding = 'UTF-8')))
  close(con)

  progress$close()
  return(proj_id)
         
}
