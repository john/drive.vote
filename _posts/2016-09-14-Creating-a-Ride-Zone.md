---
layout: default
title: Creating a Ride Zone
pubished: true
---

# Creating a Ride Zone

## Commitment from local users
Before creating a ride zone we need a firm commitment from a field office or other local entity to work with us to make it a success. They need a single point person to lead the project on their end, to finding a dispatcher and volunteers drivers, and to make sure their people are familiar with the system. We commit to doing everything we can to help, and to make it as easy as possible.

## Get a phone number from Twilio
Complete documentation [here}(https://github.com/john/drive.vote/wiki/Buying-and-Configuring-Twilio-Numbers), but in brief, you can search for local area codes [here](http://www.allareacodes.com/area-code-lookup/) (confirm with the local admin that the selected area code is appropriate). Once you know the area code you can search Twilio for number in it [here](https://www.twilio.com/console/phone-numbers/search). Make sure the number you select has SMS, MMS, and voice capability. Once you've gotten the number and are setting it up, make sure that in the 'messaging' section 'A message comes in' is configured with a webhook pointing to 'https://drive.vote/api/1/twilio/sms,' as an HTTP POST

## Create the DtV account
A DtV administrator can create a ride zone [here](https://drive.vote/admin/ride_zones). The RZ name will appear on the top of their dispatch page, the slug should be all lowercase with no spaces--it's used in the URL, ie, /dispatch/toledo_oh. Be sure to add the name and info for the ride zone administrator at the local level, so that in addition to creating the ride zone, a user account is created for them.

## Add users
Ride zones have three classes of internal users: dispatchers, and drivers, and admins. There's a one-to-many relationship between dispatchers and drivers: the dispatcher monitors the system, texts with voters when a request isn't handled automatically or directly by a driver, and make sure all ride requests are handled. They have a web app where they can see voters and drivers, and through which they can text directly with voters. You can read more about the dispatcher app [here](Using-the-Dispatcher-App)

Drivers are available to pick up voters, either for pre-scheduled rides, or on-demand as requests come in. They have a mobile web app designed for use on a phone, which shows them nearby ride requests they can take, and which lets them know when a dispatcher has assigned a ride to them. The driver app also regularly reports the driver's location back to the dispatcher, so that dispatchers can match drivers to voters based on proximity. Drivers can use the app to mark themselves as on or off duty. You can read more about the driver app [here](Using-the-Driver-App)

Admins can add new users and edit things like the zone's name and Twilio number. It's possible for a user to be any combination of admin, dispatcher, and driver.