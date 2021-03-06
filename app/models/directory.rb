# app/models/directory.rb

require 'mongoid/sleeping_king_studios/has_tree'
require 'mongoid/sleeping_king_studios/sluggable'

require 'services/features_enumerator'
require 'validators/unique_within_siblings_validator'

class Directory
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::SleepingKingStudios::HasTree
  include Mongoid::SleepingKingStudios::Sluggable

  RESERVED_ACTIONS = %w(index new edit dashboard publish unpublish).map(&:freeze).freeze

  ### Class Methods ###

  class << self
    def feature name, options = {}
      model_name  = name.to_s.singularize
      scope_name  = model_name.pluralize
      class_name  = options.key?(:class) ? options[:class].to_s : model_name.camelize
      model_class = class_name.constantize

      # Append to the feature_names collection.
      (@features ||= {})[scope_name] = model_class

      send :define_method, scope_name do
        features.where(:_type => class_name)
      end # define_method

      send :define_method, "build_#{model_name}" do |attrs|
        model_class.new attrs.merge(:directory_id => self.id)
      end # define_method

      send :define_method, "create_#{model_name}" do |attrs|
        model_class.create attrs.merge(:directory_id => self.id)
      end # define_method

      send :define_method, "create_#{model_name}!" do |attrs|
        model_class.create! attrs.merge(:directory_id => self.id)
      end # define_method
    end # method feature

    # When reloading Directory, re-register features from the FeaturesEnumerator.
    FeaturesEnumerator.each do |feature_name, options|
      Directory.feature(feature_name, options)
    end # each

    def features
      (@features ||= {}).dup
    end # method feature

    def find_by_ancestry segments
      raise ArgumentError.new "path can't be blank" if segments.blank?

      directories = []
      segments.each.with_index do |segment, index|
        directory = where(:parent_id => directories.last.try(:id), :slug => segment).first

        if directory.nil?
          raise Directory::NotFoundError.new segments, directories, segments[index..-1]
        else
          directories << directory
        end # if-else
      end # each

      return directories
    end # class method find_by_ancestry

    def join *slugs
      slugs.map(&:to_s).join('/').gsub(/\/{2,}/, '/')
    end # class method join

    def reserved_slugs
      %w(admin).concat(RESERVED_ACTIONS).concat(%w(directories features)).concat(FeaturesEnumerator.features.keys)
    end # class method reserved_slugs
  end # class << self

  ### Attributes ###
  field :title, :type => String, :default => ''

  ### Concerns ###
  has_tree :children => { :dependent => :destroy }
  slugify :title, :lockable => true

  ### Relations ###
  has_many :features, :class_name => "DirectoryFeature", :dependent => :destroy

  def directories
    children
  end # method directories

  ### Validations ###
  validates :title, :presence => true
  validates :slug,  :exclusion => { :in => reserved_slugs }, :unique_within_siblings => true

  ### Instance Methods ###

  def ancestors
    parent ? parent.ancestors.push(parent) : []
  end # method ancestors

  def to_partial_path
    Directory.join *ancestors.push(self).map(&:slug).reject { |slug| slug.blank? }
  end # method to_partial_path

  class NotFoundError < StandardError
    def initialize search, found, missing
      @search  = search
      @found   = found
      @missing = missing

      super(message)
    end # constructor

    attr_reader :found, :missing, :search

    def message
      "Problem:\n"\
        "  Document(s) not found for class Directory with path "\
        "#{search.join('/').inspect}.\n"\
        "Summary:\n"\
        "  When calling Directory.find_by_ancestry with an array of slugs, "\
        "the array must match a valid chain of directories originating at a "\
        "root directory. The search was for the slug(s): "\
        "#{search.join(', ')} ... (#{search.count} total) and the "\
        "following slug(s) were not found: #{missing.join(', ')}.\n"\
        "Resolution:\n"\
        "  Ensure that the requested directories exist in the database by "\
        "inspecting Directory.roots to find the root directory in the "\
        "chain, and then the directory.children relation to find each "\
        "requested child."
    end # method message
  end # class
end # class
