require 'test_helper'
require 'pry'

# Applicable only for LIT_STORAGE=hybrid
class HybridStorageTest < ActiveSupport::TestCase
  if ENV['LIT_STORAGE'] == 'hybrid'
    class Backend < Lit::I18nBackend
    end

    fixtures :all

    def setup
      Lit.init
      Lit::Localization.delete_all
      Lit::LocalizationKey.delete_all
      Lit::LocalizationVersion.delete_all
      @old_humanize_key = Lit.humanize_key
      Lit.humanize_key = false
      @old_load_path = I18n.load_path
      Lit.reset_hash
      I18n.backend.cache.clear
      @locale = Lit::Locale.find_by_locale(I18n.locale)
      super
    end

    def teardown
      Lit.loader = @old_loader
      Lit.humanize_key = @old_humanize_key
      I18n.backend = @old_backend
      I18n.load_path = @old_load_path
      super
    end

    test 'it should update translation both in hash and in redis' do
      # assertions to ensure that storage has been properly cleared
      assert_nil Lit._hash['en.fizz']
      assert_nil Lit.redis.get(Lit.prefix + 'en.fizz')
      I18n.t('fizz', default: 'buzz')
      assert_equal 'buzz', Lit._hash['en.fizz']
      assert_equal 'buzz', Lit.redis.get(Lit.prefix + 'en.fizz')
    end

    test 'it should clear hash when loading from redis something not yet in hash' do
      # let's do something that creates a hash snapshot timestamp
      assert_nil Lit._hash['en.fizz']
      old_hash_snapshot = Lit.hash_snapshot
      I18n.t('fizz', default: 'buzz')
      assert_operator Lit.hash_snapshot, :>, old_hash_snapshot

      # in the meantime let's create some new translation
      # simulate as if it were created and redis snapshot has been updated
      lk = Lit::LocalizationKey.create(localization_key: 'abcd')
      l = lk.localizations.create!(locale: @locale, default_value: 'efgh')

      Lit.redis.set(Lit.prefix + 'en.abcd', 'efgh')
      Lit.saved_redis_snapshot = Lit.now_timestamp
      Lit.redis_snapshot = Lit.saved_redis_snapshot
      # TODO: consider if this is not too implementation-specific

      # assert that the newly created localization has been fetched into hash
      assert_equal 'efgh', I18n.t('abcd')
      assert_equal 'efgh', Lit._hash['en.abcd']
      assert_equal 'efgh', Lit.redis.get(Lit.prefix + 'en.abcd')

      # assert that hash cache has been cleared
      assert_nil Lit._hash['en.fizz']
      I18n.t('fizz')

      # assert that the value then gets loaded into hash again
      assert_equal 'buzz', Lit._hash['en.fizz']
    end

    test 'local cache is used even when redis is cleared' do
      # define a translation by specifying default value
      assert_nil Lit._hash['en.fizz']
      I18n.t('fizz', default: 'buzz')
      assert_equal 'buzz', Lit._hash['en.fizz']

      # clear redis
      I18n.backend.cache.clear

      # modify local cache and then see if it's used for loading translation
      Lit._hash['en.fizz'] = 'fizzbuzz'
      assert_equal 'fizzbuzz', I18n.t('fizz')
    end
  else
    puts 'Skipping hybrid storage test'
  end
end
