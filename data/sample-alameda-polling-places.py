from __future__ import print_function

from argparse import ArgumentParser
from itertools import count
from time import sleep
from csv import writer

# `pip install requests==2.11.0 uritemplate==0.6 beautifulsoup4==4.5.1`
from uritemplate import expand
from bs4 import BeautifulSoup
from requests import get

# URI template and default parameters for Mapzen Search API.
# Read more at https://mapzen.com/documentation/search/search/
search_template = 'https://search.mapzen.com/v1/search{?api_key,text}{&size,boundary.rect.min_lat,boundary.rect.min_lon,boundary.rect.max_lat,boundary.rect.max_lon}'
search_kwargs = {
    # use OpenAddresses to ensure we don't trip over OpenStreetMap license.
    'sources': 'oa',
    
    # look inside Alameda County (-ish)
    'boundary.rect.min_lat': 37.422,
    'boundary.rect.min_lon': -122.369,
    'boundary.rect.max_lat': 37.912,
    'boundary.rect.max_lon': -121.405,
    
    # one result, please
    'size': 1
    }

parser = ArgumentParser('Download sample Alameda County data')
parser.add_argument('mapzen_key', help='Mapzen Search API key available from https://mapzen.com/developers')
parser.add_argument('output', help='Output CSV filename')

if __name__ == '__main__':
    args = parser.parse_args()
    search_kwargs.update(api_key=args.mapzen_key)
    
    # Retrieve a list of all HTML table cells inside #pollingLocationsDiv
    places_url = 'http://www.acgov.org/rov_app/pollinglist/election/229'
    soup = BeautifulSoup(get(places_url).content, 'html.parser')
    rows = soup.find(id='pollingLocationsDiv').find_all('tr')

    nums, places = count(1), list()
    
    # Iterate over all the table rows...
    for (num, row) in zip(nums, rows):
        print(num, 'of', len(rows))
    
        try:
            td1, td2, td3, td4, _ = row.find_all('td')
        except ValueError:
            # Skip this row if it doesn't have five cells.
            continue
        
        # Get meaningful values from first four cells.
        precinct_id = td1.contents[-1]
        is_accessible = (td2.find('img') is not None)
        location = td3.contents[-1].strip()
        address = td4.contents[-1].strip()
        
        # Stash in the places list, prior to geocoding.
        places.append([precinct_id, is_accessible, location, address, None, None, None, None])
        
        # Attempt to geocode up to three times, to allow for rate-limiting.
        for attempt in range(3):
            search_url = expand(search_template, dict(text=address, **search_kwargs))
            search_resp = get(search_url)
            
            if search_resp.status_code != 200:
                # Oops, maybe rate-limited.
                print('trying', address, 'again')
                sleep(1)
                continue
        
            try:
                # Look for properties in GeoJSON response.
                geometry = search_resp.json()['features'][0]['geometry']
                properties = search_resp.json()['features'][0]['properties']
                label, gid = properties['label'], properties['gid']
                lon, lat = geometry['coordinates']
                
                # Update current place in the places list.
                places[-1][-4:] = gid, label, lat, lon
            except:
                pass

            break
    
    # Write to output CSV file.
    with open(args.output, 'w') as file:
        out = writer(file)
        out.writerow(('precinct', 'is_accessible', 'location', 'address', 'mapzen GID', 'geocoded address', 'lat', 'lon'))
        
        for place in places:
            out.writerow(place)
