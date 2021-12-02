FROM stabilaprotocol/ubuntu

ENV JAVA_HOME /usr/lib/jvm/jdk1.8.0_301
RUN export JAVA_HOME
ENV PATH "/usr/lib/jvm/jdk1.8.0_301/bin:${PATH}"

RUN chmod 777 /home/work.sh

WORKDIR /home
CMD /home/work.sh start && while true; do sleep 10000; done
