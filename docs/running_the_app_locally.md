# Using Drive the Vote locally

Once you've checked out the repo and gotten the app running locally by following the Docker instructions in the README, here's how to get started using the admin, dispatch, and driver apps.

To demonstrate we'll use the San Francisco ride zone that’s created when you do the local setup. To use it end-to-end you need to have the Twilio credentials associated with that RZ in your local .env file--contact the DtV dev team to get the credentials, or replace the number in the database with one for which you have Twilio credentials.

When you log in with the admin credentials you should land here:<br />
[http://localhost:3000/admin/ride_zones](http://localhost:3000/admin/ride_zones)

To create a ride, you can click the ‘schedule’ link next to the ride zone in which you want to create it, and you’ll get a form for scheduling rides. For SF, it would be this one:<br />
[http://localhost:3000/ride/san_francisco](http://localhost:3000/ride/san_francisco)

Note that if you click ‘Dispatch,’ you’ll go to the page for use by RZ dispatchers--if you have dispatch credentials for a ride zone, but aren’t a system admin, when you log in you’ll end up on that page. Again for SF:<br />
[http://localhost:3000/dispatch/san_francisco](http://localhost:3000/dispatch/san_francisco)

And that too has a link to the ride scheduling form, labelled ‘Schedule a ride’. If you schedule a ride for less than 15 minutes in the future, you should see it show up on the dispatcher map as a blue pin, with a corresponding row in the table to the left the map (or below it, depending on your window width). Here’s the address for San Francisco City Hall, if you want to test with that:
1 Dr Carlton B Goodlett Pl, San Francisco, CA 94102

When you set up your local DB it creates a driver in San Francisco, Deborah Driver, but she’s “unassigned,” which is a bit of a misnomer--it means she hasn’t been approved to drive yet. That’s because we want to allow our partners to vet drivers, and approve them once they've been vetted. If you go to the ‘Drivers’ tab of the admin page, and select “View: All”, you should see her at the top of the list. Use the dropdown to promote her to a driver for SF.

Once Deborah has been promoted to legit driver, log into an incognito browser using her credentials (deborah@fnnny.com/1234abcd). We’ll use this window to spoof the driver app.

which should be what you're now looking at, at the url

- Open the Chrome dev tools
- Click the vertical '...' on the right-hand side
- Select 'More tools', and then 'Sensors'
- In the lower left of the window you should see a 'Geolocation' option, set to 'No override'. Either select a preset override, or enter a custom lat/long. Note that it must be in decimal notation (not degrees/minutes), and not go longer than six decimal places.



____


John McGrath [10:21 AM]
@dryan and I are sorting out how to share creds for email notifications, will involve a switch from Sendgrid to AWS SES, which hopefully i’ll do tonight and can get you creds for that tomorrow. everything will work until then though, just no email notifications.
Though if you want to use it as-is and have a Sendgrid account, you can put these creds in your .env, with your info, and it’ll work:
SEND_GRID_USER_NAME=xxxxxx
SEND_GRID_PASSWORD=xxxxxx