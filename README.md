# We ahead's volume data handler

A container that handles data in and out of volumes.

It supports the following storage backends:

- Docker Registry
- Amazon S3

## Secrets

`data-io` supports docker secrets. It will properly source all files founds in `/run/secrets/*`. Each filename will become an environment variable and the contents of each respective file will become the value.

[Read more about docker secrets](https://docs.docker.com/engine/swarm/secrets/)


## How it works

### With docker registry as storage backend

- Export of data:
  1. Creates a compressed tar ball of the `/source` directory inside its own container.
  2. Creates a new container based on Alpine base image.
  3. Copies the tar ball form step 1 into the container from step 2.
  4. Commits the resulting container from step 3 with the tag given to the environment variable `DATA_TAG`.
  5. Removes the container from step 2.
  6. Optionally pushes the resulting image from step 4. Set environment variable `NO_PUSH` to avoid pushing.

- Import of data:
  1. Optionally pulls the image specified in the environment variable `DATA_TAG`. Set environment variable `NO_PULL` to avoid pulling.
  2. Checks if the pull fetched a new version of the image and exits if so. This gives you the possiblity to verify the data before importing it.
  3. Creates a new container based on the image from step 1.
  4. Copies the compressed tar ball from the container from step 3 to its own container.
  5. Extracts the contents from the tar ball from step 4 to `/`.
  6. Removes the container from step 3.

This all relies on the fact that the named volumes attached to the import and exports containers are properly configured.
They should be the same volumes that are used by your application containers.

See example below.

#### Example with docker registry as a backend

Docker Compose example:

```
# reusable declarations
data:
  # Use the latest and greatest
  image: weahead/data-io:latest
  volumes:
    # We need access to Docker inside the container.
    - /var/run/docker.sock:/var/run/docker.sock
  environment:
    # Name of the resulting image containing the data, this is what is pushed.
    DATA_TAG: registry.example.com/example:latest
    # OR using a private registry:
    # Prefer using Docker secrets instead of environment variables here.
    REGISTRY: registry.example.com
    REGISTRY_USERNAME: example
    REGISTRY_PASSWORD: example 
    DATA_TAG: example:latest

data-import:
  extends:
    # Reuse data service above for common properties
    service: data
  # Unpack command imports data
  command: unpack
  volumes:
    # Import targets
    - named-volume:/path/to/target
    # Example with mysql data
    - mysql-data:/var/lib/mysql
  environment:
    # Do not pull automatically before importing
    NO_PULL: 1

data-export:
  extends:
    # Reuse data service above for common properties
    service: data
  # Pack command exports data
  command: pack
  volumes:
    # Export targets
    # Mount to /source/<path/to/import/target>, recommended read only.
    - named-volume:/source/path/to/import/target:ro
    # Example with mysql data
    - mysql-data:/source/var/lib/mysql:ro
  environment:
    # Do not push automatically after creating image
    NO_PUSH: 1
```


### With Amazon S3 as storage backend

- Export of data:
  1. Creates a compressed tar ball of the `/source` directory inside its own container.
  2. Adds a date stamp of `%Y-%m-%d_%H-%M-%S` to the compressed tar balls file name.
  3. Uploads the renamed tar ball to AWS S3 with [`aws-cli`](https://github.com/aws/aws-cli).

- Import of data:
  1. Downloads a tar ball from Amazon S3 specified by the value of the environment variable `DATA_S3_DST`.
  2. Extracts the contents from the tar ball from step 1 to `/`.

This all relies on the fact that the named volumes attached to the import and exports containers are properly configured.
They should be the same volumes that are used by your application containers.

See example below.

#### Example with Amazon S3 as a backend

Docker Compose example:

```
# reusable declarations
data:
  # Use the latest and greatest
  image: weahead/data-io:latest
  environment:
    # Name of the resulting file on Amazon S3, this is what is uploaded or downloaded
    DATA_S3_DST: s3://bucket-name/path/to/file.tar.gz
    # AWS credentials with access to bucket specified in DATA_S3_DST
    # Prefer using Docker secrets instead of environment variables here.
    AWS_ACCESS_KEY_ID:
    AWS_SECRET_ACCESS_KEY:

data-import:
  extends:
    # Reuse data service above for common properties
    service: data
  # Unpack command imports data
  command: unpack
  volumes:
    # Import targets
    - named-volume:/path/to/target
    # Example with mysql data
    - mysql-data:/var/lib/mysql

data-export:
  extends:
    # Reuse data service above for common properties
    service: data
  # Pack command exports data
  command: pack
  volumes:
    # Export targets
    # Mount to /source/<path/to/import/target>, recommended read only.
    - named-volume:/source/path/to/import/target:ro
    # Example with mysql data
    - mysql-data:/source/var/lib/mysql:ro
```


## License

[X11](LICENSE)
