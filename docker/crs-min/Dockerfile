FROM alpine:3.16
LABEL maintainer="c4pr1c3 <c4pr1c3@gmail.com>"

# minimal networking tools
RUN apk add --no-cache curl iproute2 iputils traceroute

CMD ["sh", "-c", "tail -f /dev/null"]