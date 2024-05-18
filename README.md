# README

### Creating initial token:
```shell
rails c
JsonWebToken.encode({}, 24.hours.from_now.to_i, "admin")
```
This will generate admin root token for initial link creation api call.


* Database creation

* Database initialization

* How to run the test suite

* Services (job queues, cache servers, search engines, etc.)

* Deployment instructions

* ...
