.. image:: https://d2xtrvzo9unrru.cloudfront.net/brands/smartfile/logo.png
   :alt: SmartFile

A `SmartFile`_ Open Source project. `Read more`_ about how SmartFile
uses and contributes to Open Source software.

Summary
------------

This library includes two API clients. Each one represents one of the supported
authentication methods. ``SFBasicClient`` is used for HTTP Basic authentication,
using an API key and password. ``SFOAuth1Client`` is used for OAuth (version 1) authentication,
using tokens, which will require user interaction to complete authentication with the API.

Both clients provide a wrapper around `AFNetworking <https://github.com/AFNetworking/AFNetworking>`_
library, taking care of some of the mundane details for you. The intended use of this library is to
refer to the API documentation to discover the API endpoint you wish to call, then use
the client library to invoke this call.

SmartFile API information is available at the
`SmartFile developer site <https://app.smartfile.com/api/>`_.

Installation
------------

Get the source code from GitHub.

::

    $ git clone https://github.com/smartfile/client-objc.git smartfile
    $ cd smartfile

You can see following directory structure.

::
   
   Example
   SmartFile
   SmartFileTests
   README.rst

Copy ``SmartFile`` folder to your project. In your source code import

::
   
   #import "SFBasicClient.h"

or

::

   #import "SFOAuth1Client.h"

depending on which authentication method you want to use.


More information is available at `GitHub <https://github.com/smartfile/client-objc>`_.


Usage
-----

Choose between Basic and OAuth authentication methods, then continue to use the SmartFile API.
Check the ``Example`` project which implements a simple SmartFile browser or ``SmartFileTests``
project that has dosen of SmartFile API call examples.


Running Example
---------------

Before running Example application ensure that SM_API_URL and SM_API_VERSION are set to appropriate values in
SFCredentials.h. Otherwise the exception will be raised.

Running Tests
-------------

Before running tests ensure that SM_API_URL and SM_API_VERSION as well as SM_BASIC_API_KEY SM_BASIC_API_PASSWORD
are set in Credentials.h. Otherwise tests will fail.

Basic Authentication
--------------------

Basic authentication is quite simple and requires you to provide API key and password.

   .. code:: objective-c

       #define SM_API_URL      @"https://your_user_name.smartfile.com/"
       #define SM_API_VERSION  @"2"

       #define SM_BASIC_API_KEY        @"your_basic_api_key"
       #define SM_BASIC_API_PASSWORD   @"your_basic_api_password"

       NSError *error = nil;

       SFBasicClient *basicClient = [[SFBasicClient alloc] initWithUrl:SM_API_URL version:SM_API_VERSION];

       error = [basicClient setKey:SM_BASIC_API_KEY];

       if (error != nil) {
           // Key format is invalid.
       }

       error = [basicClient setPassword:SM_BASIC_API_PASSWORD];

       if (error != nil) {
           // Password format is invalid.
       }

       [basicClient doGetRequest:@"/ping" 
                          object:nil
                           query:nil
                        callback:^(NSData *data, NSInteger statusCode, NSError *error)
       {
           if (error != nil) {
               // Invalid credentials.
           } else {
               // Login successful.
           }
       }];

OAuth Authentication
--------------------

Authentication using OAuth authentication is bit more complicated, as it involves tokens and secrets.

.. code:: objective-c

    #define SM_API_URL      @"https://your_user_name.smartfile.com/"
    #define SM_API_VERSION  @"2"

    #define SM_OAUTH_TOKEN  @"your_oauth_token"
    #define SM_OAUTH_SECRET @"your_oauth_secret"

    NSError *error = nil;

    SFOAuth1Client *oauthClient = [[SFOAuth1Client alloc] initWithUrl:SM_API_URL version:SM_API_VERSION];

    error = [oauthClient authorizeWithToken:SM_OAUTH_TOKEN secret:SM_OAUTH_SECRET callback:^(NSError *error) {
        // AFOAuth1Client performs authorization. Web view will be opened automatically if needed.
        if (error != nil) {
            // Authorization failed.
        } else {
            // Authorization successful.
        }
    }];

    if (error != nil) {
        // OAuth token/secret format is invalid.
    }

Calling endpoints
-----------------

Once you instantiate a client, you can use the get/put/post/delete methods
to make the corresponding HTTP requests to the API. There is also a shortcut
for using the GET method, which is to simply invoke the client.

