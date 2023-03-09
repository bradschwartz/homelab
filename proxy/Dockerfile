FROM alpine:latest as builder

ARG TARGETARCH

WORKDIR /app

ARG TSFILE=tailscale_1.36.2_${TARGETARCH}.tgz
RUN wget https://pkgs.tailscale.com/stable/${TSFILE} && \
	tar xzf ${TSFILE} --strip-components=1 && \
	rm ${TSFILE} && \
	mv tailscale* /usr/local/bin

RUN apk update && apk add ca-certificates iptables ip6tables apache2 && rm -rf /var/cache/apk/*

## No need to run on privileged ports
RUN sed -i 's/Listen 80/Listen 8080/g' /etc/apache2/httpd.conf

COPY proxy/* .
RUN chmod +x ./startup.sh

CMD [ "./startup.sh" ]
