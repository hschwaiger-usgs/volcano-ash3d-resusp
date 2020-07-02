import dircache, os
from string import *
import sys
import time

def send_alert(recipients,subject,body,filename=None):

        import smtplib
        from email.MIMEMultipart import MIMEMultipart
        from email.MIMEText import MIMEText
        from email.MIMEBase import MIMEBase
        from email import encoders

        msg = MIMEMultipart()

        fromaddr = 'avo-ash@usgs.gov'
        msg['From'] = fromaddr
        msg['To'] = ', '.join(recipients)
        msg['Subject'] = subject

        msg.attach(MIMEText(body, 'plain'))

        if filename:
                name = filename.split('/')[-1]
                print name
                attachment = open(filename, "rb")
                part = MIMEBase('application', 'octet-stream')
                part.set_payload((attachment).read())
                encoders.encode_base64(part)
                part.add_header('Content-Disposition', 'attachment; filename= {}'.format(name))
                msg.attach(part)

        # server = smtplib.SMTP('smtp.usgs.gov')
        server = smtplib.SMTP('10.165.14.90')
        text = msg.as_string()
        server.sendmail(fromaddr, recipients, text)
        server.quit()


alert_sub='RESUSPENSION ALERT-Ash3d'
alert_body='Resusp Alert: Ash3d forecasts indicate resuspended ash over Shelikof Strait\n' + \
           '  https://avo-vsc-ash.wr.usgs.gov/resusp.php'
alert_recip=['kwallace@usgs.gov','hfs1@hotmail.com','9079474318@mms.att.net']

#print alert_body
send_alert(alert_recip,alert_sub,alert_body)


