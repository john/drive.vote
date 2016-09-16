---
layout: default
title: Buying and Configuring Twilio Numbers
pubished: true
---

# Buying and Configuring Twilio Numbers

First find the area code of the town or city you want a number for, which you can do <a href="http://www.allareacodes.com/" target="_blank">here</a>.

Once you have an area code log in to Twilio and go to the console: https://www.twilio.com/console. Click the '...' icon on the left-side navbar, scroll down, and select 'Phone Numbers' from the 'Numbers' section. From the new nav options that become visible, click 'Buy a Number'.

Make sure 'United States' is selected, put the area code into the 'Number' box, and make sure 'begins with term' is selected. Make sure 'voice', 'sms', and 'mms' are all selected by 'Capabilities', then hit 'Search'.

You should get a bunch of numbers to choose from, for $1/mo each. Pick one with the correct area code that seems memorable, and click 'Buy', then on the confirmation screen 'Buy This Number'. Once the purchase is confirmed, click 'Setup number'.

On the next page:
- Scroll down to the 'Messaging' section.
- Leave 'Configure with' set to 'Webhooks/TwiML'.
- Under 'A message comes in', leave the dropdown on 'Webhook', and in the text box past in 'https://drive.vote/api/1/twilio/sms'.
- Hit 'Save'.

That's it! You can now [Create a Ride Zone](Creating-a-Ride-Zone) to use your new number.