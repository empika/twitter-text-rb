module Twitter
  # A module for including Tweet parsing in a class. This module provides function for the extraction and processing
  # of usernames, lists, URLs and hashtags.
  module Extractor

    # Extracts a list of all usernames mentioned in the Tweet <tt>text</tt>. If the
    # <tt>text</tt> is <tt>nil</tt> or contains no username mentions an empty array
    # will be returned.
    #
    # If a block is given then it will be called for each username.
    def extract_mentioned_screen_names(text) # :yields: username
      return [] unless text

      possible_screen_names = []
      text.scan(Twitter::Regex[:extract_mentions]) do |before, sn, after|
        possible_screen_names << sn unless after =~ Twitter::Regex[:at_signs]
      end
      possible_screen_names.each{|sn| yield sn } if block_given?
      possible_screen_names
    end

    # Extracts the username username replied to in the Tweet <tt>text</tt>. If the
    # <tt>text</tt> is <tt>nil</tt> or is not a reply nil will be returned.
    #
    # If a block is given then it will be called with the username replied to (if any)
    def extract_reply_screen_name(text) # :yields: username
      return nil unless text

      possible_screen_name = text.match(Twitter::Regex[:extract_reply])
      return unless possible_screen_name.respond_to?(:captures)
      screen_name = possible_screen_name.captures.first
      yield screen_name if block_given?
      screen_name
    end

    # Extracts a list of all URLs included in the Tweet <tt>text</tt>. If the
    # <tt>text</tt> is <tt>nil</tt> or contains no URLs an empty array
    # will be returned.
    #
    # If a block is given then it will be called for each URL.
    def extract_urls(text) # :yields: url
      return [] unless text
      urls = []
      text.to_s.scan(Twitter::Regex[:valid_url]) do |all, before, url, protocol, domain, path, query|
        urls << (protocol == "www." ? "http://#{url}" : url)
      end
      urls.each{|url| yield url } if block_given?
      urls
    end

    # Extracts a list of all hashtags included in the Tweet <tt>text</tt>. If the
    # <tt>text</tt> is <tt>nil</tt> or contains no hashtags an empty array
    # will be returned. The array returned will not include the leading <tt>#</tt>
    # character.
    #
    # If a block is given then it will be called for each hashtag.
    def extract_hashtags(text, leading_character = false) # :yields: hashtag_text
      return [] unless text
      tags = [] 
      text.scan(Twitter::Regex[:auto_link_hashtags]) do |before, hash, hash_text|
        hash_text = hash << hash_text if leading_character
        tags << hash_text
      end
      tags.each{|tag| yield tag } if block_given?
      tags
    end
    
    # Extracts a list of hashtags in the same manner as extract_hashtags.
    # However, this method will also decompose composite hashtags:
    # For example, <tt>#this.is.a.tag</tt> will generate as four tags.
    # The result is a nested array. Use ".flatten" if you want a simple
    # list.
    #
    # If a block is given then it will be called for each hashtag (flattened)
    def extract_composite_hashtags(text, leading_character = false)
      return [] unless text
      tags = [] 
      text.scan(Twitter::Regex[:auto_link_composite_hashtags]) do |before, hash, hash_text|
        if hash_text.include? '.'
          result = []
          hash_text.split('.').each { |composite_tag| result << (leading_character ? hash + composite_tag : composite_tag) }
        else
          result = leading_character ? hash + hash_text : hash_text
        end
        tags << result
      end
      tags.flatten.each{|tag| yield tag } if block_given?
      tags
    end

  end
end
