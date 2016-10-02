FROM trenpixster/elixir


# RUN apt-get update && apt-get install rsyslogd
RUN mkdir -p /var/log/audit
RUN touch /var/log/cron.log /var/log/audit/cron.log
WORKDIR /usr/local/audit
COPY . /usr/local/audit
ADD scripts/audit-cron /etc/cron.d/audit-cron
RUN chmod a+x /etc/cron.d/audit-cron
# RUN (crontab -l 2>/dev/null; echo "* * * * * /bin/echo \"ping\" >> /var/log/cron.log" )| crontab -
RUN (crontab -l 2>/dev/null;  echo "* * * * * /bin/bash -l -c 'cd /usr/local/audit && ./audit -a false >> /var/log/audit/cron.log 2>&1'") | crontab -
ADD scripts/start-cron.sh /usr/bin/start-cron.sh
RUN mix local.hex
RUN mix deps.get
RUN mix escript.build

# fetch all data from billing in the first run.
# RUN ./audit -a true 

# CMD /usr/bin/start-cron.sh
