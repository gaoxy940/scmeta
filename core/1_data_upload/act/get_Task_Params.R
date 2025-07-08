#get_Task_Params

core.data_upload.act.get_Task_Params <- function(dbpath, idx.p){
  
  if (is.null(dbpath)) {return(NULL)}
  if (is.null(idx.p)) {return(NULL)}

  dt <- fromJSON(basic.get_json_fpath(dbpath))
  proj_id <- dt$Proj.ID[idx.p]
  
  if(file.exists(file.path(DBPATH(), proj_id, 'task_params.rd'))){
    load(file.path(DBPATH(), proj_id, 'task_params.rd'))
    return(task_params)
  }

  return(list())  
}