#!/usr/bin/env ruby

require 'json'
require 'date'
require 'open-uri'
require 'active_support/core_ext/numeric/time.rb'

htmlfile = '/var/www/html/delijn/index.html'
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
    <title>De Lijn</title>
  </head>

  <body>
    <!-- Fixed navbar -->
    <nav class="navbar navbar-dark bg-dark justify-content-between">
      <a class="navbar-brand" href="#">
        <img src="De_Lijn.svg" width="44" height="30" class="d-inline-block align-top" alt="delijn-logo">
        De Lijn 
      </a>
      <div>
      <span class="navbar-text mr-sm-2" data-toggle="collapse" data-target="#collapseOne" aria-expanded="true" aria-controls="collapseOne">
        <a href="#">[ Station -> Thuis ]</a>
      </span>
      <span class="navbar-text collapsed mr-sm-2 my-sm-0" data-toggle="collapse" data-target="#collapseTwo" aria-expanded="false" aria-controls="collapseTwo">
        <a href="#">[ Thuis -> Station ]</a>
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
                </tr>
              </thead>
              <tbody>'

url = 'https://api.delijn.be/DLKernOpenData/v1/beta/routeplan/51.1716587,4.1422111/51.1547773,4.1549527'
subscription_key = '<<REDACTED>>'

response = open(url, "Ocp-Apim-Subscription-Key" => subscription_key)
json = JSON.parse(response.read)

json['reiswegen'].each do |reisweg|
  if reisweg['reiswegStappen'].count <= 3
    reisweg['reiswegStappen'].each do |reiswegstap|
      if reiswegstap['type'] != 'WANDELEN' and reiswegstap['type'] != 'WACHTEN'
        # Get the data from the json
        departure = reiswegstap['duurtijd']['start']
        linenumber = reiswegstap['lijnrichting']['lijnnummer']
        linedirection = reiswegstap['lijnrichting']['richting']
        linedescription = reiswegstap['lijnrichting']['omschrijving']
        platformid = reiswegstap['vertrekPunt']['id']
        platformname = reiswegstap['vertrekPunt']['naam']
        arrival = reiswegstap['duurtijd']['einde']

        #Parse the data to something more human friendly
        timeleft = ((DateTime.parse(departure.to_s + Time.now.strftime("%:z").to_s) - DateTime.now) * 24 * 60).to_i
        duration = ((DateTime.parse(arrival.to_s) - DateTime.parse(departure.to_s)) * 24 * 60).to_i 
        departure = DateTime.parse(departure.to_s).strftime('%H:%M')
        arrival = DateTime.parse(arrival.to_s).strftime('%H:%M')
        linenumber = linenumber.to_s[1..-1]
        linedirection = linedirection.to_s
        linedescription = linedescription.to_s
        platformid = platformid.to_s

        # Do some prettifications
        if linedirection == 'TERUG'
          linedescription = linedescription.split(' - ').reverse.join(' - ')
        end

        #Output the data
htmloutput << "
                <tr>
                  <td>#{platformid} #{platformname}</td>
                  <td>#{timeleft}m</td>
                  <td>#{departure}</td>
                  <td>#{arrival}</td>
                  <td>[#{linenumber}] #{linedescription}</td>
                  <td>#{duration}m</td>
                </tr>"
      end
    end
  end
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
                </tr>
              </thead>
              <tbody>'

# Enter reverse direction logic here
url = 'https://api.delijn.be/DLKernOpenData/v1/beta/routeplan/51.1547773,4.1549527/51.1716587,4.1422111'
subscription_key = '<<REDACTED>>'

response = open(url, "Ocp-Apim-Subscription-Key" => subscription_key)
json = JSON.parse(response.read)

json['reiswegen'].each do |reisweg|
  if reisweg['reiswegStappen'].count <= 3
    reisweg['reiswegStappen'].each do |reiswegstap|
      if reiswegstap['type'] != 'WANDELEN' and reiswegstap['type'] != 'WACHTEN'
        # Get the data from the json
        departure = reiswegstap['duurtijd']['start']
        linenumber = reiswegstap['lijnrichting']['lijnnummer']
        linedirection = reiswegstap['lijnrichting']['richting']
        linedescription = reiswegstap['lijnrichting']['omschrijving']
        platformid = reiswegstap['vertrekPunt']['id']
        platformname = reiswegstap['vertrekPunt']['naam']
        arrival = reiswegstap['duurtijd']['einde']

        #Parse the data to something more human friendly
        timeleft = ((DateTime.parse(departure.to_s + Time.now.strftime("%:z").to_s) - DateTime.now) * 24 * 60).to_i
        duration = ((DateTime.parse(arrival.to_s) - DateTime.parse(departure.to_s)) * 24 * 60).to_i
        departure = DateTime.parse(departure.to_s).strftime('%H:%M')
        arrival = DateTime.parse(arrival.to_s).strftime('%H:%M')
        linenumber = linenumber.to_s[1..-1]
        linedirection = linedirection.to_s
        linedescription = linedescription.to_s
        platformid = platformid.to_s

        # Do some prettifications
        if linedirection == 'TERUG'
          linedescription = linedescription.split(' - ').reverse.join(' - ')
        end

        #Output the data
htmloutput << "
                <tr>
                  <td>#{platformid} #{platformname}</td>
                  <td>#{timeleft}m</td>
                  <td>#{departure}</td>
                  <td>#{arrival}</td>
                  <td>[#{linenumber}] #{linedescription}</td>
                  <td>#{duration}m</td>
                </tr>"
      end
    end
  end
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


# From home to station
#https://api.delijn.be/DLKernOpenData/v1/beta/routeplan/51.1547773,4.1549527/51.1716587,4.1422111

# From station to home
#https://api.delijn.be/DLKernOpenData/v1/beta/routeplan/51.1716587,4.1422111/51.1547773,4.1549527