.. code:: objective-c

    SFBasicClient *basicClient = [[SFBasicClient alloc] initWithUrl:SM_API_URL version:SM_API_VERSION];

    [basicClient setKey:SM_BASIC_API_KEY];
    [basicClient setPassword:SM_BASIC_API_PASSWORD];

    [basicClient doGetRequest:@"/ping"
                       object:nil
                        query:nil
                     callback:^(NSData *data, NSInteger statusCode, NSError *error)
    {
        // Do something with response.
    }];

Some endpoints accept an ID, this might be a numeric value, a path, or name,
depending on the object type. For example, a user's id is their unique
``username``. For a file path, the id is it's full path.

.. code:: objective-c

    SFBasicClient *basicClient = [[SFBasicClient alloc] initWithUrl:SM_API_URL version:SM_API_VERSION];

    [basicClient setKey:SM_BASIC_API_KEY];
    [basicClient setPassword:SM_BASIC_API_PASSWORD];

    [basicClient doGetRequest:@"/path/info/"
                       object:nil
                        query:nil
                     callback:^(NSData *data, NSInteger statusCode, NSError *error)
    {
        // Do something with response.
    }];

Result will be similar to:

.. code:: java-script

    {u'acl': {u'list': True, u'read': True, u'remove': True, u'write': True},
     u'attributes': {},
     u'extension': u'',
     u'id': 7,
     u'isdir': True,
     u'isfile': False,
     u'items': 348,
     u'mime': u'application/x-directory',
     u'name': u'',
     u'owner': None,
     u'path': u'/',
     u'size': 220429838,
     u'tags': [],
     u'time': u'2013-02-23T22:49:30',
     u'url': u'http://localhost:8000/path/info/'}

File transfers
--------------

Uploading and downloading files is supported.

To upload files, pass array of file paths in local filesystem.

.. code:: objective-c

    SFBasicClient *basicClient = [[SFBasicClient alloc] initWithUrl:SM_API_URL version:SM_API_VERSION];

    [basicClient setKey:SM_BASIC_API_KEY];
    [basicClient setPassword:SM_BASIC_API_PASSWORD];

    NSString *testFilePath = [[NSBundle bundleForClass:[self class]] pathForResource:@"test_file" ofType:@"txt"];

    [basicClient doPostRequest:@"/path/data/"
                       object:nil
                        query:nil
                        files:@[testFilePath]
                     callback:^(NSData *data, NSInteger statusCode, NSError *error)
    {
        // Do something with response.
    }];


Downloading:

.. code:: objective-c

    SFBasicClient *basicClient = [[SFBasicClient alloc] initWithUrl:SM_API_URL version:SM_API_VERSION];

    [basicClient setKey:SM_BASIC_API_KEY];
    [basicClient setPassword:SM_BASIC_API_PASSWORD];

    NSString *outPath = [@"~/test_file.txt" stringByExpandingTildeInPath];

    [basicClient doGetRequest:@"/path/data"
                       object:@"/test_file.txt"
                        query:nil
                   outputFile:outPath
                     callback:^(NSData *data, NSInteger statusCode, NSError *error)
    {
        // Do something with response.
    }];

Tasks
-----

Operations are long-running jobs that are not executed within the time frame
of an API call. For such operations, a task is created, and the API can be used
to poll the status of the task.

.. code:: objective-c

    SFBasicClient *basicClient = [[SFBasicClient alloc] initWithUrl:SM_API_URL version:SM_API_VERSION];

    [basicClient setKey:SM_BASIC_API_KEY];
    [basicClient setPassword:SM_BASIC_API_PASSWORD];

    NSString *testFilePath = [[NSBundle bundleForClass:[self class]] pathForResource:@"foobar" ofType:@"png"];

    [basicClient doPostRequest:@"/path/data/"
                       object:nil
                        query:nil
                        files:@[testFilePath]
                     callback:^(NSData *data, NSInteger statusCode, NSError *error)
    {
        // Do something with response.
    }];

    [basicClient doGetRequest:@"/task"
                       object:@"uuid"
                        query:nil
                   outputFile:outPath
                     callback:^(NSData *data, NSInteger statusCode, NSError *error)
    {
        // Check status.
    }];


.. _SmartFile: http://www.smartfile.com/
.. _Read more: http://www.smartfile.com/open-source.html
