FROM python:3.7-stretch as base

RUN mkdir /base
WORKDIR /base

RUN apt-get update
RUN apt-get install -y wget
ADD fetchChromedriver.sh /base
RUN ./fetchChromedriver.sh
RUN apt-get -y install libnss3

RUN wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
RUN apt -y install ./google-chrome-stable_current_amd64.deb


FROM base

EXPOSE 5000

#caches the pip install step
ADD requirements.txt /app/requirements.txt
WORKDIR /app
RUN pip install -r requirements.txt

ADD . /app
RUN mkdir screenshots

#Remove windows file endings from the script file
RUN cp startApps.sh startApps.sh.tmp
RUN awk '{ sub("\r$", ""); print }' startApps.sh.tmp > startApps.sh

RUN chmod +x startApps.sh

CMD ["/app/startApps.sh"]
#CMD python vuln-screenshot/app.py
