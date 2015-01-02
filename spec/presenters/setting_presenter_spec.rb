# spec/presenters/setting_presenter_spec.rb

require 'rails_helper'

require 'presenters/setting_presenter'

RSpec.describe SettingPresenter, :type => :decorator do
  let(:attributes) { attributes_for(:setting) }
  let(:setting)    { build(:setting, attributes) }
  let(:instance)   { described_class.new setting }

  describe '#fields_partial_path' do
    let(:expected) { "admin/settings/fields" }

    it { expect(instance).to have_reader(:fields_partial_path).with_value(expected) }

    context 'with a navigation list setting' do
      let(:setting)  { build(:navigation_list_setting, attributes) }
      let(:expected) { "admin/settings/#{setting.class.name.pluralize.underscore}/fields" }

      it { expect(instance).to have_reader(:fields_partial_path).with_value(expected) }
    end # context

    context 'with a string setting' do
      let(:setting)  { build(:string_setting, attributes) }
      let(:expected) { "admin/settings/#{setting.class.name.pluralize.underscore}/fields" }

      it { expect(instance).to have_reader(:fields_partial_path).with_value(expected) }
    end # context
  end # describe

  describe '#label' do
    let(:expected) do
      setting.key.to_s.split(/\./).map(&:capitalize).join(' ')
    end # let

    it { expect(instance).to have_reader(:label).with_value(expected) }

    context 'with a multipart key' do
      let(:attributes) { super().merge :key => 'multipart.key' }

      it { expect(instance.label).to be == expected }
    end # context
  end # describe

  describe '#name' do
    let(:expected) { setting.key.gsub('.', '_') }

    it { expect(instance).to have_reader(:name).with_value(expected) }

    context 'with a multipart key' do
      let(:attributes) { super().merge :key => 'multipart.key' }

      it { expect(instance.name).to be == expected }
    end # context
  end # describe

  describe '#setting' do
    it { expect(instance).to have_reader(:setting).with_value(setting) }
  end # describe
end # describe
