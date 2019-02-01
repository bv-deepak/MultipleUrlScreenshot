class Blog::Setting < ApplicationRecord
  serialize :value, Hash
  belongs_to :blog

  module Key
    LP_CAPTCHA_LIMIT    = 1
    LP_TEMP_BLOCK_LIMIT = 2
    LP_BLOCK_ALL_LIMIT  = 3
    FW_DISABLED_RULES   = 4
    PLUGIN_BRANDING     = 5
    SITE_BADGE          = 6
    FW_WHITELIST_IPS    = 7
    FW_BLACKLIST_IPS    = 8
    LP_WHITELIST_IPS    = 9
    LP_BLACKLIST_IPS    = 10
    FW_BLOCK_COUNTRIES  = 11
    LP_BLOCK_COUNTRIES  = 12
    PAGE_URLS           = 13
  end

  KEYS = {}

  Blog::Setting::Key.constants.each { |key|
    KEYS[Blog::Setting::Key.class_eval(key.to_s)] = key
  }

  def self.create(key, value, blog_id)
    setting = self.new(:key => key, :value => value, :blog_id => blog_id)
    setting.save!
    setting
  end
end
