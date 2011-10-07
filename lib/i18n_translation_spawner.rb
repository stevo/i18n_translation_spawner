require "yaml/encoding"
require "i18n_translation_spawner/string"
require "i18n_translation_spawner/hash"

module I18n
  class TranslationSpawner

    class CannotDecodeTranslationFilePath < StandardError;
    end

    attr_accessor_with_default :skip_locales, []
    attr_accessor_with_default :removable_prefixes, %w()
    attr_accessor_with_default :default_translations, {}
    attr_accessor :exception_handler, :key_translations_handler, :translations_handler, :file_path_decoder, :cannot_decode_translation_file_path_handler

    private

    def translation_for_key(key, locale)
      if key_translations_handler.respond_to?(:call)
        key_translations_handler.call(key, locale, self)
      else
        default_translation_for_key(key, locale)
      end
    end

    def translation(key, locale)
      if translations_handler.respond_to?(:call)
        translations_handler.call(key, locale, self)
      else
        default_translation(key, locale)
      end
    end

    def decode_file_path(key, locale)
      if file_path_decoder.respond_to?(:call)
        file_path_decoder.call(key, locale, self)
      else
        default_decode_file_path(key, locale)
      end
    end

    def spawn_translation_key(key, locale, options, exception)
      I18n.available_locales.reject { |l| skip_locales.map(&:to_s).include?(l.to_s) }.each do |_locale|
        begin
          decode_file_path(key, _locale).tap do |path|
            translations_hash = YAML::load_file(path)
            hash_to_merge = "#{_locale.to_s}.#{key}".to_hash(translation(key, _locale.to_s)).deep_stringify_keys!
            translations_hash = translations_hash.deep_merge(hash_to_merge).to_ordered_hash
            File.open(path, 'w') { |f| f.write(YAML.unescape(translations_hash.ya2yaml.sub(/---\s*/,''))) }
          end
        rescue CannotDecodeTranslationFilePath
          if cannot_decode_translation_file_path_handler.respond_to?(:call)
            cannot_decode_translation_file_path_handler.call(key,locale,options,exception)
          else
            Rails.logger.info "=== Cannot access translation file for #{key.to_s}"
            return(options[:rescue_format] == :html ? exception.html_message : exception.message)
          end
        end
      end
      translation(key, locale.to_s)
    end

    public

    def default_decode_file_path(key, locale)
      if File.file?(path = File.join(Rails.root, "config/locales", "#{locale.to_s}.yml"))
        path
      else
        raise CannotDecodeTranslationFilePath
      end
    end

    def default_translation(key, locale)
      if translations_handler.respond_to?(:call)
        translations_handler(key, locale, self)
      else
        _key = key.dup
        while _key.present?
          if (val = default_translations[_key]).present?
            if val.is_a?(Hash)
              return(val[locale].present? ? val[locale] : translation_for_key(key, locale))
            else
              return(val.to_s)
            end
          else
            _key.sub!(/([a-zA-Z0-9_]*\.?)/, '')
          end
        end
        translation_for_key(key, locale)
      end
    end

    def default_translation_for_key(key, locale)
      key.split('.').last.sub(/\A#{removable_prefixes.map { |prefix| prefix+'_' }.join('|')}/, '').humanize
    end

    def call(exception, locale, key, options)
      if exception_handler.respond_to?(:call)
        exception_handler.call(exception, locale, key, self, options)
      else
        handle_exception(exception, locale, key, options)
      end
    end

    def handle_exception(exception, locale, key, options)
      case exception
      when I18n::MissingTranslationData
        spawn_translation_key(key, locale, options, exception)
      else
        raise exception
      end
    end

  end
end