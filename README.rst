hgweb
=====

This is my homepage, rewritten from the ground up in lwan so it is entirely in C.
Right now, it is nothing flashy (very similar to the Haskell version); project pages (and perhaps a few other treats) are planned for the near future.

The Stack
---------

* `lwan <https://lwan.ws/>`_ - used as a library to build the webserver and page logic
* `hitch <https://hitch-tls.org/>`_ - TLS-terminating proxy server
* `acme-client (portable) <https://kristaps.bsd.lv/acme-client/>`_ - an ACME-protocol client for TLS Cert renewal

All running on Arch Linux using `nftables <https://netfilter.org/projects/nftables/>`_ for traffic redirection and forwarding

Traffic Redirection and Forwarding
----------------------------------

lwan does not officially support running on an internal port, and it remains the author's express suggestion to not do so.
To bypass this limitation, we leverage hitch to redirect traffic from ``443`` to ``8443`` (where the contentful instance of lwan is running) and back.

Furthermore, to forcibly redirect HTTP to HTTPS, we use nftables to redirect traffic from ``80`` to ``8080``.
Then, a very small instance of lwan is running on port ``8080`` that does nothing but respond to ACME challenge requests and redirect all other traffic to ``https://halosgho.st``.

Design Characteristics
----------------------

* `Secure Header Configuration <https://securityheaders.com/?q=halosgho.st&followRedirects=on>`_
* `Secure TLS Configuration <https://www.ssllabs.com/ssltest/analyze.html?d=halosgho.st>`_
* `Good Accessibility <http://wave.webaim.org/report#/http://halosgho.st>`_
* `High Performance <https://gtmetrix.com/reports/halosgho.st/pXtTFfZV/latest>`_
* `Valid, Modern, Semantic Markup <https://validator.nu/?doc=https%3A%2F%2Fhalosgho.st>`_
* `Valid Styles <https://jigsaw.w3.org/css-validator/validator?uri=halosgho.st>`_

