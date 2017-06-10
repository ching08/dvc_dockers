FROM python:2.7-alpine
ADD . /code
WORKDIR /code
RUN mkdir /tmp/dvc_reports
RUN pip install -r requirements.txt
ENTRYPOINT ["pytest" , "test.py" ] 
