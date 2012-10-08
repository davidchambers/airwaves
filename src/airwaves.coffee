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

class Channel
  constructor: ->
    @subscriptions = {}
    @stack = []

  intercept: (name, fn) ->
    (@subscriptions[name] or= ints: [], subs: []).ints.push fn
    return

  subscribe: (name, fn) ->
    (@subscriptions[name] or= ints: [], subs: []).subs.push fn
    return

  unsubscribe: (name, fn) ->
    if fn is undefined
      delete @subscriptions[name]
    else if Object::hasOwnProperty.call @subscriptions, name
      remove @subscriptions[name].ints, fn
      remove @subscriptions[name].subs, fn
    return

  broadcast: (name, args...) ->
    return if name in @stack # prevent recursion
    return unless Object::hasOwnProperty.call @subscriptions, name
    @stack.push name
    queue = @subscriptions[name].ints[..]
    # Decorate subscribers so they can be treated like interceptors.
    wrap = (fn) -> (next, args...) -> fn args...; next args...
    queue.push (wrap sub for sub in @subscriptions[name].subs)...
    # Create a function to notify each of the subscribers in turn.
    next = (args...) -> queue.shift() next, args... if queue.length
    try next args... finally @stack.pop()
    return

airwaves = {Channel, version: '0.1.1'}
if typeof module isnt 'undefined' then module.exports = airwaves
else window.airwaves = airwaves
