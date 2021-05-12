"""
Transforms to and from JSON and a dict
"""
#********************************************************************
#      File:    json.py
#      Author:  Sam Strachan
#
#      Description:
#       JSON adapter
#
#      Copyright (c) 2017 by Cisco Systems, Inc.
#
#       ALL RIGHTS RESERVED. THESE SOURCE FILES ARE THE SOLE PROPERTY
#       OF CISCO SYSTEMS, Inc. AND CONTAIN CONFIDENTIAL  AND PROPRIETARY
#       INFORMATION.  REPRODUCTION OR DUPLICATION BY ANY MEANS OF ANY
#       PORTION OF THIS SOFTWARE WITHOUT PRIOR WRITTEN CONSENT OF
#       CISCO SYSTEMS, Inc. IS STRICTLY PROHIBITED.
#
#*********************************************************************/

from __future__ import absolute_import
import json

def loads( line ):
    """Converts a json line back into a dict"""
    return json.loads( line )

def decode_dict(d):
    result = {}
    for key, value in d.items():
        if isinstance(key, bytes):
            key = key.decode()
        if isinstance(value, bytes):
            value = value.decode()
        elif isinstance(value, dict):
            value = decode_dict(value)
        result.update({key: value})
    return result

def dumps( data ):
    """Serializes the incoming object as a json string"""
    if isinstance(data, dict):
        return json.dumps( decode_dict(data) )
    elif isinstance(data, bytes):
        return json.dumps( data.decode("utf-8") )
    elif isinstance(data, bytearray):
        return json.dumps( data.decode("utf-8") )
    else:
        return json.dumps( data )
