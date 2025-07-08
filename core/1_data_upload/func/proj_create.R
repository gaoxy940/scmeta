# proj.create

args <- commandArgs(trailingOnly = TRUE)
if(length(args) == 0) {return(NULL)}
dbpath <- args[1]
file_path <- args[2]
proj_id <- args[3]
proj_name <- args[4]

if(is.null(dbpath) || is.na(dbpath)) {return(NULL)}
if(is.null(file_path) || is.na(file_path)) {return(NULL)}
if(is.null(proj_id) || is.na(proj_id)) {return(NULL)}
if(is.null(proj_name) || is.na(proj_name)) {return(NULL)}
  
  library(jsonlite)

  proj_dir <- file.path(dbpath, proj_id)
  seq_dir <- file.path(proj_dir, 'seq')
  
  print('Decompressing...')
  # unzip file_path
  splited_basename <- strsplit(basename(file_path), '.', fixed = T)[[1]]
  
  if (splited_basename[length(splited_basename)] == 'zip') {    
    unzip(file_path, exdir = seq_dir, overwrite = T)    
  } else if (splited_basename[length(splited_basename)] == 'gz') {    
    untar(file_path, exdir = seq_dir, overwrite = T)    
  }

  # proj_info & move/create group.txt
  seq_group_file <- file.path(seq_dir, 'group.txt')
  proj_group_file <- file.path(proj_dir, 'group.txt')
  
  if(file.exists(seq_group_file)){
    Proj_Group = 'Control + Treat'
    file.copy(from = seq_group_file, to = proj_group_file) #file.rename
  }else {
    Proj_Group = 'Single'
    files <- list.files(seq_dir, full.names = FALSE)
    sample_ids <- sapply(files, function(x) {
      if (grepl("_2", x)) {
        sub("_2.*", "", x)
      } else {NA}
    })
    sample_ids <- na.omit(sample_ids)
    content <- c("Sample\tGroup", paste0(sample_ids,"\tSingle"))
    writeLines(content, con = proj_group_file)
  }

  # run fastqc
  print('Fastqc Running...')
  system(paste("/bin/bash script/run_fastqc.sh",file.path(dbpath, proj_id)))

  # remove the erroneous samples from group.txt
  file_path.error_samples = file.path(dbpath, proj_id, 'result/error_samples_list.txt')
  if(file.size(file_path.error_samples) > 0){
    error_lines <- readLines(file_path.error_samples)
    if(file.exists(proj_group_file)){
      group <-  read.table(proj_group_file, header = TRUE, sep = "\t")
      group = group[!group[[1]] %in% error_lines, ]
      write.table(group, proj_group_file, sep = "\t", row.names = FALSE, col.names = TRUE, quote = FALSE)
    }
    print("The following samples are identified as erroneous; subsequent analysis will eliminate them:")
    print(error_lines)
  }

  # refresh json
  print('Creating...')
  File_Count = length(readLines(proj_group_file)) - 1
  Projs <- fromJSON(file.path(dbpath, "Projs.json"))
  new_data <- list(Proj.ID = proj_id, Proj.Name = proj_name,
                    Sample.Count = File_Count, Proj.Group = Proj_Group,
                    Proj.Path = proj_dir)
  new_Projs <- rbind(Projs,new_data)
  Projs <- toJSON(new_Projs, pretty = T)
  cat(Projs, file = (con <- file(file.path(dbpath, "Projs.json"), 'w', encoding = 'UTF-8')))
  close(con)

  # copy form group.txt to group_filtered.txt
  file.copy(from = proj_group_file, to = file.path(proj_dir, 'group_filtered.txt'))

  print('Success!')
