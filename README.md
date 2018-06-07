### How to use this?

## NMBS

Get your departure and arrival stations from https://docs.irail.be/#stations-stations-api-get

Fill in the departure and arrival stations in the nmbs.rb script.

Install needed gems

Create the /var/www/html/nmbs directory and copy the following files in there:
* logo-nmbs-sncb.ashx
* disable-collapse.js
* sticky-footer-navbar.css

Configure your apache/nginx to serve the directory

Run the script on a cron!

## De Lijn

Get your departure and arrival coordinates from https://maps.google.com

Fill in your subscription key for the DeLijn API. You can get one here: [https://data.delijn.be/developer](https://data.delijn.be/developer)

Fill in the coordinates in the url in the delijn.rb script.

Install needed gems

Create the /var/www/html/delijn directory and copy the following files in there:
* De_Lijn.svg
* disable-collapse.js
* sticky-footer-navbar.css

Run it on a cron!

### See it in action

NMBS: [https://nmbs.vuokko.be](https://nmbs.vuokko.be)

De Lijn: [https://delijn.vuokko.be](https://delijn.vuokko.be)
