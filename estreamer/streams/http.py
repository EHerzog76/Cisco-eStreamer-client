
#********************************************************************
#      File:    tcp.py
#      Author:  Sam Strachan
#
#      Description:
#       This writes to a tcp port with a stream interface
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

import http.client
import json
from datetime import date
from estreamer.streams.base import Base

# See: # https://wiki.python.org/moin/UdpCommunication

class HttpStream( Base ):
    """Creates a UDP socket and sends messages to it"""
    def __init__( self, host, port, path, headers, extraData, httpMethod, loglevel, encoding = 'utf-8' ):
        self.host = host
        self.port = port
        if path is None:
            path = "/"
        self.path = path
        self.Headers = headers
        self.extraData = extraData
        if httpMethod is None:
            httpMethod = "POST"
        self.httpMethod = httpMethod.upper()
        if loglevel is None:
            self.logLevel = 0
        elif loglevel == "ERROR":
            self.logLevel = 500
        elif loglevel == "WARNING":
            self.logLevel = 400
        elif loglevel == "WARN":
            self.logLevel = 400
        elif loglevel == "INFO":
            self.logLevel = 200
        elif loglevel == "DEBUG":
            self.logLevel = 1
        else:
            self.logLevel = 0
        self.encoding = encoding
        self.conn = None
        #print("{0}:{1}{2} Headers {3} {4} {5} {6}".format(self.host, self.port, self.path, self.extraData, self.httpMethod, self.logLevel, self.encoding))


    def __connect( self ):
        self.conn = http.client.HTTPConnection(self.host, self.port)


    def close( self ):
        try:
            self.conn.close()

        except AttributeError:
            pass



    def write( self, data ):
        if self.conn is None:
            self.__connect()

        #json_data = "{ \"index\" : { \"_index\" : \"fmc-\", \"_type\" : \"_doc\" } }"
        if self.extraData is None:
            json_data = ""
        else:
            json_data = date.today().strftime(self.extraData)
        Lines = data.split('\n')
        for d in Lines:
            if d.strip() != '':
                if json_data == '':
                    json_data = d
                else:
                    json_data += ",\n" + d
        json_data += "\n"
        ### Debug
        if self.logLevel == 0:
            hdr = ""
            for k, v in self.Headers.items():
                hdr += k + ":" + v + " / "
                print("\nSEND: {0} {1} {2} {3}".format(self.httpMethod, self.path, hdr, json_data))
        ###data.encode( self.encoding )
        self.conn.request(self.httpMethod, self.path, json_data, self.Headers)
        if self.logLevel == 0:
            pass
        else:
            try:
                response = self.conn.getresponse()
                if response.status >= self.logLevel:
                    print(response.read().decode())
                else:
                    recv = response.read()

            except:
                pass

