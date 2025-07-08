
core.submit_task.func.send_email_success <- function(dbpath, proj_id, task_params) {

    sender = "xiaoyu3245@foxmail.com"
    recipients = task_params$email

    mail_body <- '
    <!DOCTYPE html>
    <html>
    <body>
        <p>Dear colleague,</p>
        <br>
        <p>We are pleased to inform you that your task submitted in scMETA have been successfully processed.</p>
        <p>The result file is attached, please download and check it promptly.</p>
        <p>If you want to visualize the results, you can upload the received result file to scMETA.</p>    
        <br>
        <p>If you have any questions or require further assistance, feel free to reach out to us.</p>
        <br>
        <p>Best regards,</p>
        <p>scMETA development team</p>  
    </body>
    </html>
    '

    mailR::send.mail(
        from = sender,
        to = recipients,
        subject = "Result of the task submitted in scMETA",
        body = mail_body,
        encoding = "utf-8",
        html = TRUE,
        inline = TRUE,
        attach.files = file.path(dbpath, proj_id, "result.zip"),
        smtp = list(
            host.name = "smtp.qq.com",
            port = 465,
            user.name = sender,
            passwd = "koovxwmvdncreabb",
            ssl = TRUE),
        authenticate = TRUE,
        send = TRUE
    )
}