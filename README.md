# Pstream Src

PstreamSrc is a very basic gem to take the master HLS file out of a pstream.net jwplayer video using the famous [Nokogiri](https://github.com/sparklemotion/nokogiri) gem.
However, the link being generated is unique to your ip address and will expires after 10 minutes, if you try getting the file anyway you'll just get a 404 error. The links in the master file will not expire after the same amount of time so don't worry.
Do not forget to add the appropriate http headers to your request if you don't want to receive a 404 error.

## Installation

Clone this repo, and build the gem:

    $ gem build pstream_src.gemspec -o pstream_src.gem

Then, install the gem by executing:

    $ gem install ./pstream_src.gem

## Usage

This gem is very simple to use, you just need the pstream video id, it can be found at the end of the video link,
 Ex:``https://www.pstream.net/e/PvpVL4rvlarq26W -> PvpVL4rvlarq26W``

	require "pstream_src"
	pstream = PstreamSrc::JWPlayer.new("PvpVL4rvlarq26W")
	pstream.master #=> https://www.pstream.net/m/eyJpdiI6IjBkQ0ZKQjF6dE44aEI3V2Jib0lMcVE9PSIsInZhbHV ...

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/Antallyn/pstream_src.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
