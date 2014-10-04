# spec/controllers/concerns/content_building_spec.rb

require 'rails_helper'

RSpec.describe ContentBuilding, :type => :controller_concern do
  shared_examples 'with resource content' do
    let(:content) { build(:content) }

    before(:each) { resource.content = content }
  end # shared_examples

  shared_examples 'with text content' do
    let(:content) { build(:text_content) }

    before(:each) { resource.content = content }
  end # shared_examples

  let(:resource) { build(:page) }
  let(:instance) do
    Struct.new(:resource).new(resource).extend(described_class)
  end # let

  describe '#build_content' do
    let(:params) { {} }

    it { expect(instance).to respond_to(:build_content).with(1..2).arguments }

    it 'sets the resource content' do
      expect { instance.build_content params }.to change(resource, :content).to(be_a Content)
    end # it

    context 'with an implicit content type' do
      let(:params) { super().merge :_type => 'TextContent' }

      it 'sets the resource content' do
        expect { instance.build_content params }.to change(resource, :content).to(be_a TextContent)
      end # it
    end # context

    context 'with an explicit content type' do
      it 'sets the resource content' do
        expect { instance.build_content params, 'TextContent' }.to change(resource, :content).to(be_a TextContent)
      end # it
    end # context
  end # describe

  describe '#content' do
    it { expect(instance).to have_reader(:content).with(nil) }

    context 'with resource content' do
      let(:content) { build(:content) }

      before(:each) { resource.content = content }

      it { expect(instance.content).to be == content }
    end # context
  end # describe

  describe '#content=' do
    let(:content) { build(:content) }

    it { expect(instance).to have_writer(:content=) }

    it 'sets the resource content' do
      expect { instance.content = content }.to change(resource, :content).to(content)
    end # it
  end # describe

  describe '#content_params' do
    let(:content_params) { { 'text_content' => 'It was a dark and stormy night...' } }
    let(:params)         { { :resource => { :content => content_params } } }

    it { expect(instance).to respond_to(:content_params).with(1).arguments }

    it { expect(instance.content_params params).to be == content_params }
  end # describe

  describe '#update_content' do
    include_context 'with text content'

    it { expect(instance).to respond_to(:update_content).with(1).argument }

    describe 'with the same content type' do
      let(:params) { { :_type => 'text', :text_content => '"Who\'s on first, What\'s on second, I Don\'t Know\'s on third..."' } }

      it 'updates the content' do
        expect { instance.update_content params }.to change { instance.content.text_content }.to(params[:text_content])
      end # it
    end # describe
  end # describe
end # describe