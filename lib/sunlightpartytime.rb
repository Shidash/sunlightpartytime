require "httparty"
require "json"

class SunlightPartyTime
  def initialize(apikey)
    @apikey = apikey
  end

  # Get legislator ID
  def crp_id(name)
    options = {:query => {:apikey => @apikey} }
    namearray = name.split(" ")
    data = HTTParty.get("http://congress.api.sunlightfoundation.com/legislators?query="+namearray.last, options)["results"]

    data.each do |l| 
      dhash = Hash[*l.flatten]
      if data.length > 1
        return dhash["crp_id"] if dhash["first_name"] == namearray.first
      else return dhash["crp_id"]
      end
    end
  end

  # Get all events a legislator is a beneficiary of
  def parties(cid)
    options = {:query => {:apikey => @apikey} }
    data = HTTParty.get("http://politicalpartytime.org/api/v1/event/?beneficiaries__crp_id=" + cid.to_s + "&format=json", options)["objects"]
    return data.to_json
  end

  # Get a cleaner JSON of party events
  def parties_clean(cid)
    parties = JSON.parse(parties(cid))
    partyarray = Array.new

    parties.each do |p|
      savehash = Hash.new
      phash = Hash[*p.flatten]
      
      savehash["start time"] = phash["start_date"].to_s
      savehash["end time"] = phash["end_date"].to_s
      savehash["headline"] = "Party: " + phash["entertainment"].to_s 
      savehash["text"] = "contributions_info: " + phash["contributions_info"].to_s + " venue: " + phash["venue"]["venue_name"].to_s + " " +  phash["venue"]["city"].to_s + ", " + phash["venue"]["state"].to_s 
      
      partyarray.push(savehash)
    end
    
    partyarray.to_json
  end
end
