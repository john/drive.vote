### Conversation Bot
The conversation bot is a very simple chat bot designed to gather information from a voter in a _linear flow_. 
Here is the information the bot wants to collect from the voter:

- Language (currently English or Spanish)
- Name
- Pickup location **
- Destination location (can be skipped) **
- Pickup time **
- Number of additional passengers
- Any special requests (e.g. wheelchair, car seats)

The steps marked ** have an additional confirmation question. Note that all Spanish in this doc was from google 
translate so it's likely to be hilariously wrong until a native speaker cleans it up (and removes this sentence).

### Typical Flow
Here is a "perfect" flow in English where everything is understood and works the first time. This is for a brand new 
voter sending an SMS to our ride zone phone number for the first time.

**Voter**: Hi there I need a ride. I was given this number?

**Bot**: Hi, thanks for contacting us for a ride! This is an automated system. Reply "1" for English, Responder "2" para el español.

**Voter**: 1

**Bot**: Thanks! What is your name?

**Voter**: joe

**Bot**: Hello joe. Where do you want to be picked up - address and city?

**Voter**: 150 south main providence

**Bot**: Please confirm the address is 150 S Main Street, Providence RI 02903. Yes/no?

**Voter**: yup

**Bot**: Where do you want to go - address and city? If not sure, reply "don't know" or "skip".

**Voter**: first unitarian church providence

**Bot**: Please confirm the address is First Unitarian Church Providence RI. Yes/no?

**Voter**: yes

**Bot**: When do you want to be picked up (HH:MM am/pm)?

**Voter**: 5pm

**Bot**: Please confirm pickup today at 5:00 pm. Yes/no?

**Voter**: right

**Bot**: How many additional people need a ride (0-4)?

**Voter**: none

**Bot**: What are your special requests (like wheelchair, car seats)? Or reply none.

**Voter**: none

**Bot**: Thank you! We have your info and will contact you before your ride.

### Problems
The perfect flow will only happen if the voter is a software engineer. The bot can handle various issues but 
pretty quickly will give up and call for human help if it runs into trouble. Here is what the bot can handle 
at each step and when it will give up.

#### Language
Accepts:
- 1 or eng in the text for English
- 2 or esp in the text for Spanish

On non-matching input, bot will reply with this twice then give up:

**Bot**: Sorry I did not understand. Reply help/ayuda to reach a person. Please reply with "1" for English. Responder "2" para el español.

When giving up:

**Bot**: Someone will contact you soon - Alguien se pondrá en contacto en breve

#### Name
Accepts: anything not blank

On blank input, bot will reply twice with "Sorry, I didn't get a response. What is your name?" and then
give up.

#### Origin location
Accepts: free form text

The bot appends the ride zone state to the input text and calls a geocoder to get a full address and
lat/long location. This search can return zero, one, or more than one response. If we get back one
response we echo it back and confirm it. The bot will attempt to get origin three times before giving up.

Zero responses: "Address not found. Please reply with specific address and city or reply "don't know" or "skip"."

More than one response: "Too many matches! Please reply with specific address and city or reply "don't know" or "skip"."

The following expressions are accepted as "don't know/skip":

- don't know
- dont know
- unsure
- dunno
- skip
- omitir
- seguro
- no se
- no sé

On giving up or the voter indicating don't know/skip:

**Bot**: Someone will contact you soon.

#### Confirming origin location
Accepts: positive response

- y (anything with a y so yes, yup, y)
- right
- correct
- good
- sure
- cierto
- bien
- si
- sí

If none of these are present, bot prompts again for the origin location

#### Destination location
Accepts: free form text

The process is the same as origin location, except:

- The bot gives up after 2 errors, not 3
- The bot does not stall out. It simply skips gathering the destination and moves on, because the
 driver can always figure this out.

#### Confirming origin location
Accepts: positive response

Same as origin location

#### Pickup time
Accepts:
- something that looks like a time 12hr + am/pm or 24hr
- now or ahora

If the bot cannot determine the time, or if it is in the past, it will try twice with this message:

**Bot**: That doesn't look like a good time or it's passed. Enter something like 4:30pm

#### Confirming time
Accepts: positive response as above

If none of the positive responses are present, bot prompts again for the time

#### Additional people
Accepts:
- 0, none, zero, nada, cero
- 1, one, uno
- 2, two, dos
- 3, three, tres
- 4, four, cuatro

If none of these is present, bot tries twice with this message. After two times, replies "Someone will 
contact you soon".

**Bot**: Please reply with number of additional passengers (0-4)

#### Special requests
Accepts: free form text

There is no validation on this, we just store it in the database.

### Special Case

When a voter has completed their first ride and texts back to the bot we assume they are looking
for a return ride. If their first conversation resulted in a full origin and destination address
we ask them this:

**Bot**: Welcome back! Reply "help" at any time. Are you going from <prior destination> to <prior origin>?

On a positive response, the bot fills in the origin and destination and picks up the flow from there (asking
for pickup time).
