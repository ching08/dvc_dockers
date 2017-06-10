FROM rabbitmq:3.6.6-management

RUN apt-get update -y
RUN apt-get install -y  curl


COPY configure.sh configure.sh

RUN cat configure.sh

CMD  [ "./configure.sh" ]


