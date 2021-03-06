# app/assets/javascripts/application.js.coffee

# Require core libraries.
#= require jquery
#= require jquery_ujs
#= require underscore

# Require supplemental libraries.
#= require jquery.autosize

# Require HTML/CSS framework files.
#= require twitter/bootstrap

# Require JavaScript framework files.
#= require backbone
#= require backbone.marionette

#= require appleseed
#= require helpers
#= require layouts

$ ->
  # Start the Marionette application.
  Appleseed.application.start()
