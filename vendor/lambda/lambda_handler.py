#! /usr/bin/env python3

import json
import os
from urllib import request


def lambda_handler(options, *args, **kwargs):
    """
    options is a dictionary and must contain a domain property.
    The domain is used to form the API URL, which is then POSTed to.
    The response code of that request is returned in the response dict.
    """
    assert options.get('domain'), 'domain is a required property of options'
    url = 'https://{}/api/1/rides/confirm_scheduled'.format(
        options.get('domain')
    )
    # setup the request instance
    req = request.Request(
        url,
        data={},  # setting data to any non None value makes this a POST request
        headers={
            'User-Agent': 'DtV Ping',
            # this is a pre-shared secret to make sure the request is from a trusted source
            'X-Token': os.getenv('API_TOKEN'),
        }
    )
    # make the request
    resp = request.urlopen(req)
    # return back a dict with the status code
    return {
        "statusCode": resp.code,
    }


# this is for running in the command line and is not used by Lambda
if __name__ == '__main__':
    import argparse
    parser = argparse.ArgumentParser()
    parser.add_argument('domain')
    options = parser.parse_args()
    print(lambda_handler(dict(domain=options.domain)))
