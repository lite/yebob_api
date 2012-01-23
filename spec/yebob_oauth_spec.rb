require_relative 'spec_helper.rb'

require 'oauth'
require 'oauth/consumer'
require 'ruby-debug'
require 'rexml/document'

API_KEY = LOLDONGS
API_KEY_PRIVATE = "reallylongnumberwithletters"

class Net::HTTP
  def address=(new_address)
    @address = new_address
  end
end

module OAuth
  class Consumer
    attr_accessor :username, :homeurl

    def silo_address=(address)
      @silo_address = address
      @orig_address = self.http.address
    end

    def create_signed_request(http_method,path, token=nil,request_options={},*arguments)

      # Use the original address to generate OAuth signature
      self.http.address = @orig_address if @orig_address

      request=create_http_request(http_method,path,*arguments)
      sign!(request,token,request_options)

      # Submit the request to the silo address
      self.http.address = @silo_address if @silo_address

      request
    end

  end
end

module OAuth
  class RequestToken
    def get_access_token(options={})
      response=consumer.token_request(consumer.http_method,consumer.access_token_path,self,options)
      self.consumer.silo_address = response[:subdomain]
      self.consumer.homeurl = response[:homeurl]
      self.consumer.username = response[:username]
      OAuth::AccessToken.new(consumer,response[:oauth_token],response[:oauth_token_secret]) 
    end
  end
end


class PhotoBucket
  attr_accessor :request_token, :access_token, :consumer

  def get_request_token
    @consumer=OAuth::Consumer.new(API_KEY,
                                  API_KEY_PRIVATE,
                                  {
                                    :site => "[api.photobucket.com"];, 
                                    :request_token_path => '/login/request',
                                    :authorize_path => '/apilogin/login',
                                    :access_token_path => '/login/access'
                                  })
    @consumer.http.set_debug_output($stderr)
    @request_token = @consumer.get_request_token
  end

  def get_authorize_url
    @request_token.authorize_url.gsub("api.photobucket.com", "photobucket.com" )
  end

  def get_access_token
    @access_token = @request_token.get_access_token
  end

  def find_albums
    root_album = nil
    sub_albums = []
    albums_doc = execute_request("/album/#{@consumer.username}?recurse=1" )
    albums_doc.each_recursive{ |node|
      if node.is_a? REXML::Element and node.name == "album"
        album = PhotoBucket::Album.new( node )
        if album.name == @consumer.username
          root_album = album
        else
          sub_albums << album
        end
      end
    }
    root_album.albums = sub_albums
    return root_album
  end

  protected

  # Returns REXML document
  def execute_request(query_str)
    debugger
    resp = @access_token.get(query_str)
    unless resp.code == "200"
      raise "HTTP code #{resp.code} for #{query_str}. Response body:\n#{resp.body}"
    end
    REXML::Document.new(resp.body)
  end

  class Album

    attr_accessor :photo_count, :subalbum_count, :albums, :photos, :videos, :video_count, :name


    def initialize(rexml_element)
      @albums = []; @videos = []; @photos = [];
      self.photo_count = rexml_element.attributes["photo_count"]
      self.video_count = rexml_element.attributes["video_count"]
      self.name = rexml_element.attributes["name"]
      self.subalbum_count = rexml_element.attributes["subalbum_count"]

      rexml_element.each_recursive{ |node|
        if node.is_a? REXML::Element and node.name == "media" and node.attributes["type"] == "image"

          @photos << PhotoBucket::Photo.new(node)
        end
      }
    end
  end

  class Photo
    attr_accessor :name, :uploaddate, :public, :url, :thumb, :title, :description, :browseurl

    def initialize(rexml_element)
      @name = rexml_element.attributes["name"]
      @uploaddate = rexml_element.attributes["uploaddate"]
      @privacy = rexml_element.attributes["privacy"]
      rexml_element.each_element{ |e|
        @browseurl = e.text if e.name == "browseurl"
        @url = e.text if e.name == "url"
        @thumb = e.text if e.name == "thumb"
        @title = e.text if e.name == "title"
        @description = e.text if e.name == "description"
      }
    end

  end

  class Video
  end

end

# Example:

pb = PhotoBucket.new

pb.get_request_token
auth_url = pb.get_authorize_url

puts "Go to #{auth_url}"
counter = 10
while counter > 0
  puts "Continuing in #{counter}s"; sleep 5; counter -= 5
end

pb.get_access_token
album = pb.find_albums