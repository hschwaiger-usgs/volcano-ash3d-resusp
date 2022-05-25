#import dircache, os
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
                print(name)
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


alert_sub='RESUSPENSION ALERT'
alert_body='Resusp Alert: Current conditions favorible for resuspension'
#alert_recip=['kwallace@usgs.gov','hfs1@hotmail.com','9079474318@mms.att.net']
alert_recip=['hfs1@hotmail.com']
email_recip=['hfs1@hotmail.com']

MetRoot='/data/WindFiles/nam/091'
FC_day=sys.argv[1]
FCh=sys.argv[2]
inflag=sys.argv[3]
outstr = FC_day + '  ' + FCh + '  ' + inflag
print(outstr)
MetDir='/data/WindFiles/nam/091/' + FC_day + '_00/'
Us_DataFile='wgb_Us_00_' + FCh + '.dat'
P0_DataFile='wgb_PRATE_00_' + FCh + '.dat'
SnD_DataFile='wgb_SnD_00_' + FCh + '.dat'
Vsm_DataFile='wgb_VSm_00_' + FCh + '.dat'

if int(inflag) == 1:
  # Preparing a warning text
  myDatafile=MetDir + Us_DataFile
  with open(myDatafile) as f:
      #Us = map(float, f)
      Us=f.read()
      #f.close()
  myDatafile=MetDir + P0_DataFile
  with open(myDatafile) as f:
      #P0 = map(float, f)
      P0=f.read()
      #f.close()
  myDatafile=MetDir + SnD_DataFile
  with open(myDatafile) as f:
      #SnD = map(float, f)
      SnD=f.read()
      #f.close()
  myDatafile=MetDir + Vsm_DataFile
  with open(myDatafile) as f:
      #Vsm = map(float, f)
      Vsm=f.read()
      #f.close()
  
  alert_body='Resusp Alert: Conditions favorible for resuspension\n' + \
             ' on ' + FC_day + ' at ' + FCh + 'UTC (AKDT+8)\n' + \
             '  Us  = ' + Us  + ' m/s \n'   + \
             '  P0  = ' + P0  + ' mm/hr \n' + \
             '  SnD = ' + SnD + ' m \n'    + \
             '  Vsm = ' + Vsm + '\n https://avo-vsc-ash.wr.usgs.gov/resusp.php'

elif int(inflag) == 2:
  print('Summary')
  # Preparing a summary text
  FChours=['00','01','02','03','04','05','06','07','08','09','10','11','12','13','14','15','16','17','18','19','20','21','22','23','24','25','26','27','28','29','30','31','32','33','34','35','36']
  alert_body='SUMMARY Resusp Alert: Conditions favorible for resuspension\n' + \
             ' on ' + FC_day + ' UTC (AKDT+8)\n'

  for fc in range(len(FChours)):
    myDatafile=MetDir + 'wgb_Us_00_' + FChours[fc] + '.dat'
    #print myDatafile
    #print FChours[fc]
    with open(myDatafile) as f:
        Us = map(float, f)
        f.close()
    print(Us)
    #alert_body=alert_body + FChours[fc] + Us + '\n' 

else:
  outstr = 'Neither warning nor summary flags set: ' + inflag
  print(outstr)

#print alert_body
send_alert(alert_recip,alert_sub,alert_body)


