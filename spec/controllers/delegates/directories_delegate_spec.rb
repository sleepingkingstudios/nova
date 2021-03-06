# spec/controllers/delegates/directories_delegate_spec.rb

require 'rails_helper'

require 'delegates/directories_delegate'

RSpec.describe DirectoriesDelegate, :type => :decorator do
  include Spec::Contexts::Controllers::ResourcesContexts
  include Spec::Contexts::Delegates::DelegateContexts

  shared_context 'with request params' do
    let(:params) do
      ActionController::Parameters.new(
        :directory => {
          :title => 'Some Title',
          :slug  => 'Some Slug',
          :evil  => 'malicious'
        } # end hash
      ) # end hash
    end # let
  end # shared_context

  shared_examples 'sanitizes directory attributes' do
    it 'whitelists directory attributes' do
      %w(title slug).each do |attribute|
        expect(sanitized[attribute]).to be == params.fetch(:directory).fetch(attribute)
      end # each
    end # it

    it 'excludes unrecognized attributes' do
      expect(sanitized).not_to have_key 'evil'
    end # it
  end # shared_examples

  let(:object)   { nil }
  let(:instance) { described_class.new object }

  describe '::new' do
    it { expect(described_class).to construct.with(0..1).arguments }

    describe 'with no arguments' do
      let(:instance) { described_class.new }

      it 'sets the resource class' do
        expect(instance.resource_class).to be Directory
      end # it
    end # it
  end # describe

  ### Instance Methods ###

  describe '#build_resource_params' do
    include_context 'with request params'

    let(:directories) { [] }
    let(:sanitized)   { instance.build_resource_params params }

    before(:each) do
      instance.directories = directories
    end # before each

    expect_behavior 'sanitizes directory attributes'

    it 'assigns parent => nil' do
      expect(sanitized[:parent]).to be nil
    end # it

    context 'with many directories' do
      include_context 'with a valid path to a directory'

      it 'assigns parent => directories.last' do
        expect(sanitized[:parent]).to be == directories.last
      end # it
    end # context
  end # describe

  describe '#resource_params' do
    include_context 'with request params'

    let(:sanitized) { instance.resource_params params }

    expect_behavior 'sanitizes directory attributes'
  end # describe

  describe '#update_resource_params' do
    include_context 'with request params'

    let(:directories) { [] }
    let(:sanitized)   { instance.update_resource_params params }

    before(:each) do
      instance.directories = directories
    end # before each

    expect_behavior 'sanitizes directory attributes'
  end # describe

  ### Actions ###

  describe '#new', :controller => true do
    let(:directories) { [] }
    let(:request)     { double('request', :params => ActionController::Parameters.new({})) }

    before(:each) do
      instance.directories = directories
    end # before each

    it 'assigns a directory' do
      instance.new request

      expect(assigns[:resource]).to be_a Directory
    end # it
  end # describe

  describe '#create', :controller => true do
    let(:directories) { [] }
    let(:attributes)  { {} }
    let(:request)     { double('request', :params => ActionController::Parameters.new(:directory => attributes)) }

    before(:each) do
      instance.directories = directories
    end # before each

    describe 'with invalid params' do
      let(:attributes) { {} }

      it 'renders the new template' do
        expect(controller).to receive(:render).with(instance.new_template_path)

        instance.create request
      end # it

      it 'does not create a directory' do
        expect { instance.create request }.not_to change(Directory, :count)
      end # it
    end # describe

    describe 'with valid params' do
      let(:attributes)        { attributes_for :directory }
      let(:created_directory) { Directory.where(attributes).first }

      it 'creates a directory' do
        expect { instance.create request }.to change(Directory, :count).by(1)
      end # it

      it 'redirects to dashboard' do
        expect(controller).to receive(:redirect_to).with(/\A\/directory-\d+\/dashboard/)

        instance.create request
      end # it

      context 'with many directories' do
        include_context 'with a valid path to a directory'

        it 'sets the directory parent' do
          instance.create request

          expect(created_directory.ancestors).to be == directories
        end # it

        it 'redirects to dashboard' do
          expect(controller).to receive(:redirect_to).with(/\A\/#{segments.join '/'}\/directory-\d+\/dashboard/)

          instance.create request
        end # it
      end # context
    end # describe
  end # describe

  describe '#show', :controller => true do
    let(:object)  { create(:directory) }
    let(:request) { double('request', :params => ActionController::Parameters.new({})) }

    it 'renders the show template' do
      expect(controller).to receive(:render).with(instance.show_template_path)

      instance.show request

      expect(assigns[:resource]).to be == object
    end # it

    describe 'with an unpublished index page' do
      let!(:index_page) { create(:page, :directory => object, :slug => 'index', :content => build(:content)) }

      it 'renders the directory show template' do
        expect(controller).to receive(:render).with(instance.show_template_path)

        instance.show request

        expect(assigns[:resource]).to be == object
      end # it
    end # describe

    describe 'with an index page' do
      let!(:index_page) { create(:page, :directory => object, :slug => 'index', :published_at => 1.day.ago, :content => build(:content)) }

      it 'renders the page show template' do
        expect(controller).to receive(:render).with(instance.page_template_path)

        instance.show request

        expect(assigns[:resource]).to be == index_page
      end # it
    end # describe
  end # describe

  ### Partial Methods ###

  describe '#page_template_path' do
    it { expect(instance).to have_reader(:page_template_path).with('features/pages/show') }
  end # describe

  ### Routing Methods ###

  describe '#_dashboard_resource_path' do
    it { expect(instance.send :_dashboard_resource_path).to be == '/dashboard' }

    context 'with one directory' do
      let(:directory) { build(:directory) }

      before(:each) { allow(instance).to receive(:resource).and_return(directory) }

      it { expect(instance.send :_dashboard_resource_path).to be == "/#{directory.slug}/dashboard" }
    end # pending

    context 'with many directories' do
      include_context 'with a valid path to a directory'

      let(:directory)  { build(:directory, :parent => directories.last) }

      before(:each) do
        allow(instance).to receive(:resource).and_return(directory)

        instance.directories = directories
      end # before each

      it { expect(instance.send :_dashboard_resource_path).to be == "/#{segments.join '/'}/#{directory.slug}/dashboard" }
    end # context
  end # describe

  describe '#_resources_path' do
    it { expect(instance.send :_resources_path).to be == '/directories' }

    context 'with many directories' do
      include_context 'with a valid path to a directory'

      before(:each) do
        instance.directories = directories
      end # before each

      it { expect(instance.send :_resources_path).to be == "/#{segments.join '/'}/directories" }
    end # context
  end # describe
end # describe
