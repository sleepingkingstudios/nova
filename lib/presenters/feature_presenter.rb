# lib/presenters/feature_presenter.rb

require 'presenters/presenter'

class FeaturePresenter < Presenter
  include IconsHelper

  alias_method :feature, :object

  delegate :slug, :title, :to => :feature

  def icon options = {}
    super(icon_name, options)
  end # method icon

  def label
    feature.title_changed? && !feature.title_was.blank? ? feature.title_was : feature.title
  end # method label

  def type
    feature._type
  end # method type

  private

  def icon_name
    :cube
  end # method icon_name
end # class