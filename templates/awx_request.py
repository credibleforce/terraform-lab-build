#!/usr/bin/env python

import requests
import json
import logging
import time


# define a class to encapsulate Job template info
class JobTemplate():
    def __init__(self,id,name,launch_url):
        self.id=id
        self.name=name
        self.launch_url=launch_url


class Credential():
    def __init__(self,id,name):
        self.id=id
        self.name=name

logger = logging.getLogger('awx_request')
logger.setLevel(logging.DEBUG)

# create file handler which logs even debug messages
#fh = logging.FileHandler('aws_request.log')
#fh.setLevel(logging.DEBUG)
# create console handler with a higher log level
ch = logging.StreamHandler()
ch.setLevel(logging.DEBUG)

# create formatter and add it to the handlers
formatter = logging.Formatter('%(asctime)s - %(name)s - %(levelname)s - %(message)s')
#fh.setFormatter(formatter)
ch.setFormatter(formatter)
# add the handlers to the logger
#logger.addHandler(fh)
logger.addHandler(ch)

AWX_HOST="http://localhost"
AWX_JOB_TEMPLATES_API = '{0}/api/v2/job_templates'.format(AWX_HOST)
AWX_CREDENTIALS_API = '{0}/api/v2/credentials'.format(AWX_HOST)
AWX_OAUTH2_TOKEN = 'XXXXXX'
headers = {"User-agent": "python-awx-client", "Content-Type": "application/json","Authorization": "Bearer {}".format(AWX_OAUTH2_TOKEN)}
job_template = 'Test'
job_credential = 'lab-windows-domain'
job_limit = 'win16-dc1'

logger.info("Starting...")

# get the job template id
response = requests.get(AWX_JOB_TEMPLATES_API,headers=headers)
for job in response.json()['results']:
    jt = JobTemplate(job['id'], job['name'], AWX_HOST + job['related']['launch'])

    if(jt.name == job_template):
        logger.info("Job template {} located.".format(jt.name))
        break


# get the credentials is
response = requests.get(AWX_CREDENTIALS_API,headers=headers)
for cred in response.json()['results']:
    cr = Credential(cred['id'], cred['name'])

    if(cr.name == job_credential):
        logger.info("Credential {} located.".format(cr.name))
        break

# launch template
response = requests.post(jt.launch_url, headers=headers, data=json.dumps({'limit':job_limit,'credentials':[cr.id], 'extra_vars': { "test": 1 }}))

# Checking the response status code, ensures the launch was ok
if(response.status_code == 201):

    job_status_url = AWX_HOST + response.json()['url']

    logger.info("Job launched successfully.")
    logger.info("Job URL = {}".format(job_status_url))

    logger.info("Job id = {}".format(response.json()['id']))
    logger.info("Status = {}".format(
        response.json()['status']))
    logger.info(
        "Waiting for job to complete (timeout = 15mins).")
    timeout = time.time() + 60*15

    while(True):
        time.sleep(2)

        job_response = requests.get(
            job_status_url, headers=headers)
        if(job_response.json()['status'] == "new"):
            logger.info("Job status = new.")
        if(job_response.json()['status'] == "pending"):
            logger.info("Job status = pending.")
        if(job_response.json()['status'] == "waiting"):
            logger.info("Job status = waiting.")
        if(job_response.json()['status'] == "running"):
            logger.info("Job status = running.")
        if(job_response.json()['status'] == "successful"):
            logger.info("Job status = successful.")
            break
        if(job_response.json()['status'] == "failed"):
            logger.error("Job status = failed.")
            break
        if(job_response.json()['status'] == "error"):
            logger.error("Job status = error.")
            break
        if(job_response.json()['status'] == "canceled"):
            logger.info("Job status = canceled.")
            break
        if(job_response.json()['status'] == "never updated"):
            logger.info("Job status = never updated.")

        # timeout of 15m break loop
        if time.time() > timeout:
            logger.warning("Timeout after 15mins.")
            break

    logger.info("Fetching Job stdout")
    job_stdout_response = requests.get(AWX_HOST + response.json()['related']['stdout'] + "?format=json", headers=headers, verify=False)

    print(job_stdout_response.json()['content'])
else:
    logger.error(response.json())


logger.info("Done.")