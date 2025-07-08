
core.submit_task.func.send_email_fail <- function(dbpath, proj_id, task_params, message) {

    sender = "xiaoyu3245@foxmail.com"
    recipients = task_params$email

    mail_body <- paste0(
        "<html>",
        "<body>",
        "<p>Dear colleague,</p>",
        "<br>",
        "<p>", message, 
        " As a result, the task has been terminated.</p>",
        "<p>If you believe this is an error or if you need assistance, please review your input data and parameter selection, or feel free to contact us for support.</p>",
        "<p>We apologize for any inconvenience caused and appreciate your understanding.</p>",
        "<br>",
        "<p>Best regards,</p>",
        "<p>scMETA development team</p>",
        "</body>",
        "</html>"
    )

    mailR::send.mail(
        from = sender,
        to = recipients,
        subject = "Result of the task submitted in scMETA",
        body = mail_body,
        encoding = "utf-8",
        html = TRUE,
        inline = TRUE,
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