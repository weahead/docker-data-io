# We ahead's volume data handler

Container that handles data in and out of volumes.

It is a container that:

- Exports data:
  1. Creates a compressed tar ball of the `/source` directory inside itself.
  2. Creates a new container based on Alpine base image.
  3. Copies the tar ball form step 1 into the container from step 2.
  4. Commits the resulting container from step 3 with the tag given to environment variable `DATA_TAG`.
  5. Optionally pushes the resulting image from step 4, unless environment variable `NO_PUSH` is set.

- Imports data:
  1. Optionally pulls the image with the name given to environment variable `DATA_TAG`.
  2. Checks if the pull fetched a new version of the image and exists if so. This gives you the possiblity to verify the data before importing it.
  3. Created a new container based on the image from step 1.
  4. Copies the compressed tar ball from the container from step 3 to itself.
  5. Extracts the contents from the tar ball from step 4 to `/`.
  6. Kills the container from step 3 and removes it.

This all relies on the fact that the named volumes attached to the import and exports containers are properly configured.

See example below.

## Usage

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


## License

[X11](LICENSE)
