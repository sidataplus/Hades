# syntax=docker/dockerfile:1
FROM rocker/rstudio:4.4.1

# install OS dependencies including java and python 3
RUN apt-get update && apt-get install -y openjdk-11-jdk liblzma-dev libbz2-dev libncurses5-dev curl python3-dev python3.venv python3-pip cmake libfontconfig-dev libsodium-dev libxml2-dev libcurl4-openssl-dev \
&& R CMD javareconf \
&& rm -rf /var/lib/apt/lists/*

WORKDIR /home/

# install supervisor process controller
RUN apt-get update && apt-get install -y supervisor

# start Rserve & RStudio using supervisor
RUN echo "" >> /etc/supervisor/conf.d/supervisord.conf \
	&& echo "[supervisord]" >> /etc/supervisor/conf.d/supervisord.conf \
	&& echo "nodaemon=true" >> /etc/supervisor/conf.d/supervisord.conf \
	&& echo "" >> /etc/supervisor/conf.d/supervisord.conf \
	&& echo "[program:Rserve]" >> /etc/supervisor/conf.d/supervisord.conf \
	&& echo "command=/usr/local/bin/startRserve.R" >> /etc/supervisor/conf.d/supervisord.conf \
	&& echo "" >> /etc/supervisor/conf.d/supervisord.conf \
	&& echo "[program:RStudio]" >> /etc/supervisor/conf.d/supervisord.conf \
	&& echo "command=/init" >> /etc/supervisor/conf.d/supervisord.conf \
	&& echo "" >> /etc/supervisor/conf.d/supervisord.conf \
	&& echo "stdout_logfile=/var/log/supervisor/%(program_name)s.log" >> /etc/supervisor/conf.d/supervisord.conf \
	&& echo "stderr_logfile=/var/log/supervisor/%(program_name)s.log" >> /etc/supervisor/conf.d/supervisord.conf 

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
