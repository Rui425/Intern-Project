### Run in python ###
__author__ = 'rfan'
import sys
import psycopg2
import pandas as pd
from scipy.sparse import coo_matrix, vstack, hstack
import os
import collections

# Connect the Redshift database
try:
  conn = psycopg2.connect("""dbname='clipclop' port='5439' user='rfan' 
    host='dw-sm.camyztsai2ut.us-east-1.redshift.amazonaws.com' 
    password='GlHc9FNK'""")
except:
  print "\nUnable to connect to the database\n"
  sys.exit()


### Run in terminal ### 
psql -U rfan -w -p 5439 -h dw-sm.camyztsai2ut.us-east-1.redshift.amazonaws.com clipclop $* 
# Unload all program and with cost greater than 0 
unload ('
	select
	  ad_time_est,
	  ad_cost*30/ad_length as cost_per_30seconds,
	  extract(DOW FROM ad_time_est) AS DayOfWeek,
	  extract(HOUR FROM ad_time_est) AS HourOfDay,
	  case when product_type like ''%DR'' then ''DR''
         when product_type like ''%Promo'' then ''Promo''
         else ''Regular''
         end as product_type_groups,
    program,
    master_n as channel
    from dw.f_kantar_ads
    where ad_cost>0 
          and ad_time_est between (select DATEADD(mm, -6, MAX(ad_time_est))from dw.f_kantar_ads where ad_cost > 0)
          and (select max(ad_time_est) from dw.f_kantar_ads where ad_cost > 0)
    order by ad_time_est
;') to 's3://sm-science/rfan/Kantar_compact_cost_without0_'
credentials
'aws_access_key_id=ASIAJJYJ4VXQMPHZ7XKQ;aws_secret_access_key=VNTjNEEynosDx5y7+GYlPbebTqf+ogEqT4c22xEZ;token=AQoDYXdzENn//////////wEa8AH4q4/pc39Yz0ojotubJCP7p2dgqZQ8MQ6oB/HISCc0TWi7ZzPtW8ir6zDdD66QNu/sOSRn9mhJzH7LTolNozVXwibFLpw/l9mTRGPrfgcB8vXvesX1p0RJMDDO6+YhdJpCGS4PT9vuQSFfGLcxW7ACmAjYCZT3ZPWIzPW3wrE9zNwD2YjmCkiHzPiZiLI/crMI6AD3/DV47flvlsvt0O1pmK1dK/lKW8daSig6iXHnaZOd6OobItxn3tfUXmvM8Jk1fzdTSad47POtiXytavZXqSfsqCoZxMsBfk6Z2hU+hNvICbk6FkT0asOHzzpxAQggtZP+rQU='
 delimiter ','
 addquotes
 allowoverwrite
 parallel off
 gzip;

# Unload program type and with cost greater than 0  
 unload ('
	select
	  ad_time_est,
	  ad_cost*30/ad_length as cost_per_30seconds,
	  extract(DOW FROM ad_time_est) AS DayOfWeek,
	  extract(HOUR FROM ad_time_est) AS HourOfDay,
	  case when product_type like ''%DR'' then ''DR''
         when product_type like ''%Promo'' then ''Promo''
         else ''Regular''
         end as product_type_groups,
    program_type,
    master_n as channel
    from dw.f_kantar_ads
    where ad_cost>0 
          and ad_time_est between (select DATEADD(mm, -6, MAX(ad_time_est))from dw.f_kantar_ads where ad_cost > 0)
          and (select max(ad_time_est) from dw.f_kantar_ads where ad_cost > 0)
    order by ad_time_est
;') to 's3://sm-science/rfan/Kantar_pt_compact_cost_without0_'
credentials
'aws_access_key_id=ASIAJJYJ4VXQMPHZ7XKQ;aws_secret_access_key=VNTjNEEynosDx5y7+GYlPbebTqf+ogEqT4c22xEZ;token=AQoDYXdzENn//////////wEa8AH4q4/pc39Yz0ojotubJCP7p2dgqZQ8MQ6oB/HISCc0TWi7ZzPtW8ir6zDdD66QNu/sOSRn9mhJzH7LTolNozVXwibFLpw/l9mTRGPrfgcB8vXvesX1p0RJMDDO6+YhdJpCGS4PT9vuQSFfGLcxW7ACmAjYCZT3ZPWIzPW3wrE9zNwD2YjmCkiHzPiZiLI/crMI6AD3/DV47flvlsvt0O1pmK1dK/lKW8daSig6iXHnaZOd6OobItxn3tfUXmvM8Jk1fzdTSad47POtiXytavZXqSfsqCoZxMsBfk6Z2hU+hNvICbk6FkT0asOHzzpxAQggtZP+rQU='
 delimiter ','
 addquotes
 allowoverwrite
 parallel off
 gzip;
