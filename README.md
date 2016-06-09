## SSL Check

An easy way to verify the installation of SSL certificates.

[![Build Status](https://travis-ci.org/clayton/sslcheck.svg?branch=master)](https://travis-ci.org/clayton/sslcheck)
[![Code Climate](https://codeclimate.com/github/clayton/sslcheck/badges/gpa.svg)](https://codeclimate.com/github/clayton/sslcheck)

## Installation

Install the gem on your system

```
  gem install sslcheck
```

Use the gem with bundler by adding the following to your `Gemfile`

```
  gem "sslcheck"
```

## Using SSLCheck

The SSLCheck gem has a simple API.

First create a check:

```
  check = SSLCheck::Checker.new
```

Then, check a url:

```
  check.check("github.com")
```

Is the certificate valid?

```
  check.valid?
  => true
```

Are there any errors?

```
  check.errors
  => []
```

## Timeouts

By default, connections to verify a certificate will timeout after 30 seconds. To
change this behavior, specify your own timeout, in seconds, on the `SSLCheck::Client`
class.

```
  SSLCheck::Client.timeout_seconds = 10  # A 10 second timeout
  check = SSLCheck::Checker.new
  check.check("github.com")
```

What are the details of the certificate?

The peer certificate found during the check is available with a rich
(undocumented) API. See `SSLCheck::Certificate` for more details. A helper
method is provided on the `Certificate` to get at most of the important details.

```
  checker.peer_cert.to_h
  {:common_name=>"letsencrypt.org",
   :organization_unit=>"Domain Control Validated",
   :not_before=>
    #<DateTime: 2014-07-25T00:00:00+00:00 ((2456864j,0s,0n),+0s,2299161j)>,
   :not_after=>
    #<DateTime: 2015-07-25T23:59:59+00:00 ((2457229j,86399s,0n),+0s,2299161j)>,
   :issued=>true,
   :expired=>false,
   :issuer=>
    {:common_name=>"COMODO RSA Domain Validation Secure Server CA",
     :country=>"GB",
     :state=>"Greater Manchester",
     :locality=>"Salford",
     :organization=>"COMODO CA Limited"}}
  => {:common_name=>"letsencrypt.org", :organization_unit=>"Domain Control Validated", :not_before=>#<DateTime: 2014-07-25T00:00:00+00:00 ((2456864j,0s,0n),+0s,2299161j)>, :not_after=>#<DateTime: 2015-07-25T23:59:59+00:00 ((2457229j,86399s,0n),+0s,2299161j)>, :issued=>true, :expired=>false, :issuer=>{:common_name=>"COMODO RSA Domain Validation Secure Server CA", :country=>"GB", :state=>"Greater Manchester", :locality=>"Salford", :organization=>"COMODO CA Limited"}}
```

What are the details of the CA Bundle?

Each certificate in the CA Bundle is available as an `SSLCheck::Certificate`
instance if needed.


### Potential Validation Errors

**SSLCheck::Errors::Validation::CommonNameMismatch**

Occurs when the common name supplied in the check does not match the common name
on the certificate, any alternate subject names or match a regex based on the
wildcard domain if the certificate was issued for a wildcard domain.

**SSLCheck::Errors::Validation::NotYetIssued**

Occurs when the certificates `not_before` date is in the future.

**SSLCheck::Errors::Validation::CertificateExpired**

Occurs when the certificates `not_after` date is in the past.

**SSLCheck::Errors::Validation::CABundleVerification**

Occurs when the CA Bundle (peer certificate chain) that is gathered during the
connection to the server cannot verify the certificate. This is a very common
error when setting up and install SSL Certificates and occurs when the web
server is not configured correctly or the CA Bundle certificates from the
certificate issuer were not configured or installed correctly.



### Validating Certificates

A certificate is considered valid if the certificate is present, the CA
bundle is present and all of the default validations pass.

By default, SSLCheck validates the following:

* Common Name matches (accounting for alternate names and wildcard certificates)
* CA Bundle Verification (can the CA bundle verify the certificate?)
* Issue Date (is in the past)
* Expiration Date (is in the future)

## Custom Client

By default, all certificates are fetched by opening an SSL Socket Connection and
grabbing the peer certificate and peer certificate chain (CA Bundle.)

A custom client should return a response that exposes the peer certificate,
peer certificate chain and url that was fetched. See `SSLCheck::Client::Response`
for more information.

### Using a custom client

```
  check = SSLCheck::Checker.new(MyClient.new)
```

## Custom Validators and Validations

A custom validator can be used to allow for additional validations or override
the default validations. For more information see `SSLCheck::Validator`

### Using a custom validator

```
  # passing nil as the first argument to use the default client
  check = SSLCheck::Checker.new(nil, MyValidator.new)
```

## Contributing

* Fork
* Run the tests (`rake`)
* Commit & Push
* Submit a pull request

## Special Thanks

* [https://badssl.com](https://badssl.com)
* [https://letsencrypt.org](https://letsencrypt.org)

## License

The MIT License (MIT)

Copyright (c) 2014 Clayton Lengel-Zigich

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
