# unzip ref_file & return ref_filename

core.snp_analysis.func.get_ref_filename <- function(dbpath, proj.id, species_name, ref_filepath){
    
  if (is.null(dbpath)) {return(NULL)}
  if (is.null(proj.id)) {return(NULL)}
  if (is.null(ref_filepath) || ref_filepath == '') {return(NULL)}

  if (ref_filepath == 'Bifidobacterium_longum.fna') {return(ref_filepath)}

  dir_path = file.path(dbpath, proj.id, 'result/snippy', species_name)
  if (!dir.exists(dir_path)) {
    dir.create(dir_path, recursive = TRUE)
  }

  ref_splited_basename <- strsplit(basename(ref_filepath), '.', fixed = T)[[1]]
  ref_tail = ref_splited_basename[length(ref_splited_basename)]
  if (ref_tail != 'fna') {    
    showModal(modalDialog(
            title = "Invalid Input",
            "The input file is not in the correct format!",
            alertType = "warning"
          ))
    return(NULL)
  }

  # removes the extension from the file name and returns the basic part of the file name
  ref_filename = paste0(species_name, '.fna')
  file.copy(from = ref_filepath, to = file.path(dir_path, ref_filename))

  return(ref_filename)
  
}
