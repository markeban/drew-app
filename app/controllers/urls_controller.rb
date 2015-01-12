class UrlsController < ApplicationController
require 'csv'
require 'json'


  def index
  end

  def results
    api_calls = Hash.new
    @json_and_placeholder = []

    url = params[:url]
    placeholders = params[:placeholder].gsub(/\s+/m, ' ').strip.split(" ")

    placeholders.each do |placeholder|
      api_calls[url.sub('placeholder', placeholder)] = placeholder
    end
    
    api_calls.each do |url, placeholder|
      json_data = Unirest.get(url).body
      json_data.each do |key, array|
        array.each do |hash|
          hash["placeholder"] = placeholder
          @json_and_placeholder.push(hash)
        end
      end
    end





    headers = %w{placeholder actor_name object_id translated_event_type date_time_in_timezone}
    file_name = "drew_data"

    csv_file = CSV.generate do |csv|
      csv << headers
      @json_and_placeholder.each do |hash|
        csv << headers.map { |h| hash[h] }
      end
    end
    send_data csv_file, :type => 'text/csv; charset=iso-8859-1; header=present', :disposition => "attachment;data=#{file_name}.csv"

  end

  private

  def url_params
    params.require(:url).permit(:url, :placeholder)
  end

end
