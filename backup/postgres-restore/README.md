```shell
docker build -t darkkeks/postgres-restore .
docker run -it --rm \
    --network server-stuff_default \
    --env-file ../../.env.s3 \
    -e S3_BUCKET=darkkeks-backups \
    -e S3_PREFIX=postgres-kks \
    -e POSTGRES_HOST=postgres-kks \
    -e POSTGRES_DATABASE=kks \
    -e POSTGRES_USER=postgres \
    -e POSTGRES_PASSWORD=root \
    darkkeks/postgres-restore
```
