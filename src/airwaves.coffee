###
       ( ( ( ( ( airwaves ) ) ) ) )

    Broadcast on a dedicated frequency
      Copyright 2012, David Chambers
###

remove = (array, value) ->
  idx = 0
  while idx < array.length
    if array[idx] is value then array.splice idx, 1 else idx += 1
  return

split = (fn) ->
  (names, args...) ->
    fn.call this, (n for n in "#{names}".split(/[,\s]+/) when n), args...

subscribe = (propertyName) ->
  (names, fn) ->
    for name in names
      unless Object::hasOwnProperty.call @subscriptions, name
        @subscriptions[name] = ints: [], subs: []
      @subscriptions[name][propertyName].push fn
    return

class Channel
  constructor: ->
    @subscriptions = {}
    @stack = []

  intercept: split subscribe 'ints'
  subscribe: split subscribe 'subs'

  unsubscribe: split (names, fn) ->
    for name in names
      if fn is undefined
        delete @subscriptions[name]
      else if Object::hasOwnProperty.call @subscriptions, name
        remove @subscriptions[name].ints, fn
        remove @subscriptions[name].subs, fn
    return

  broadcast: split (names, args...) ->
    for name in names
      continue if name in @stack # prevent recursion
      continue unless Object::hasOwnProperty.call @subscriptions, name
      @stack.push name
      queue = @subscriptions[name].ints[..]
      # Decorate subscribers so they can be treated like interceptors.
      wrap = (fn) -> (next, args...) -> fn args...; next args...
      queue.push (wrap sub for sub in @subscriptions[name].subs)...
      # Create a function to notify each of the subscribers in turn.
      next = (args...) -> queue.shift() next, args... if queue.length
      try next args... finally @stack.pop()
    return

airwaves = {Channel, version: '0.2.2'}
if typeof module isnt 'undefined' then module.exports = airwaves
else if typeof define is "function" and define.amd then define airwaves
else window.airwaves = airwaves
