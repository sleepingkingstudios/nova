# spec/models/directory_spec.rb

require 'rails_helper'

RSpec.describe Directory, :type => :model do
  let(:attributes) { attributes_for :directory }
  let(:instance)   { described_class.new attributes }

  shared_context 'with a parent directory' do
    let(:parent)     { build :directory }
    let(:attributes) { super().merge :parent => parent }
  end # shared_context

  shared_context 'with many ancestor directories' do
    let(:ancestors) do
      [].tap do |ary|
        3.times { |index| ary << create(:directory, :parent => ary[index - 1]) }
      end # tap
    end # let
    let(:parent)     { ancestors.last }
    let(:attributes) { super().merge :parent => parent }
  end # shared_context

  shared_context 'with many child directories' do
    let!(:children) do
      Array.new(3).map do
        instance.children.build attributes_for(:directory)
      end # map
    end # let!
  end # shared_context

  shared_context 'with many features' do
    let!(:features) do
      Array.new(3).map do
        instance.features.build attributes_for(:feature)
      end # map
    end # let!
  end # shared_context

  shared_context 'with many example features' do
    let!(:example_features) do
      Array.new(3).map do
        create :example_feature, :directory => instance
      end # map
    end # let!
  end # shared_context

  describe '::RESERVED_ACTIONS' do
    it { expect(described_class.const_defined? :RESERVED_ACTIONS).to be true }

    it 'is immutable' do
      expect { described_class::RESERVED_ACTIONS << 'autodefenestrate' }.to raise_error(RuntimeError)
      expect { described_class::RESERVED_ACTIONS.first.clear }.to raise_error(RuntimeError)
    end # it

    it 'lists resourceful actions' do
      expect(described_class::RESERVED_ACTIONS).to contain_exactly *%w(
        index
        new
        edit
        dashboard
        publish
        unpublish
      ) # end array
    end # it
  end # describe

  ### Class Methods ###

  describe '::feature' do
    it { expect(described_class).to respond_to(:feature).with(1..2).arguments }

    describe 'with a model name and class' do
      def self.model_name
        :example_feature
      end # class method model_name

      let(:model_name)  { self.class.model_name }
      let(:model_class) { "Spec::Models::#{model_name.to_s.camelize}".constantize }
      let(:scope_name)  { model_name.to_s.pluralize }

      before(:each) { Directory.feature model_name, :class => model_class }

      describe "##{model_name.to_s.pluralize}" do
        let(:criteria) { instance.send(scope_name) }

        it { expect(instance).to respond_to(model_name.to_s.pluralize).with(0).arguments }

        it { expect(criteria).to be_a Mongoid::Criteria }

        it { expect(criteria.selector.fetch('directory_id')).to be == instance.id }

        it { expect(criteria.selector.fetch('_type')).to be == model_class.to_s }

        context 'with many example features' do
          include_context 'with many features'
          include_context 'with many example features'

          it 'returns the example features' do
            expect(criteria.to_a).to contain_exactly *example_features
          end # it
        end # context
      end # describe

      describe "#build_#{model_name.to_s}" do
        def build_feature
          instance.send :"build_#{model_name.to_s}", feature_attributes
        end # method create_feature

        let(:feature_attributes) { {} }

        it { expect(instance).to respond_to(:"build_#{model_name.to_s}").with(1).argument }

        it { expect(build_feature).to be_a model_class }

        it { expect(build_feature.directory_id).to be == instance.id }
      end # describe

      describe "#create_#{model_name.to_s}" do
        def create_feature
          instance.send :"create_#{model_name.to_s}", feature_attributes
        end # method create_feature

        it { expect(instance).to respond_to(:"create_#{model_name.to_s}").with(1).argument }

        describe 'with invalid attributes' do
          let(:feature_attributes) { {} }

          it { expect(create_feature).to be_a model_class }

          it 'does not create a new feature' do
            expect { create_feature }.not_to change(instance.send(model_name.to_s.pluralize), :count)
          end # it
        end # describe

        describe 'with valid attributes' do
          let(:feature_attributes) { attributes_for(:example_feature) }

          it { expect(create_feature).to be_a model_class }

          it 'creates a new feature' do
            expect { create_feature }.to change(instance.send(model_name.to_s.pluralize), :count).by(1)
          end # it
        end # describe
      end # describe

      describe "#create_#{model_name.to_s}!" do
        def create_feature
          instance.send :"create_#{model_name.to_s}!", feature_attributes
        end # method create_feature

        it { expect(instance).to respond_to(:"create_#{model_name.to_s}!").with(1).argument }

        describe 'with invalid attributes' do
          let(:feature_attributes) { {} }

          it 'raises an error' do
            expect { create_feature }.to raise_error Mongoid::Errors::Validations
          end # it

          it 'does not create a new feature' do
            expect {
              begin create_feature; rescue Mongoid::Errors::Validations; end
            }.not_to change(instance.send(model_name.to_s.pluralize), :count)
          end # it
        end # describe

        describe 'with valid attributes' do
          let(:feature_attributes) { attributes_for(:example_feature) }

          it { expect(create_feature).to be_a model_class }

          it 'creates a new feature' do
            expect { create_feature }.to change(instance.send(model_name.to_s.pluralize), :count).by(1)
          end # it
        end # describe
      end # describe
    end # describe
  end # describe

  describe '::find_by_ancestry' do
    it { expect(described_class).to respond_to(:find_by_ancestry).with(1).arguments }

    describe 'with nil' do
      it 'raises an error' do
        expect { described_class.find_by_ancestry nil }.to raise_error(ArgumentError)
      end # it
    end # describe

    describe 'with an empty array' do
      it 'raises an error' do
        expect { described_class.find_by_ancestry [] }.to raise_error(ArgumentError)
      end # it
    end # describe

    describe 'with an invalid path with one value' do
      let(:values) { ['this-is-a-slug'] }

      it 'raises an error' do
        expect { described_class.find_by_ancestry values }.to raise_error(Directory::NotFoundError)
      end # it
    end # describe

    describe 'with an invalid path with many values' do
      include_context 'with many ancestor directories'

      let(:values) { ancestors.map(&:slug).push('missing-child') }

      it 'raises an error' do
        expect { described_class.find_by_ancestry values }.to raise_error(Directory::NotFoundError)
      end # it
    end # describe

    describe 'with a valid path with one value' do
      let!(:directory) { create :directory, attributes }
      let(:values)     { [directory.slug] }

      it 'does not raise an error' do
        expect { described_class.find_by_ancestry values }.not_to raise_error
      end # it

      it 'returns the directories' do
        expect(described_class.find_by_ancestry values).to be == [directory]
      end # it
    end # describe

    describe 'with a valid path with many values' do
      include_context 'with many ancestor directories'

      let!(:directory) { create :directory, attributes }
      let(:values)     { ancestors.dup.push(directory).map(&:slug) }

      it 'does not raise an error' do
        expect { described_class.find_by_ancestry values }.not_to raise_error
      end # it

      it 'returns the directories' do
        expect(described_class.find_by_ancestry values).to be == ancestors.dup.push(directory)
      end # it
    end # describe
  end # describe

  describe '::join' do
    it { expect(described_class).to respond_to(:join).with(0..9001).arguments }

    describe 'with an array of strings' do
      let(:slugs) { %w(weapons swords japanese) }

      it { expect(described_class.join *slugs).to be == slugs.join('/') }

      it 'compacts consecutive dividers' do
        expected = slugs.join('/')
        slugs[1] = "#{slugs[1]}/"

        expect(described_class.join *slugs).to be == expected
      end # it
    end # describe
  end # describe

  describe '::reserved_slugs' do
    let(:features) { { :foo => nil, :bar => nil } }

    it { expect(described_class).to have_reader(:reserved_slugs) }

    it { expect(described_class.reserved_slugs).to include 'admin' }

    it 'contains resourceful actions' do
      expect(described_class.reserved_slugs).to include *%w(
        index
        new
        edit
      ) # end array
    end # it

    it 'contains directory and feature names' do
      expect(described_class.reserved_slugs).to include *%w(
        directories
        features
      ) # end array
    end # it

    it 'contains feature names from FeaturesEnumerator' do
      allow(FeaturesEnumerator).to receive(:features).and_return(features)

      expect(described_class.reserved_slugs).to include *features.keys
    end # it
  end # describe

  describe '::roots' do
    it { expect(described_class).to respond_to(:roots).with(0).arguments }

    it 'returns a Mongoid criteria' do
      expect(described_class.roots).to be_a Mongoid::Criteria
    end # it

    describe 'with three parents and nine children' do
      let(:parents) { Array.new(3).map { create :directory } }
      let!(:children) do
        parents.map do |parent|
          Array.new(3).map { create :directory, :parent => parent }
        end.flatten # each
      end # let

      it 'returns the parents' do
        expect(Set.new described_class.roots.to_a).to be == Set.new(parents)
      end # let
    end # describe
  end # describe

  ### Attributes ###

  describe '#title' do
    it { expect(instance).to have_property :title }
  end # describe

  describe '#slug' do
    let(:value) { attributes_for(:directory).fetch(:title).parameterize }

    it { expect(instance).to have_property :slug }

    it 'is generated from the title' do
      expect(instance.slug).to be == instance.title.parameterize
    end # it

    it 'sets #slug_lock to true' do
      expect { instance.slug = value }.to change(instance, :slug_lock).to(true)
    end # it
  end # describe

  describe '#slug_lock' do
    it { expect(instance).to have_property :slug_lock }
  end # describe

  ### Relations ###

  describe '#parent' do
    it { expect(instance).to have_reader(:parent_id).with(nil) }

    it { expect(instance).to have_reader(:parent).with(nil) }

    wrap_context 'with a parent directory' do
      it { expect(instance.parent_id).to be == parent.id }
    end # context
  end # describe

  describe '#children' do
    it { expect(instance).to have_reader(:children).with([]) }

    wrap_context 'with many child directories' do
      it { expect(instance.children).to be == children }

      it 'destroys the children on destroy' do
        instance.save!
        children.map &:save!

        expect { instance.destroy }.to change(Directory, :count).by(-(1 + children.count))
      end # it
    end # context
  end # describe

  describe '#directories' do
    it { expect(instance).to have_reader(:directories).with([]) }

    wrap_context 'with many child directories' do
      it { expect(instance.directories).to be == children }
    end # context
  end # describe

  describe '#features' do
    it { expect(instance).to have_reader(:features).with([]) }

    wrap_context 'with many features' do
      it { expect(instance.features).to be == features }

      it 'destroys the features on destroy' do
        instance.save!
        features.map &:save!

        expect { instance.destroy }.to change(Feature, :count).by(-features.count)
      end # it
    end # context
  end # describe

  ### Validation ###

  describe 'validation' do
    it { expect(instance).to be_valid }

    describe 'title must be present' do
      let(:attributes) { super().merge :title => nil }

      it { expect(instance).to have_errors.on(:title).with_message("can't be blank") }
    end # describe

    describe 'slug must be present' do
      let(:attributes) { super().merge :slug => nil }

      it { expect(instance).to have_errors.on(:slug).with_message("can't be blank") }
    end # describe

    describe 'slug must not match reserved values' do
      context 'with "admin"' do
        let(:attributes) { super().merge :slug => 'admin' }

        it { expect(instance).to have_errors.on(:slug).with_message("is reserved") }
      end # context

      context 'with "index"' do
        let(:attributes) { super().merge :slug => 'index' }

        it { expect(instance).to have_errors.on(:slug).with_message("is reserved") }
      end # context

      context 'with "edit"' do
        let(:attributes) { super().merge :slug => 'edit' }

        it { expect(instance).to have_errors.on(:slug).with_message("is reserved") }
      end # context

      context 'with "directories"' do
        let(:attributes) { super().merge :slug => 'directories' }

        it { expect(instance).to have_errors.on(:slug).with_message("is reserved") }
      end # context
    end # describe

    describe 'slug must be unique within parent_id scope' do
      context 'with a sibling directory' do
        before(:each) { create :directory, :slug => instance.slug }

        it { expect(instance).to have_errors.on(:slug).with_message("is already taken") }
      end # context

      context 'with a sibling feature' do
        before(:each) { create :feature, :slug => instance.slug }

        it { expect(instance).to have_errors.on(:slug).with_message("is already taken") }
      end # context

      wrap_context 'with a parent directory' do
        before(:each) { create :directory, :slug => instance.slug }

        it { expect(instance).not_to have_errors.on(:slug) }

        context 'with a sibling directory' do
          before(:each) { create :directory, :parent => parent, :slug => instance.slug }

          it { expect(instance).to have_errors.on(:slug).with_message("is already taken") }
        end # context

        context 'with a sibling feature' do
          before(:each) { create :directory_feature, :directory => parent, :slug => instance.slug }

          it { expect(instance).to have_errors.on(:slug).with_message("is already taken") }
        end # context
      end # context
    end # describe
  end # describe

  ### Instance Methods ###

  describe '#ancestors' do
    it { expect(instance).to respond_to(:ancestors).with(0).arguments }

    it { expect(instance.ancestors).to be == [] }

    wrap_context 'with a parent directory' do
      it { expect(instance.ancestors).to be == [parent] }
    end # describe

    wrap_context 'with many ancestor directories' do
      it { expect(instance.ancestors).to be == ancestors }
    end # describe
  end # describe

  describe '#root?' do
    it { expect(instance).to respond_to(:root?).with(0).arguments }

    it { expect(instance.root?).to be true }

    wrap_context 'with a parent directory' do
      it { expect(instance.root?).to be false }
    end # describe
  end # describe

  describe '#to_partial_path' do
    it { expect(instance).to respond_to(:to_partial_path).with(0).arguments }

    it { expect(instance.to_partial_path).to be == instance.slug }

    describe 'with a parent directory', :parent => :one do
      let(:slugs) { instance.ancestors.map(&:slug).push(instance.slug) }

      it { expect(instance.to_partial_path).to be == slugs.join('/') }

      context 'with an empty slug' do
        let(:attributes) { super().merge :slug => nil }
        let(:slugs)      { super()[0...-1] }

        it { expect(instance.to_partial_path).to be == slugs.join('/') }
      end # context
    end # describe

    wrap_context 'with many ancestor directories' do
      let(:slugs) { instance.ancestors.map(&:slug).push(instance.slug) }

      it { expect(instance.to_partial_path).to be == slugs.join('/') }
    end # describe
  end # describe
end # describe
