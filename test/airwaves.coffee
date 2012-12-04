assert    = require 'should'
{Channel} = require '../src/airwaves'

describe 'airwaves', ->

  it 'provides basic pub/sub functionality', ->
    count = 0
    bbc = new Channel
    bbc.subscribe 'news', ({name, desc}) ->
      name.should.equal 'World Business Report'
      desc.should.equal 'The latest business and finance news from around the world.'
      count += 1
    bbc.broadcast 'news',
      name: 'World Business Report'
      desc: 'The latest business and finance news from around the world.'
    count.should.equal 1

  it 'lets any number of values be broadcast', ->
    channel = new Channel
    channel.subscribe '0', (args...) -> args.length.should.equal 0
    channel.subscribe '1', (args...) -> args.length.should.equal 1
    channel.subscribe '2', (args...) -> args.length.should.equal 2
    channel.subscribe '3', (args...) -> args.length.should.equal 3
    channel.broadcast '0'
    channel.broadcast '1', 1
    channel.broadcast '2', 1, 2
    channel.broadcast '3', 1, 2, 3

  it 'lets any value be broadcast', ->
    channel = new Channel
    channel.subscribe 'x', (a, b, f, n, o, s, u, x) ->
      a.should.equal _a
      b.should.equal false
      f.should.equal _f
      n.should.equal Infinity
      o.should.equal _o
      s.should.equal ''
      (u is undefined).should.be.true
      (x is null).should.be.true
    _a = [1, 2, 3]
    _b = false
    _f = ->
    _n = Infinity
    _o = x: 4, y: 2
    _s = ''
    _u = undefined
    _x = null
    channel.broadcast 'x', _a, _b, _f, _n, _o, _s, _u, _x

  it 'lets broadcasts have any number of subscribers', ->
    count = 0
    channel = new Channel
    channel.broadcast 'x'
    count.should.equal 0
    channel.subscribe 'x', -> count += 1
    channel.broadcast 'x'
    count.should.equal 1
    channel.broadcast 'x'
    count.should.equal 2
    channel.subscribe 'x', -> count += 1
    channel.broadcast 'x'
    count.should.equal 4

  it 'uses a dedicated frequency for each channel’s broadcasts', ->
    hour = 0
    channel1 = new Channel
    channel2 = new Channel
    channel1.subscribe 'news', (h) -> hour = h
    channel2.subscribe 'news', (h) -> throw new Error 'oops!'
    channel1.broadcast 'news', 18
    hour.should.equal 18

  it 'notifies subscribers in the order in which they subscribed', ->
    count = 0
    channel = new Channel
    channel.subscribe 'x', -> count.should.equal 0; count += 1
    channel.subscribe 'x', -> count.should.equal 1; count += 1
    channel.subscribe 'x', -> count.should.equal 2; count += 1
    channel.subscribe 'x', -> count.should.equal 3; count += 1
    channel.broadcast 'x'
    count.should.equal 4

  it 'provides an "intercept" method', ->
    count = 0
    channel = new Channel
    channel.intercept 'x', -> count += 1
    channel.broadcast 'x'
    count.should.equal 1

  it 'notifies interceptors in the order in which they subscribed', ->
    count = 0
    channel = new Channel
    channel.intercept 'x', (bc) -> count.should.equal 0; count += 1; bc()
    channel.intercept 'x', (bc) -> count.should.equal 1; count += 1; bc()
    channel.intercept 'x', (bc) -> count.should.equal 2; count += 1; bc()
    channel.intercept 'x', (bc) -> count.should.equal 3; count += 1; bc()
    channel.broadcast 'x'
    count.should.equal 4

  it 'lets an interceptor modify a broadcast', ->
    channel = new Channel
    channel.intercept 'x', (broadcast, n) -> n.should.equal 0; broadcast n + 1
    channel.intercept 'x', (broadcast, n) -> n.should.equal 1; broadcast n + 1
    channel.intercept 'x', (broadcast, n) -> n.should.equal 2; broadcast n + 1
    channel.intercept 'x', (broadcast, n) -> n.should.equal 3; broadcast n + 1
    channel.subscribe 'x', (n) -> n.should.equal 4
    channel.broadcast 'x', 0

  it 'lets an interceptor cancel a broadcast', ->
    count = 0
    channel = new Channel
    channel.intercept 'x', (broadcast) -> count += 1; broadcast()
    channel.intercept 'x', (broadcast) -> count += 1; broadcast()
    channel.intercept 'x', (broadcast) -> count += 1
    channel.intercept 'x', -> throw new Error 'oops!'
    channel.subscribe 'x', -> throw new Error 'oops!'
    channel.broadcast 'x'
    count.should.equal 3

  it 'allows a single subscription to a broadcast to be cancelled', ->
    count = 0
    add1 = -> count += 1
    add2 = -> count += 2
    channel = new Channel
    channel.subscribe 'x', add1
    channel.subscribe 'x', add2
    channel.broadcast 'x'
    count.should.equal 3
    channel.unsubscribe 'x', add1
    channel.broadcast 'x'
    count.should.equal 5

  it 'allows all subscriptions to a broadcast to be cancelled', ->
    count = 0
    channel = new Channel
    channel.intercept 'x', (broadcast) -> count += 1; broadcast()
    channel.subscribe 'x', -> count += 1
    channel.broadcast 'x'
    count.should.equal 2
    channel.unsubscribe 'x'
    channel.broadcast 'x'
    count.should.equal 2

  it 'prevents infinite loops', ->
    count = 0
    channel = new Channel
    channel.subscribe 'x', -> count += 1; channel.broadcast 'y'
    channel.subscribe 'y', -> count += 1; channel.broadcast 'x'
    channel.broadcast 'x'
    count.should.equal 2

  it 'clears the internal stack if there’s an uncaught exception', ->
    count = 0
    channel = new Channel
    channel.subscribe 'x', -> count += 1
    channel.subscribe 'x', -> throw new Error
    try channel.broadcast 'x' catch err
    count.should.equal 1
    try channel.broadcast 'x' catch err
    count.should.equal 2

  it 'supports comma-separated event names', ->
    count = 0
    channel = new Channel
    # intercept
    channel.intercept 'i, j', -> count += 1
    channel.broadcast 'i'
    count.should.equal 1
    channel.broadcast 'j'
    count.should.equal 2
    # subscribe
    channel.subscribe 's, t', -> count += 1
    channel.broadcast 's'
    count.should.equal 3
    channel.broadcast 't'
    count.should.equal 4
    # broadcast
    channel.broadcast 'i, j, s, t'
    count.should.equal 8
    # unsubscribe
    channel.unsubscribe 'i, j, s, t'
    channel.broadcast 'i'
    channel.broadcast 'j'
    channel.broadcast 's'
    channel.broadcast 't'
    count.should.equal 8
