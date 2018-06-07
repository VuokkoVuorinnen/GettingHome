#!/usr/bin/env ruby

require 'open-uri'
require 'nokogiri'
require 'date'
require 'active_support/core_ext/numeric/time.rb'

htmlfile = '/var/www/html/nmbs/index.html'
htmloutput = '
<!doctype html>
<html lang="en">
  <head>
    <!-- Required meta tags -->
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
    <!-- Reload every X seconds -->
    <meta http-equiv="Refresh" content="60">
    <!-- Bootstrap CSS -->
    <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/4.0.0-beta.2/css/bootstrap.min.css" integrity="sha384-PsH8R72JQ3SOdhVi3uxftmaW6Vc51MKb0q5P2rRUpPvrszuE4W1povHYgTpBfshb" crossorigin="anonymous">
    <!-- Custom styles for this template -->
    <link href="sticky-footer-navbar.css" rel="stylesheet">
    <title>NMBS</title>
  </head>

  <body>
    <!-- Fixed navbar -->
    <nav class="navbar navbar-dark bg-dark justify-content-between">
      <a class="navbar-brand" href="#">
        <img src="logo-nmbs-sncb.ashx" width="44" height="30" class="d-inline-block align-top" alt="nmbs-logo">
        NMBS
      </a>
      <div>
      <span class="navbar-text mr-sm-2" data-toggle="collapse" data-target="#collapseOne" aria-expanded="true" aria-controls="collapseOne">
        <a href="#">[ Antwerpen-Centraal -> Sint-Niklaas ]</a>
      </span>
      <span class="navbar-text collapsed mr-sm-2 my-sm-0" data-toggle="collapse" data-target="#collapseTwo" aria-expanded="false" aria-controls="collapseTwo">
        <a href="#">[ Sint-Niklaas -> Antwerpen-Centraal ]</a>
      </span>
      </div>
    </nav>

    <div id="accordion">
      <div class="card" style="border: 0px">
        <div id="collapseOne" class="collapse show" data-parent="#accordion">
          <div class="card-body">
            <table class="table table-hover">
              <thead>
                <tr>
                  <th>Platform</th>
                  <th>ETA</th>
                  <th>Departure</th>
                  <th>Arrival</th>
                  <th>Direction</th>
                  <th>Duration</th>
                  <th>Delay</th>
                </tr>
              </thead>
              <tbody>'

url = 'https://api.irail.be/connections/?to=008894508&from=008821006'
xml = Nokogiri::XML(open(url))

xml.xpath("//connection").each do |connection|

  # Get the data from the XML
  departure = connection.xpath("./departure/time/@formatted")
  platform = connection.xpath("./departure/platform/text()")
  normalplatform = connection.xpath("./departure/platform/@normal")
  vehicle = connection.xpath("./departure/vehicle/text()")
  arrival = connection.xpath("./arrival/time/@formatted")
  direction = connection.xpath("./arrival/direction/text()")
  delay = connection.xpath("./departure/@delay")
  arrivaldelay = connection.xpath("./arrival/@delay")
  duration = connection.xpath("./duration/text()")
  canceled = connection.xpath("./departure/@canceled")

  # Parse the data to something more human friendly
  timeleft = ((DateTime.parse(departure.to_s + Time.now.strftime("%:z").to_s) - DateTime.now) * 24 * 60).to_i
  updateddeparture = DateTime.parse(departure.to_s)
  departure = DateTime.parse(departure.to_s).strftime('%H:%M')
  updatedarrival = DateTime.parse(arrival.to_s)
  arrival = DateTime.parse(arrival.to_s).strftime('%H:%M')
  duration = duration.to_s.to_i / 60
  vehicle = vehicle.to_s.gsub("BE.NMBS.", "").gsub(/[0-9]*/, "")
  delay = delay.to_s.to_i / 60
  arrivaldelay = delay.to_s.to_i / 60
  platform = platform.to_s
  normalplatform = normalplatform.to_s
  canceled = canceled.to_s

  # Make it clear that the train is not leaving from it's regular platform
  if platform != normalplatform
    platform = "<strong>#{platform}</strong>"
  end

  # Let's update the departure time if there's a delay
  if delay != 0
    updateddeparture = updateddeparture + delay.minutes
    departure = departure + " (<strong class=\"text-danger\">" + updateddeparture.strftime('%H:%M') + "</strong>)"
  end

  # Let's update the arrival time if there's a delay
  if arrivaldelay != 0
    updatedarrival = updatedarrival + delay.minutes
    arrival = arrival + " (<strong class=\"text-danger\">" + updatedarrival.strftime('%H:%M') + "</strong>)"
  end

  # Make it clear that there is a delay
  if delay == 0
    delay = "<td>" + delay.to_s + "m</td>"
  else
    delay = "<td class=\"text-danger\"><strong>" + delay.to_s + "m</strong></td>"
  end

  # The train was cancelled, let's signal that
  if canceled != '0'
    delay = "<td class=\"text-danger\"><strong>CANCELED</strong></td>"
  end

  # Make it clear that a train is about to leave
  if timeleft < 10
    timeleft = "<td class=\"text-danger\"><strong>" + timeleft.to_s + "m</strong></td>"
  else
    timeleft = "<td>" + timeleft.to_s + "m</td>"
  end

