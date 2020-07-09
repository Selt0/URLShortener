# URL Shortener: Part SQL

In this project, I built a tool that will take an arbitrarily-long URL and will shorten it for the user.

Subsequent users can then give the short URL back to the tool and be redirected to the original URL. It also tracks clickthroughs, since these can be really helpful for business analytics.

Unfortunately, I don't know how to build things in the browser yet, so I used a simple CLI tool along with the [gem launchy](https://github.com/copiousfreetime/launchy), to pop open the original URL in a browser.

### Random String

I generated a random string with `SecureRandom::urlsafe_base64`. In [Base64 encoding](https://en.wikipedia.org/wiki/Base64), a random number with a given byte-length is generated and returned as a string.

---

---

## TESTS

```
[URLShortener (master)]$ rails runner bin/cli
Running via Spring preloader in process 22205
Input your email:
tester@yahoo.com

What do you want to do?
0. Create shortened URL
1. Visit shortened URL
0
Type in your long url
https://github.com/
Short url is: FYv-qWki4iJBOL0LLW28mw
[URLShortener (master)]$ rails runner bin/cli
Running via Spring preloader in process 22226
Input your email:
tester@yahoo.com

What do you want to do?
0. Create shortened URL
1. Visit shortened URL
1

Type in the shortened URL
FYv-qWki4iJBOL0LLW28mw

Launching https://github.com/ ...
Goodbye!
```

## Monetizing

Tested monetization to the app by limiting the number of total URLs non-premium users can submit to 5

```
[URLShortener (master)]$ rails runner bin/cli
Running via Spring preloader in process 21865
Input your email:
test@gmail.com

What do you want to do?
0. Create shortened URL
1. Visit shortened URL
0
Type in your long url
https://github.com/
Traceback (most recent call last):
.
.
.
 Validation failed: Only premium members can create more than 5 short urls (ActiveRecord::RecordInvalid)
```

### Pruning Stale URLs

`ShortenedUrl::prune`, an automated prune method that removes URLs submitted by non-premium users after a given period of time

```ruby
u1 = User.create!(email: 'jefferson@cats.com', premium: true)
u2 = User.create!(email: 'muenster@cats.com')

su1 = ShortenedUrl.create_for_user_and_long_url!(u1, 'www.boxes.com')
su2 = ShortenedUrl.create_for_user_and_long_url!(u2, 'www.meowmix.com')
su3 = ShortenedUrl.create_for_user_and_long_url!(u2, 'www.smallrodents.com')

v1 = Visit.create!(user_id: u1.id, shortened_url_id: su1.id)
v2 = Visit.create!(user_id: u1.id, shortened_url_id: su2.id)

ShortenedUrl.all # should return su1, su2 and su3
ShortenedUrl.prune(10)
ShortenedUrl.all # should return su1, su2 and su3

# wait at least one minute
ShortenedUrl.prune(1)
ShortenedUrl.all # should return only su1

su2 = ShortenedUrl.create_for_user_and_long_url!(u2, 'www.meowmix.com')
v3 = Visit.create!(user_id: u2.id, shortened_url_id: su2.id)
# wait at least two minutes
v4 = Visit.create!(user_id: u1.id, shortened_url_id: su2.id)

ShortenedUrl.prune(1)
ShortenedUrl.all # should return su1 and su2
```

## User validation

```
[URLShortener (master)]$ rails runner bin/cli
Running via Spring preloader in process 22078
Input your email:
tester@gmail.com
Traceback (most recent call last):
.
.
.
That user doesn't exist (RuntimeError)
[URLShortener (master)]$
```

---

### Default table

`rails db:setup` to load default values in `db/seeds.rb`

```
[URLShortener (master)]$ rails db:setup
```
