noflo = require 'noflo'

class DuplicateProperty extends noflo.Component
  constructor: ->
    @properties = {}
    @separator = '/'

    @inPorts = new noflo.InPorts
      property:
        datatype: 'all'
      separator:
        datatype: 'string'
      in:
        datatype: 'object'
    @outPorts = new noflo.OutPorts
      out:
        datatype: 'object'

    @inPorts.property.on 'data', (data) =>
      @setProperty data
    @inPorts.separator.on 'data', (data) =>
      @separator = data

    @inPorts.in.on 'begingroup', (group) =>
      @outPorts.out.beginGroup group
    @inPorts.in.on 'data', (data) =>
      @addProperties data
    @inPorts.in.on 'endgroup', =>
      @outPorts.out.endGroup()
    @inPorts.in.on 'disconnect', =>
      @outPorts.out.disconnect()

  setProperty: (prop) ->
    if typeof prop is 'object'
      @prop = prop
      return

    propParts = prop.split '='
    if propParts.length > 2
      @properties[propParts.pop()] = propParts
      return

    @properties[propParts[1]] = propParts[0]

  addProperties: (object) ->
    for newprop, original of @properties
      if typeof original is 'string'
        object[newprop] = object[original]
        continue

      newValues = []
      for originalProp in original
        newValues.push object[originalProp]
      object[newprop] = newValues.join @separator

    @outPorts.out.send object

exports.getComponent = -> new DuplicateProperty