htmloutput << "
                <tr>
                  <td>#{platform}</td>
                  #{timeleft}
                  <td>#{departure}</td>
                  <td>#{arrival}</td>
                  <td>[#{vehicle}] #{direction}</td>
                  <td>#{duration}m</td>
                  #{delay}
                </tr>"

end

htmloutput <<'
              </tbody>
            </table>
          </div>
        </div>
      </div>

      <div class="card" style="border: 0px">
        <div id="collapseTwo" class="collapse" data-parent="#accordion">
          <div class="card-body">    
            <table class="table table-hover">
              <thead>
                <tr>
                  <th>Platform</th>
                  <th>ETA</th>
                  <th>Departure</th>
                  <th>Arrival</th>
                  <th>Direction</th>
                  <th>Duration</th>
                  <th>Delay</th>
                </tr>
              </thead>
              <tbody>'

url = 'https://api.irail.be/connections/?to=008821006&from=008894508'
xml = Nokogiri::XML(open(url))

xml.xpath("//connection").each do |connection|

  # Get the data from the XML
  departure = connection.xpath("./departure/time/@formatted")
  platform = connection.xpath("./departure/platform/text()")
  normalplatform = connection.xpath("./departure/platform/@normal")
  vehicle = connection.xpath("./departure/vehicle/text()")
  arrival = connection.xpath("./arrival/time/@formatted")
  direction = connection.xpath("./arrival/direction/text()")
  delay = connection.xpath("./departure/@delay")
  arrivaldelay = connection.xpath("./arrival/@delay")
  duration = connection.xpath("./duration/text()")
  canceled = connection.xpath("./departure/@canceled")

  # Parse the data to something more human friendly
  timeleft = ((DateTime.parse(departure.to_s + Time.now.strftime("%:z").to_s) - DateTime.now) * 24 * 60).to_i
  updateddeparture = DateTime.parse(departure.to_s)
  departure = DateTime.parse(departure.to_s).strftime('%H:%M')
  updatedarrival = DateTime.parse(arrival.to_s)
  arrival = DateTime.parse(arrival.to_s).strftime('%H:%M')
  duration = duration.to_s.to_i / 60
  vehicle = vehicle.to_s.gsub("BE.NMBS.", "").gsub(/[0-9]*/, "")
  delay = delay.to_s.to_i / 60
  arrivaldelay = delay.to_s.to_i / 60
  platform = platform.to_s
  normalplatform = normalplatform.to_s
  canceled = canceled.to_s

  # Make it clear that the train is not leaving from it's regular platform
  if platform != normalplatform
    platform = "<strong>#{platform}</strong>"
  end

  # Let's update the departure time if there's a delay
  if delay != 0
    updateddeparture = updateddeparture + delay.minutes
    departure = departure + " (<strong class=\"text-danger\">" + updateddeparture.strftime('%H:%M') + "</strong>)"
  end

  # Let's update the arrival time if there's a delay
  if arrivaldelay != 0
    updatedarrival = updatedarrival + delay.minutes
    arrival = arrival + " (<strong class=\"text-danger\">" + updatedarrival.strftime('%H:%M') + "</strong>)"
  end

  # Make it clear that there is a delay
  if delay == 0
    delay = "<td>" + delay.to_s + "m</td>"
  else
    delay = "<td class=\"text-danger\"><strong>" + delay.to_s + "m</strong></td>"
  end

  # The train was cancelled, let's signal that
  if canceled != '0'
    delay = "<td class=\"text-danger\"><strong>CANCELED</strong></td>"
  end

  # Make it clear that a train is about to leave
  if timeleft < 10
    timeleft = "<td class=\"text-danger\"><strong>" + timeleft.to_s + "m</strong></td>"
  else
    timeleft = "<td>" + timeleft.to_s + "m</td>"
  end

htmloutput << "
                <tr>
                  <td>#{platform}</td>
                  #{timeleft}
                  <td>#{departure}</td>
                  <td>#{arrival}</td>
                  <td>[#{vehicle}] #{direction}</td>
                  <td>#{duration}m</td>
                  #{delay}
                </tr>"

end

lastgenerated = Time.now.strftime("%Y-%m-%d %H:%M:%S")

htmloutput <<"
              </tbody>
            </table>
          </div>
        </div>
      </div>
    </div>

    <footer class=\"footer\">
      <div class=\"container text-right\">
        <span class=\"text-muted\">Last updated: #{lastgenerated}</span>
      </div>
    </footer>

    <!-- jQuery first, then Tether, then Bootstrap JS. -->
    <script src=\"https://code.jquery.com/jquery-3.1.1.slim.min.js\" integrity=\"sha384-A7FZj7v+d/sdmMqp/nOQwliLvUsJfDHW+k9Omg/a/EheAdgtzNs3hpfag6Ed950n\" crossorigin=\"anonymous\"></script>
    <script src=\"https://cdnjs.cloudflare.com/ajax/libs/tether/1.4.0/js/tether.min.js\" integrity=\"sha384-DztdAPBWPRXSA/3eYEEUWrWCy7G5KFbe8fFjk5JAIxUYHKkDx6Qin1DkWx51bBrb\" crossorigin=\"anonymous\"></script>
    <script src=\"https://maxcdn.bootstrapcdn.com/bootstrap/4.0.0-alpha.6/js/bootstrap.min.js\" integrity=\"sha384-vBWWzlZJ8ea9aCX4pEW3rVHjgjt7zpkNpZk+02D9phzyeVkE+jo0ieGizqPLForn\" crossorigin=\"anonymous\"></script>
    <script src=\"disable-collapse.js\"></script>
  </body>
</html>
"

File.open(htmlfile, 'w') do |f|
  f.write(htmloutput)
end
