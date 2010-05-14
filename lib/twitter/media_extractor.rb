module Twitter
  
  module MediaExtractor
    # include Extractor
    
    IMAGE_REGEX = {}
    
    IMAGE_REGEX[:twitpic] = /http:\/\/twitpic.com\/(.*)/ix
    IMAGE_REGEX[:tweetphoto] = /http:\/\/tweetphoto.com\/(.*)/ix
    
    # Extracts specifically image related media urls
    #
    # Yields the url, the key or identifier for the given service and a symbol for the service
    def extract_image_media_urls(text)
      media_urls = []
      extract_urls(text) do |url|
        IMAGE_REGEX.each_pair do |key, regex|
          url.scan regex do |id|
            media_urls << url            
            yield(url, id[0], key) if block_given?
          end
        end
      end
      media_urls
    end
    
  end
  
end