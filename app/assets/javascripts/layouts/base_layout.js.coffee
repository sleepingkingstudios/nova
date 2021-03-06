# app/assets/javascripts/layouts/base_layout.js.coffee

class Appleseed.Layouts.BaseLayout extends Backbone.Marionette.LayoutView
  @addInitializer: (fn) ->
    if @_initializers?
      @_initializers = @_initializers.slice(0)
    else
      @_initializers = []

    @_initializers.push(fn)

  @extend: (sources...) ->
    for source in sources
      for key, value of source when key not in ['extended', 'included']
        @[key] = value

      source.extended?.apply(@)

  @include: (sources...) ->
    for source in sources
      for key, value of source when key not in ['extended', 'included']
        @::[key] = value

      source.included?.apply(@)

  initialize: (options) ->
    super(options)

    fn.apply(@) for fn in @constructor._initializers if @constructor._initializers?

  get: (name, strict = true) ->
    sel = @selectors()[name]
    throw "undefined selector \"#{name}\"" unless sel?

    # If the selector is prefixed with 'body', don't scope the selector to the
    # layout (e.g. shared page content, modals, et cetera).
    if sel.match /^\s*body/
      $elements = $ sel
    else
      $elements = @$ sel

    if strict && (0 == $elements.length)
      throw "no element found for selector \"#{name}\" ('#{sel}')"

    $elements

  selectors: ->
    return @_selectors if @_selectors?

    inherited = @_getSuperclassProperty 'selectors'
    @_selectors = @_flattenSelectors $.extend(true, {}, inherited ?= {}, @constructor.selectors)

  _flattenSelectors: (hsh, flat = {}, parent = null, scope = null) ->
    sel = hsh.sel ?= ''
    sel = "#{scope} #{sel}" if scope?
    prefix = if 0 < sel.length then "#{sel} " else ''
    for key, value of hsh
      scoped_key = if parent? then "#{parent}.#{key}" else key

      if 'string' == typeof value
        flat[scoped_key] = "#{prefix}#{value}" unless key == 'sel'
      else
        flat[scoped_key] = "#{prefix}#{value.sel}"
        @_flattenSelectors value, flat, scoped_key, sel

    flat

  _getSuperclassProperty: (property) ->
    @constructor.__super__.constructor[property]
