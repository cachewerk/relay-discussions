# Docker

These Docker environments are concrete examples of Relay's [installation instruction](https://relay.so/docs/installation).

## Amazon Linux 2

```bash
docker build --pull --tag relay-amazon2 --file al2.Dockerfile .
docker run -it relay-amazon2 bash
$ php --ri relay
```

## Amazon Linux 2023

```bash
docker build --pull --tag relay-amazon2023 --file al2023.Dockerfile .
docker run -it relay-amazon2023 bash
$ php --ri relay
```

## Alpine Linux 3

```bash
docker build --pull --tag relay-alpine --file alpine.Dockerfile .
docker run -it relay-alpine sh
$ php --ri relay
```

## Apache 2

```bash
docker build --pull --tag relay-apache2 --file apache2.Dockerfile .
docker run -it relay-apache2 bash
$ php --ri relay
```

## PHP Images

This image uses `mlocati/php-extension-installer` to install the extension.

```bash
docker build --pull --tag relay-php-cli --file php-cli.Dockerfile .
docker run -it relay-php-cli bash
$ php --ri relay
```

## Versions / Nightly builds

You may specify the Relay version/build for non-package (APT/YUM) Docker examples:

```bash
docker build --pull --tag relay-alpine --file alpine.Dockerfile --build-arg RELAY=v0.9.1 .
```

To install the nightly developments builds use the `dev` version:

```bash
docker build --pull --tag relay-alpine --file alpine.Dockerfile --build-arg RELAY=dev .
```
