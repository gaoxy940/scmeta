# func/task_run.R
print('task_run -----')

args <- commandArgs(trailingOnly = TRUE)
if(length(args) == 0) {return(NULL)}
dbpath <- args[1]
proj_id <- args[2]

source('core/6_submit_task/func/send_email_success.R')
source('core/6_submit_task/func/send_email_fail.R')
source('core/3_species_annotation/func/anno_confirm.R')
source('core/5_snp_analysis/func/get_ref_filename.R')
source('core/5_snp_analysis/func/get_snp_species_tab.R')

    if(is.null(dbpath) || is.na(dbpath)) {return(NULL)}
    if(is.null(proj_id) || is.na(proj_id)) {return(NULL)}
    
    print(paste("proj_id =", proj_id))
    proj_dir = file.path(dbpath, proj_id)
    # task_params
    load(file.path(proj_dir, 'task_params.rd'))
    print("task_params :")
    print(task_params)

    ## qc
    print('qc running ---')
    file_path.fastp_summary = file.path(proj_dir, 'result/fastp/fastp_summary.txt')

    if(!file.exists(file_path.fastp_summary)) {
        system(paste("/bin/bash script/run_fastp.sh", proj_dir))
    }

    if(!file.exists(file_path.fastp_summary) || file.size(file_path.fastp_summary) < 20){
        # send_email_fail
        message = "Unfortunately, the task program encountered an error while executing fastp. This issue may be due to an error in the input file format."
        print(paste0('!!! ERROR: ',message))
        core.submit_task.func.send_email_fail(dbpath, proj_id, task_params, message)
        return(NULL)   
    } else {print('qc success!')}

    ## anno
    print('anno running ---')
    file_pre = ifelse(task_params$anno_method == 'Kraken2',
        paste0("result/kraken2/kraken2.", task_params$anno_db),
        'result/metaphlan4/metaphlan4')
    file_path.anno_confirm = file.path(proj_dir, paste0(file_pre, '_annotation.confirm.txt'))

    if(!file.exists(file_path.anno_confirm)) {
        if(task_params$anno_method == 'Kraken2'){
            system(paste("/bin/bash script/run_anno_kraken2.sh", proj_dir, task_params$anno_db, ">", file.path(proj_dir, 'result/log.run_anno_kraken2.txt'), "2>&1"))
        }else{
            system(paste("/bin/bash script/run_anno_metaphlan4.sh", proj_dir, ">", file.path(proj_dir, 'result/log.run_anno_metaphlan4.txt'), "2>&1"))
        }
        # get anno_confirm.txt
        core.species_annotation.func.anno_confirm(dbpath, proj_id, file_pre, task_params$anno_threshold)
    }

    if(!file.exists(file_path.anno_confirm) || file.size(file_path.anno_confirm) < 20){
        # send_email_fail
        message = paste0("Unfortunately, the task program encountered an error while executing ",task_params$anno_method,". This issue may be due to The task program encountered an error while performing fastp, which may be caused by uneven genome coverage.")
        print(paste0('!!! ERROR: ',message))
        core.submit_task.func.send_email_fail(dbpath, proj_id, task_params, message)
        return(NULL)        
    } else {print('anno success!')}

    ## func_anno    
    if(task_params$func_anno == 'Yes'){
        print('func_anno running ---')

        file_path.humann_pathabundance = file.path(proj_dir, 'result/humann3/pathabundance_relab_unstratified.tsv')
        
        if(!file.exists(file_path.humann_pathabundance)) {     
            system(paste("/bin/bash script/run_humann3.sh", proj_dir, ">", file.path(proj_dir, 'result/log.run_humann3.txt'), "2>&1"))
        }
        
        if(!file.exists(file_path.humann_pathabundance) || file.size(file_path.humann_pathabundance) < 20){
            # send_email_fail
            message = "Unfortunately, the task program encountered an error while executing HUMAnN3. This issue may be due to The task program encountered an error while performing fastp, which may be caused by uneven genome coverage."
            print(paste0('!!! ERROR: ',message))
            core.submit_task.func.send_email_fail(dbpath, proj_id, task_params, message)
            return(NULL) 
        } else {print('func_anno success!')}
    }

    ## snp    
    if(task_params$snp == 'Yes'){
        print('snp running ---')

        file_path.snp_matrix = file.path(proj_dir, 'result/snippy', task_params$snp_name, 'snp_matrix.txt')
        
        if(!file.exists(file_path.snp_matrix)) {        
            # Check if there is a sample of snp_name in anno. If not, return a prompt
            anno <- read.table(file_path.anno_confirm, header = T, row.names = 1)
            anno_list = sub(".*__", "", unique(anno[task_params$snp_level])[,1])
            if(!(task_params$snp_name %in% anno_list)){
                # send_email_fail
                message = paste0("Unfortunately, the task program encountered an error while conducting mutation analysis. There is no ", task_params$snp_name, " present in the samples.")
                print(paste0('!!! ERROR: ',message))
                core.submit_task.func.send_email_fail(dbpath, proj_id, task_params, message)
                return(NULL)
            }
            snp_ref_filename = core.snp_analysis.func.get_ref_filename(dbpath,
                                                                        proj_id,
                                                                        task_params$snp_name,
                                                                        task_params$snp_ref_filepath$datapath)
            # get_snp_species_tab
            core.snp_analysis.func.get_snp_species_tab(dbpath, proj_id, file_pre, task_params$snp_level, task_params$snp_name)
            # run snippy
            system(paste("/bin/bash script/run_snippy.sh", proj_dir, task_params$snp_name, snp_ref_filename, ">", file.path(proj_dir, 'result/log.run_snippy.txt'), "2>&1"))
            # # output some necessary images
            # core.snp_analysis.plt.snp_gcircle(dbpath,
            #                                 proj_id,
            #                                 task_params$snp_name,
            #                                 snp_ref_filename)
            # tree.nwk
            system(paste("/bin/bash script/run_snippy_tree.sh", file.path(proj_dir, 'result/snippy', task_params$snp_name), ">", file.path(proj_dir, 'result/log.run_snippy_tree.txt'), "2>&1"))
        }

        if(!file.exists(file_path.snp_matrix) || file.size(file_path.snp_matrix) < 20){
            # send_email_fail
            message = "Unfortunately, the task program encountered an error while conducting mutation analysis. This issue may be due to a mismatch between the selected species and the reference genome."
            print(paste0('!!! ERROR: ',message))
            core.submit_task.func.send_email_fail(dbpath, proj_id, task_params, message)
            return(NULL)
        } else {print('snp success!')}
    }

    save(task_params, file = file.path(proj_dir, "task_params.rd"))

    # zip
    zip_cmd <- paste0(
        'cd ', proj_dir, '&& zip -r result.zip result/ group.txt group_filtered.txt task_params.rd'
    )
    system(zip_cmd)

    if (!file.exists(file.path(proj_dir, "result.zip"))) {
        # send_email_fail
        message = "Unfortunately, the task program encountered an error while returning the result. Please try again later."
        print(paste0('!!! ERROR: ',message))
        core.submit_task.func.send_email_fail(dbpath, proj_id, task_params, message)
        return(NULL)
    }

    # send_email_success
    core.submit_task.func.send_email_success(dbpath, proj_id, task_params)
    print('send_email success!')

