# README
Appliaction with HTTP REST API
Write an application with HTTP REST API for uploading images via an
invitation link. You should implement at least these endpoints:
- **Generate upload link** - which accepts a secret token and expiration
time, and produces an expirable link to the endpoint that can be used for
image upload;
- **Upload image** - an expirable one, which accepts one or many images
and returns back some identifier(s). The logic of uploading multiple
images until the link is expired is up to you. Images, which will be
persisted at service side and service should recognize duplicates and
store them just once. Also, the image metadata data should be parsed and
stored in a database (dimensions, camera model, location, etc.)
- **Get image** - accepts image identifier and returns back an image.
- **Get service statistics** - which expects a secret token and returns
service statistics, among which:
- the most popular image format;
- the top 10 most popular camera models;
- image upload frequency per day for the past 30 days.
Application should be packed in one or multiple docker containers.
Technologies and language choice is up to you.
A link to a repository or an archive with code is expected back from you.

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

Please use included Postman collection for testing.

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
So, let's talka layers first:
1. Load balancer: After sending request to our api first thing is not manage load with Load Balancer.
2. Live proccessing layer: i have foggy idea about how this shuld work, but i assume that it's gonna be still a queue and some high power EC2 unit or warmed up lambda to process data from images or apply models on a go.
3. Storage: Second step/layer - simple storage. We want as less friction on this step as possible. S3 would probably be good fit for it.
3. Event: On top of batch upload o would publish even or another queue  message that some images are uploaded and ready to be processed.
4. Post proccesing layer: gets images in batches from s3 and applies all heavy operatioins and train models.

Extra services/features:
1. Monitoring/alarms - we need to know if something goes wrong or bottlenecks. Grafana would do.
2. Autoscaling on storage layer (we cannot affort to lose data, i assume)
3. Dead letter queues - scheduled job to go through them and report if it still there
4. DB: along with storing images we need to store it in DocumentDB (never tried it but sounds like a perfect usecase) or Redis with tricky set of prefixes

 > Where and how would you store data?

S3/DocumentDB/Redis

 > On top of what is mentioned above, what would you use the batch/real-time pipeline for?
 1. Live data analysys. We could warm up some computational powers if we scan predict that most images require some proccesing.
 2. Anomaly Detection and maybe filtering out some obviosly bad input
 3. Data cleaning: I'm not good at image processing but depending on how heavy it is - we could clean/enhance images before storing it idf load is mild at the moment.

 > What kind of questions would you need to have answered in order to solve this task more concretely or in order to make better decisions on architecture and technologies?

- How many images we expect daily?
- What is batch limit we could set?
- What are the latency requirements for real-time processing?
- What is the budget for infrastructure?
- What are the security requirements?
- how ofter predictive models change and do we need to redo previously proccessed images?
- How should we proccess bad data?
