# Airwaves

Airwaves is a lightweight pub/sub library that can be used in any JavaScript
environment. It has no dependencies.

To communicate over the airwaves, first create a channel:

```coffeescript
bbc = new airwaves.Channel
```

Channels provide methods for broadcasting transmissions and for managing
subscriptions to these broadcasts. Each channel operates on a dedicated
frequency, so there's no risk of anyone receiving unwanted transmissions.

```coffeescript
bbc.subscribe "news", ({name}) -> alert "now playing: #{name}"
bbc.broadcast "news",
  name: "World Business Report"
  desc: "The latest business and finance news from around the world."
```

This adds a subscriber to "news" broadcasts on the `bbc` channel. Shortly
thereafter, the subscriber learns of the World Business Report broadcast.

---

### `channel.broadcast(name, args...)`

Broadcast `args` to all those subscribed to `name` on this channel.

```coffeescript
channel.broadcast "delete"
channel.broadcast "rename", "johnsmith", "JohnSmith"
channel.broadcast "resize", width: 1360, height: 859
```

---

### `channel.subscribe(name, fn)`

Subscribe `fn` to broadcasts of `name` on this channel. `fn` receives the
broadcast's values as arguments.

```coffeescript
channel.subscribe "hashchange", (hash) -> location.hash = hash
```

---

### `channel.unsubscribe(name[, fn])`

Unsubscribe `fn` from broadcasts of `name` on this channel. If `fn` is
omitted, all subscriptions to broadcasts of `name` on this channel are
cancelled.

```coffeescript
# Unsubscribe save handler from "textchange" broadcasts:
channel.unsubscribe "textchange", save

# Unsubscribe all handlers from "resize" broadcasts:
channel.unsubscribe "resize"
```

---

### `channel.intercept(name, fn)`

Subscribe `fn` to broadcasts of `name` on this channel in such a way that it
may modify and/or cancel such broadcasts.

Subscribers can receive and respond to broadcasts, but cannot affect them in
any way. Interceptors, on the other hand:

  * receive broadcasts ahead of subscribers
  * can modify broadcasts
  * can cancel broadcasts

An interceptor receives the broadcast as its first argument, followed by zero
or more arguments representing the broadcast's content:

```coffeescript
channel.intercept "print", (broadcast, filename, orientation) ->
  # ...
channel.broadcast "print", "~/Downloads/contract.pdf", "portrait"
```

An interceptor cancels any broadcast it intercepts unless it invokes the
function passed to it as its first argument. The values it passes to this
function are received by subscribers (and any remaining interceptors).
The no-op interceptor is as follows:

```coffeescript
channel.intercept name, (broadcast, args...) ->
  broadcast args...
```

An interceptor modifies a broadcast by invoking the broadcast function with
values different from those it received. This enables an interceptor to, for
example, sanitize broadcasts on the fly:

```coffeescript
channel.intercept "comment", (broadcast, user, message) ->
  broadcast user, message.replace /wtf/gi, "what on earth"

channel.subscribe "comment", (user, message) ->
  console.log "#{user}: #{message}"

channel.broadcast "comment", "Mr. Badger", "I don't know WTF is going on"
channel.broadcast "comment", "Ken Shabby", "WTF are you talking about?"

# Mr. Badger: I don't know what on earth is going on
# Ken Shabby: what on earth are you talking about?
```

Interceptors can also be used to suppress invalid broadcasts. For example:

```coffeescript
channel.intercept "move", (broadcast, move) ->
  if player is active_player then broadcast move
  else alert "It's not your turn!"
```

---

### Event names

Airwaves supports comma-separated event names, so the following snippets
are equivalent:

```coffeescript
channel.subscribe "numerator-change", calculate
channel.subscribe "denominator-change", calculate
```
```coffeescript
channel.subscribe "numerator-change, denominator-change", calculate
```

More accurately, event names are delimited by `[,\s]+` (thus cannot contain
commas or whitespace).

### Testing

    make setup
    make test
