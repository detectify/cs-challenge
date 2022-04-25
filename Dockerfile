FROM debian:latest

RUN apt-get update -y && apt-get install -y make socat curl xxd sqlite3 --no-install-recommends
RUN groupadd --gid 999 service 
RUN useradd -m -s /bin/bash -u 999 -g service service
RUN mkdir /service 

COPY . /service/

RUN chown -R 999:999 /service

WORKDIR /service
USER service

CMD ["bash", "-c", "cd code && ./run.sh"]