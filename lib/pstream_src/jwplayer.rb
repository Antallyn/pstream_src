class PstreamSrc::JWPlayer

    require "net/http"
    require "nokogiri"
    require "base64"
    require "json"

    HEADERS = {"Host" => "www.pstream.net","User-Agent"=>"Mozilla/5.0 (Windows NT 10.0; WOW64; x64; rv:105.0esr) Gecko/20010101 Firefox/105.0esr","Accept"=>"text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,*/*;q=0.8","Accept-Language"=>"en-US,en;q=0.5","Accept-Encoding"=>"deflate, br","Connection"=>"keep-alive","Upgrade-Insecure-Requests"=>"1","Sec-Fetch-Dest"=>"document","Sec-Fetch-Mode"=>"navigate","Sec-Fetch-Site"=>"same-origin"}
    
    def initialize(video_id, headers=HEADERS)
        @embed_link = "https://www.pstream.net/e/" + video_id
        @headers = headers #Changing headers may cause a 404 http code
    end

    def player_script
        request = http_request(@embed_link, @headers)
        raise PstreamSrc::InvalidVideoIDError unless request.code_type.equal? Net::HTTPOK # Raises an error if response code isn't 200
        source = Array.new # Array that will contain the script url
        scripts = Nokogiri::HTML5.parse(request.body).xpath("//script") #Will return an array of all script tags
        # The line above will take the source of all tags looking like the player script (there should be only one)
        scripts.each {|script_tag| source << script_tag["src"] if !script_tag["src"].nil? && script_tag["src"].start_with?("https://www.pstream.net/u/player-script")}
        raise PstreamSrc::UnthoughtError if source.size != 1 # Rases an error ff there is more or less than one source
        source.first
    end

    def master(script_url=player_script())
        request = http_request(script_url, @headers)
        raise PstreamSrc::UnthoughtError unless request.code_type.equal? Net::HTTPOK # Raises an error if response code isn't 200
        focus, final = Array.new, Array.new # "focus" will be used to contain cutted part of the script that match the base64 pattern whereas "final" will contain only the base64-encoded json
        cutlist = request.body.split("\n").last.split(/[\(\)]/).uniq # Will take the last line and cut at each occurence of ( or )
        # The line above, will remove all " characters from strings of the array and then check if it looks like a base64 encoded string
        cutlist.each {|part| focus << part if part.gsub!("\"", "").class == String ? part.match?(/^([A-Za-z0-9+\/]{4})*([A-Za-z0-9+\/]{3}=|[A-Za-z0-9+\/]{2}==)?$/) : nil}
        # At this point, "focus" is a list of strings matching the base64 pattern, but there is only one real base64 encoded string, and its size is large
        focus.each {|target| final << target if target.size >= 70}
        raise PstreamSrc::UnthoughtError if final.size != 1
        decoded = Base64.decode64 final.first # Finally, decode the string to get the json
        decoded.slice! 0..1 # After being decoded, the json has 2 invalid chars at the begining, so we slice like in the js script
        datas = JSON.parse(decoded)
        master = datas["mmmmmmmmmmmmmmmmmmmm"] # Yeah, don't ask me why the key pointing to the url has this name xD
        # If the key fortuitously changes, try to find the link anyway...
        datas.each_key {|key| master = datas[key] if datas[key].class.equal?(String) && datas[key].start_with?("https://www.pstream.net/m/") && datas[key].include?(".m3u8")} if master.nil?
        # If it doesn't work, raise an error
        raise PstreamSrc::UnthoughtError if master.nil?
        master
    end

    private
    def http_request(url, headers)                   
        uri = URI.parse(url)                             
        http = Net::HTTP.new uri.host, uri.port          
        http.use_ssl = true  
        request = Net::HTTP::Get.new(uri.request_uri) 
        headers.each_key do |key|
            request[key] = headers[key]
        end
        http.request(request)
    end
end