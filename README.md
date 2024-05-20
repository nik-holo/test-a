# README
Please use included Postman collection for testing.

### Setup

1. Start docker daemon on your machine
2. Open project folder and run
```shell
docker-compose build
```
3. Create and migrate DB
```shell
docker-compose run web rails db:create db:migrate
```
4. Create rails credentials
```shell
VISUAL="mate --wait" bin/rails credentials:edit
```
5. Make sure you have secret key base by running this in rails console
```shell
Rails.application.credentials.secret_key_base
```
6. Start your engines!
```shell
docker-compose up
```

### Creating initial token:
1. Open rails console
```shell
docker-compose run web rails console
```
2. Create admin token (needed for links creation and stats endpoint)
```shell
JsonWebToken.encode({}, 48.hours.from_now.to_i, "admin")
```
This will generate admin root token for initial link creation api call.

### Using API

Using New Link request from Postman collection generate a link upload with admin bearer token.

Copy it to next Batch Upload requst. Don't forget to include some images.

Using ids from response - feel free to retrieve image. (you're gonna need bearer token as well, copy it from url for batch upload)

Stats endpoint should be avaiable with admin bearer token and look like this:
```json
{
    "cameras": {
        "NIKON D300": 1,
        "NIKON D7000": 1,
        "unknown": 49,
        "NIKON D800E": 1,
        "Canon EOS-1Ds Mark III": 1,
        "ILCE-7S": 1
    },
    "formats": {
        "image/png": 4,
        "image/jpeg": 50
    },
    "days": {
        "2024-05-20": 55
    }
}
```

### Known imperfections
1. There should be test :) I would at least make one happy path e2e test that would got through all endpoints.
2. There are no validation of user input for expiration date and file format
3. I've used simple activestorage from image storage, not cloud solutions like s3
4. I don't line idea of sending JWT token as part of post url, it's not safe since urls are exposed, unless you use DNS over HTTPS or completely isolated in private network. It's ok then.
5. ImageMagic is sooooooooooooo sloooooooooow. I would use queues and jobs to handle exif info parsing. This is the slowest part for now. Maybe there is a better way to extract it without initializin image magic at all.
6. Per day stats are now created via SQL query but i would stick to Redis for all the stats counters.
7. Speaking of Redis - i would use it for storing md5 hashes instead of sql uniq constrain. Mybe in separate instance as well.
8. Deleting images shold drop the counters on stats, but i've skipped to save time.
9. Nobody called Rubocop, but i would've done it in real world work on each commit as a hook. But something got broken during rubocop -a so skipped it as well.


##  Service scalability and performance
 >What kind of technologies would you use for the service and its respective infrastructure?

TBD

 > Where and how would you store data?

TBD

 > On top of what is mentioned above, what would you use the batch/real-time pipeline for?

TBD

 > What kind of questions would you need to have answered in order to solve this task more concretely or in order to make better decisions on architecture and technologies?

TBD
