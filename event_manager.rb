require "csv"
require "sunlight"

class EventManager
  INVALID_ZIPCODE = "00000"
  INVALID_PHONE_NUMBER = "0000000000"
  Sunlight::Base.api_key = "e179a6973728c4dd3fb1204283aaccb5"
  
  def initialize(filename)
    puts "EventManager Initialized."
    @file = CSV.open(filename, {:headers => true, :header_converters => :symbol})
  end

  def print_names
    @file.each do |line|
      puts "#{line[:first_name]} #{line[:last_name]}"
    end
  end

  def print_numbers
    @file.each do |line|
      puts clean_number(line[:homephone])
    end
  end

  def clean_number(number)
    number.gsub!(/[^\d]/, '')
    if number.length == 10
      # do nothing
    elsif number.length == 11
      if number.start_with?("1")
        number = number[1..-1]
      else
        number = INVALID_PHONE_NUMBER
      end
    else
      number = INVALID_PHONE_NUMBER
    end
    return number
  end
  
  def print_zipcodes
    @file.each do |line|
      zipcode = clean_zipcode(line[:zipcode])
      puts zipcode
    end
  end
  
  def clean_zipcode(original)
    if original.nil?
      result = INVALID_ZIPCODE
    elsif original.length < 5
      result = original.prepend("0") until original.length == 5
    else
      result = original
    end
    
    return result
  end
  
  def output_data(filename)
    output = CSV.open(filename, "w")
    @file.each do |line|
      if @file.lineno == 0
        output << line.headers
      else
        line[:homephone] = clean_number(line[:homephone])
        line[:zipcode] = clean_zipcode(line[:zipcode])
        output << line
      end
    end
  end
  
  def rep_lookup
    # prevents killing the API
    20.times do
      line = @file.readline
      
      legislators = Sunlight::Legislator.all_in_zipcode(clean_zipcode(line[:zipcode]))
      names = legislators.collect do |leg|
        first_name = leg.firstname
        first_initial = first_name[0]
        last_name = leg.lastname
        party = leg.party
        title = leg.title
        title + " " + first_initial + ". " + last_name + " (#{party})"
      end
      
      representative = "unknown"
      # API lookup goes here
      puts "#{line[:last_name]}, #{line[:first_name]}, #{line[:zipcode]}, #{names.join(", ")}"
    end
  end
  
  def create_form_letters
    letter = File.open("form_letter.html", "r").read
    20.times do
      line = @file.readline
      custom_letter = letter.gsub("#first_name",line[:first_name])
      custom_letter = custom_letter.gsub("#last_name",line[:last_name])
      custom_letter = custom_letter.gsub("#street", line[:street])
      custom_letter = custom_letter.gsub("#city", line[:city])
      custom_letter = custom_letter.gsub("#state", line[:state])
      custom_letter = custom_letter.gsub("#zipcode", line[:zipcode])
      filename = "output/thanks_#{line[:last_name]}_#{line[:first_name]}.html"
      output = File.new(filename, "w")
      output.write(custom_letter)
    end
  end
  
  
end

manager = EventManager.new("event_attendees.csv")
manager.rep_lookup
manager.create_form_letters
manager.output_data("event_attendees_clean.csv")
